import SwiftUI
import UIKit

/// Picks the right reader for a gallery.
enum ReaderDestination {
    @ViewBuilder
    static func view(for gallery: Gallery, startIndex: Int = 0) -> some View {
        if gallery.sourceURL != nil {
            OnlineReaderView(gallery: gallery, startIndex: startIndex)
        } else if OfflineLibrary.hasCompleteCopy(gallery) {
            OfflineReaderView(gallery: gallery, startIndex: startIndex)
        } else {
            ContentUnavailableView("无法阅读", systemImage: "book", description: Text("该作品缺少在线地址，且没有离线副本。"))
        }
    }

    static func canRead(_ gallery: Gallery) -> Bool {
        gallery.sourceURL != nil || OfflineLibrary.hasCompleteCopy(gallery)
    }
}

struct SharedReaderView<Source: View>: View {
    let title: String
    let gallery: Gallery
    let pageCount: Int
    let initialIndex: Int
    let onIndexChange: (Int) -> Void
    let onPageAppear: (Int) -> Void
    @ViewBuilder let source: (Int, Bool, CGFloat) -> Source
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var reading: ReadingStore
    @AppStorage("taro.eh.reader.direction") private var direction = "horizontal"
    @AppStorage("taro.eh.reader.fit") private var fit = true
    @AppStorage("taro.eh.reader.keepScreenOn") private var keepScreenOn = true
    @State private var index: Int
    @State private var showUI = false
    @State private var scale: CGFloat = 1
    @State private var sliderIndex = 0
    @State private var isProgrammaticScroll = false
    @State private var autoHideWorkItem: Task<Void, Never>?
    @State private var hasRestoredInitialPosition = false

    init(gallery: Gallery, title: String, pageCount: Int, initialIndex: Int = 0, onIndexChange: @escaping (Int) -> Void = { _ in }, onPageAppear: @escaping (Int) -> Void = { _ in }, @ViewBuilder source: @escaping (Int, Bool, CGFloat) -> Source) {
        self.gallery = gallery
        self.title = title
        self.pageCount = pageCount
        self.initialIndex = initialIndex
        self.onIndexChange = onIndexChange
        self.onPageAppear = onPageAppear
        self.source = source
        _index = State(initialValue: min(max(0, initialIndex), max(0, pageCount - 1)))
        _sliderIndex = State(initialValue: min(max(0, initialIndex), max(0, pageCount - 1)))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            content
        }
        .foregroundStyle(.white)
        .statusBarHidden(true)
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .safeAreaInset(edge: .top, spacing: 0) {
            if showUI {
                topBar
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showUI {
                bottomBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showUI)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
            sliderIndex = index
            showUIWithAutoHide()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            autoHideWorkItem?.cancel()
            reading.flush()
        }
        .onChange(of: index) { _, value in
            sliderIndex = value
            reading.save(gallery: gallery, pageIndex: index)
            onIndexChange(value)
            // Re-show UI briefly when changing pages if it was visible
            if showUI { showUIWithAutoHide() }
        }
    }

    private func showUIWithAutoHide() {
        autoHideWorkItem?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            showUI = true
        }
        autoHideWorkItem = Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) { showUI = false }
            }
        }
    }

    @ViewBuilder private var content: some View {
        if direction == "vertical" {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<pageCount, id: \.self) { i in
                            source(i, fit, scale)
                                .id(i)
                                .onAppear {
                                    onPageAppear(i)
                                    // Avoid GeometryReader/PreferenceKey updates on
                                    // every scroll frame. onAppear is enough to
                                    // advance reading progress without driving a
                                    // full-tree layout pass continuously.
                                    guard direction == "vertical", !isProgrammaticScroll, i != index else { return }
                                    index = i
                                    sliderIndex = i
                                }
                        }
                    }
                }
                .coordinateSpace(name: "reader-scroll")
                .onChange(of: sliderIndex) { _, value in
                    guard value != index else { return }
                    isProgrammaticScroll = true
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(value, anchor: .top)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isProgrammaticScroll = false
                    }
                }
                .onAppear {
                    guard !hasRestoredInitialPosition else { return }
                    hasRestoredInitialPosition = true
                    let target = min(max(initialIndex, 0), max(0, pageCount - 1))
                    guard target > 0 else { return }
                    sliderIndex = target
                    isProgrammaticScroll = true
                    DispatchQueue.main.async {
                        proxy.scrollTo(target, anchor: .top)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isProgrammaticScroll = false
                        }
                    }
                }
            }
            .onTapGesture(count: 2) { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { scale = scale == 1 ? 2 : 1 } }
            .onTapGesture(count: 1) {
                if showUI {
                    autoHideWorkItem?.cancel()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showUI = false }
                } else {
                    showUIWithAutoHide()
                }
            }
        } else {
            TabView(selection: $index) {
                ForEach(0..<pageCount, id: \.self) { i in
                    source(i, fit, scale)
                        .tag(i)
                        .onAppear { onPageAppear(i) }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onTapGesture(count: 2) { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { scale = scale == 1 ? 2 : 1 } }
            .onTapGesture(count: 1) {
                if showUI {
                    autoHideWorkItem?.cancel()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showUI = false }
                } else {
                    showUIWithAutoHide()
                }
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down")
                    .font(.headline)
                    .frame(width: 42, height: 38)
                    .contentShape(Rectangle())
            }
            .frame(width: 46)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            Menu {
                Button(direction == "horizontal" ? "切换为纵向滚动" : "切换为横向分页") {
                    withAnimation(.easeInOut(duration: 0.25)) { direction = direction == "horizontal" ? "vertical" : "horizontal" }
                }
                Button(fit ? "切换为填充模式" : "切换为适应模式") { fit.toggle() }
                Button(scale == 1 ? "放大页面" : "还原页面") { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { scale = scale == 1 ? 2 : 1 } }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .frame(width: 42, height: 38)
                    .contentShape(Rectangle())
            }
            .frame(width: 46)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.92))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("第 \(index + 1) / \(pageCount) 页")
                    .font(.caption.weight(.medium))
                Spacer()
                Text("\(progressPercent)%")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Slider(value: Binding(get: { Double(sliderIndex) }, set: { value in
                let next = min(max(0, Int(value.rounded())), max(0, pageCount - 1))
                sliderIndex = next
                index = next
            }), in: 0...Double(max(0, pageCount - 1)), step: 1)
                .tint(.white.opacity(0.85))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.92))
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
        }
    }

    private var progressPercent: Int {
        guard pageCount > 0 else { return 0 }
        return Int((Double(index + 1) / Double(pageCount) * 100).rounded())
    }
}
