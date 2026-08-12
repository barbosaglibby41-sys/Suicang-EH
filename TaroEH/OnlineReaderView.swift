import SwiftUI

struct OnlineReaderView: View {
    let gallery: Gallery
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var reading: ReadingStore
    @State private var pageLinks: [URL] = []
    @State private var imageURLs: [Int: URL] = [:]
    @State private var error: String?
    var body: some View {
        Group { if let error { ContentUnavailableView("无法加载在线页面", systemImage: "exclamationmark.triangle", description: Text(error)) } else if pageLinks.isEmpty { ProgressView("正在获取阅读目录…").tint(.white) } else { SharedReaderView(title: gallery.title, pageCount: pageLinks.count) { i, fit, scale in OnlinePage(url: imageURLs[i], fit: fit, scale: scale).task { await loadPage(i) } } } }.task { await setup() }
    }
    private func setup() async { let cache = ImageURLCache.shared; pageLinks = cache.pages(for: gallery); do { if pageLinks.isEmpty { let detail = try await SiteClient.shared.detail(gallery, cookieHeader: session.cookieHeader()); pageLinks = detail.pageLinks; cache.setPages(pageLinks, gallery: gallery) }; imageURLs = Dictionary(uniqueKeysWithValues: pageLinks.indices.compactMap { i in cache.image(for: gallery, at: i).map { (i, $0) } }); if pageLinks.isEmpty { error = "未能从页面中提取图片目录。" } } catch { error = error.localizedDescription } }
    private func loadPage(_ i: Int) async { guard pageLinks.indices.contains(i), imageURLs[i] == nil else { return }; do { let url = try await SiteClient.shared.imageURL(pageURL: pageLinks[i], cookieHeader: session.cookieHeader()); imageURLs[i] = url; ImageURLCache.shared.setImage(url, gallery: gallery, index: i) } catch { if imageURLs.isEmpty { error = error.localizedDescription } } }
}
private struct OnlinePage: View {
    let url: URL?
    let fit: Bool
    let scale: CGFloat
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        PipelineImage(url: url, cookieHeader: session.cookieHeader(), contentMode: fit ? .fit : .fill)
            .scaleEffect(scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
