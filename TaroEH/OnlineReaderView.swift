import SwiftUI

struct OnlineReaderView: View {
    let gallery: Gallery
    var startIndex: Int = 0
    @EnvironmentObject private var session: SessionStore
    @State private var pageLinks: [URL] = []
    @State private var imageURLs: [Int: URL] = [:]
    @State private var loadError: String?

    var body: some View {
        Group {
            if let loadError {
                VStack(spacing: 14) {
                    Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.orange)
                    Text("无法加载在线页面").font(.headline)
                    Text(loadError).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 24)
                    Button("重试") { Task { await setup() } }.buttonStyle(.borderedProminent)
                }
            } else if pageLinks.isEmpty {
                ProgressView("正在获取阅读目录…").tint(.white)
            } else {
                SharedReaderView(title: gallery.title, pageCount: pageLinks.count, initialIndex: min(startIndex, max(0, pageLinks.count - 1))) { index, fit, scale in
                    OnlinePage(url: imageURLs[index], fit: fit, scale: scale).task { await loadPage(index) }
                }
            }
        }.task { await setup() }
    }

    private func setup() async {
        let cache = ImageURLCache.shared
        pageLinks = cache.pages(for: gallery)
        do {
            if pageLinks.isEmpty {
                let detail = try await SiteClient.shared.detail(gallery, cookieHeader: session.cookieHeader())
                pageLinks = detail.pageLinks
                cache.setPages(pageLinks, gallery: gallery)
            }
            imageURLs = Dictionary(uniqueKeysWithValues: pageLinks.indices.compactMap { index in cache.image(for: gallery, at: index).map { (index, $0) } })
            if pageLinks.isEmpty { loadError = "未能从页面中提取图片目录。" }
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func loadPage(_ index: Int) async {
        guard pageLinks.indices.contains(index), imageURLs[index] == nil else { return }
        do {
            let url = try await SiteClient.shared.imageURL(pageURL: pageLinks[index], cookieHeader: session.cookieHeader())
            imageURLs[index] = url
            ImageURLCache.shared.setImage(url, gallery: gallery, index: index)
        } catch {
            if imageURLs.isEmpty { loadError = error.localizedDescription }
        }
    }
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
