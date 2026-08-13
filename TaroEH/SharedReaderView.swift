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
    @ViewBuilder let source: (Int, Bool, CGFloat) -> Source
    @Environment(\.dismiss) private var dismiss
    @AppStorage("taro.eh.reader.direction") private var direction = "horizontal"
    @AppStorage("taro.eh.reader.fit") private var fit = true
    @AppStorage("taro.eh.reader.keepScreenOn") private var keepScreenOn = true
    @State private var index = 0
    @State private var showUI = true
    @State private var scale: CGFloat = 1
    var body: some View {
        ZStack { Color.black.ignoresSafeArea(); content; if showUI { overlay } }
            .foregroundStyle(.white).statusBarHidden(!showUI)
            .onAppear { UIApplication.shared.isIdleTimerDisabled = keepScreenOn }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
    @ViewBuilder private var content: some View {
        if direction == "vertical" { ScrollView { LazyVStack(spacing: 5) { ForEach(0..<pageCount, id: \.self) { i in source(i, fit, scale).id(i) } } }.onTapGesture(count: 2) { withAnimation { scale = scale == 1 ? 2 : 1 } }.onTapGesture(count: 1) { withAnimation { showUI.toggle() } } }
        else { TabView(selection: $index) { ForEach(0..<pageCount, id: \.self) { i in source(i, fit, scale).tag(i) } }.tabViewStyle(.page(indexDisplayMode: .never)).onTapGesture(count: 2) { withAnimation { scale = scale == 1 ? 2 : 1 } }.onTapGesture(count: 1) { withAnimation { showUI.toggle() } } }
    }
    private var overlay: some View { VStack { HStack { Button { dismiss() } label: { Image(systemName: "chevron.down") }; Spacer(); Text(title).lineLimit(1); Spacer(); Menu { Button("横向分页") { direction = "horizontal" }; Button("纵向滚动") { direction = "vertical" }; Button(fit ? "填充模式" : "适应模式") { fit.toggle() }; Button(scale == 1 ? "放大" : "还原") { withAnimation { scale = scale == 1 ? 2 : 1 } } } label: { Image(systemName: "ellipsis") } }.padding().background(.black.opacity(0.78)); Spacer(); Text(direction == "vertical" ? "连续滚动" : "第 \(index + 1) / \(pageCount) 页").font(.caption).padding().background(.black.opacity(0.78)) } }
}
