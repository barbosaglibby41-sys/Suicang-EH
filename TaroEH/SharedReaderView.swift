import SwiftUI
import UIKit

/// Picks the right reader for a gallery: online when a source URL exists,
/// offline when a complete local copy exists, otherwise a fallback message.
/// Never falls back to the demo reader for real galleries.
enum ReaderDestination {
    @ViewBuilder
    static func view(for gallery: Gallery) -> some View {
        if gallery.sourceURL != nil {
            OnlineReaderView(gallery: gallery)
        } else if OfflineLibrary.hasCompleteCopy(gallery) {
            OfflineReaderView(gallery: gallery)
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

    init(title: String, pageCount: Int, initialIndex: Int = 0, onIndexChange: @escaping (Int) -> Void = { _ in }, onPageAppear: @escaping (Int) -> Void = { _ in }, @ViewBuilder source: @escaping (Int, Bool, CGFloat) -> Source) {
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
            if showUI { overlay }
        }
        .foregroundStyle(.white)
        .statusBarHidden(!showUI)
        .toolbar(showUI ? .visible : .hidden, for: .navigationBar, .tabBar)
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
            sliderIndex = index
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: index) { _, value in
            sliderIndex = value
            onIndexChange(value)
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
                                .onAppear { onPageAppear(i) }
                        }
                    }
                }
                .onChange(of: sliderIndex) { _, value in
                    guard value != index else { return }
                    withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(value, anchor: .top) }
                }
            }
            .onTapGesture(count: 2) { withAnimation { scale = scale == 1 ? 2 : 1 } }
            .onTapGesture(count: 1) { withAnimation(.easeInOut(duration: 0.2)) { showUI.toggle() } }
        } else {
            TabView(selection: $index) {
                ForEach(0..<pageCount, id: \.self) { i in
                    source(i, fit, scale)
                        .tag(i)
                        .onAppear { onPageAppear(i) }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onTapGesture(count: 2) { withAnimation { scale = scale == 1 ? 2 : 1 } }
            .onTapGesture(count: 1) { withAnimation(.easeInOut(duration: 0.2)) { showUI.toggle() } }
        }
    }

    private var overlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.down").font(.headline).frame(width: 34, height: 34)
                }
                Text(title).font(.subheadline.weight(.semibold)).lineLimit(1)
                Spacer()
                Menu {
                    Button(direction == "horizontal" ? "切换为纵向滚动" : "切换为横向分页") { direction = direction == "horizontal" ? "vertical" : "horizontal" }
                    Button(fit ? "切换为填充模式" : "切换为适应模式") { fit.toggle() }
                    Button(scale == 1 ? "放大页面" : "还原页面") { withAnimation { scale = scale == 1 ? 2 : 1 } }
                } label: { Image(systemName: "ellipsis.circle").font(.title3) }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(.black.opacity(0.82))
            Spacer()
            VStack(spacing: 8) {
                HStack {
                    Text(direction == "vertical" ? "连续滚动" : "第 \(index + 1) / \(pageCount) 页").font(.caption.weight(.medium))
                    Spacer()
                    Text("\(progressPercent)%").font(.caption).foregroundStyle(.secondary)
                }
                Slider(value: Binding(get: { Double(sliderIndex) }, set: { value in
                    let next = min(max(0, Int(value.rounded())), max(0, pageCount - 1))
                    sliderIndex = next
                    if direction == "horizontal" { index = next }
                }), in: 0...Double(max(0, pageCount - 1)), step: 1)
                    .tint(.white)
            }
            .padding(.horizontal, 18).padding(.top, 10).padding(.bottom, 14)
            .background(.black.opacity(0.82))
        }
    }

    private var progressPercent: Int {
        guard pageCount > 0 else { return 0 }
        return Int((Double(index + 1) / Double(pageCount) * 100).rounded())
    }
}
