import SwiftUI
import UIKit

private struct ReaderPageOffset: Equatable {
    let index: Int
    let minY: CGFloat
}

private struct ReaderPageOffsetKey: PreferenceKey {
    static var defaultValue: [ReaderPageOffset] = []
    static func reduce(value: inout [ReaderPageOffset], nextValue: () -> [ReaderPageOffset]) {
        value.append(contentsOf: nextValue())
    }
}

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
            // Show UI briefly on entry, then auto-hide
            showUI = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.3)) { showUI = false }
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: index) { _, value in
            sliderIndex = value
            reading.save(gallery: gallery, pageIndex: index)
            onIndexChange(value)
            Haptics.light()
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
                                .background {
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: ReaderPageOffsetKey.self,
                                            value: [ReaderPageOffset(index: i, minY: geo.frame(in: .named("reader-scroll")).minY)]
                                        )
                                    }
                                }
                                .onAppear { onPageAppear(i) }
                        }
                    }
                }
                .coordinateSpace(name: "reader-scroll")
                .onPreferenceChange(ReaderPageOffsetKey.self) { offsets in
                    updateVerticalProgress(offsets)
                }
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
            }
            .onTapGesture(count: 2) { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { scale = scale == 1 ? 2 : 1 } }
            .onTapGesture(count: 1) { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showUI.toggle() } }
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
            .onTapGesture(count: 1) { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showUI.toggle() } }
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
        .background(
            Color.black.opacity(0.85)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 0.5)
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
                    .foregroundStyle(.white.opacity(0.6))
            }
            Slider(value: Binding(get: { Double(sliderIndex) }, set: { value in
                let next = min(max(0, Int(value.rounded())), max(0, pageCount - 1))
                sliderIndex = next
                index = next
            }), in: 0...Double(max(0, pageCount - 1)), step: 1)
                .tint(.white)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Color.black.opacity(0.85)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 0.5)
        }
    }

    private func updateVerticalProgress(_ offsets: [ReaderPageOffset]) {
        guard direction == "vertical", !isProgrammaticScroll, !offsets.isEmpty else { return }
        let candidate = offsets
            .filter { $0.minY <= 140 }
            .max { $0.minY < $1.minY }
            ?? offsets.min { abs($0.minY - 140) < abs($1.minY - 140) }
        guard let candidate else { return }
        let next = min(max(candidate.index, 0), max(0, pageCount - 1))
        guard next != index else { return }
        index = next
        sliderIndex = next
    }

    private var progressPercent: Int {
        guard pageCount > 0 else { return 0 }
        return Int((Double(index + 1) / Double(pageCount) * 100).rounded())
    }
}
