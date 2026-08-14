import SwiftUI

struct OnlineReaderView: View {
    let gallery: Gallery
    var startIndex: Int = 0
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var reading: ReadingStore
    @State private var pageLinks: [URL] = []
    @State private var imageURLs: [Int: URL] = [:]
    @State private var loadError: String?
    @State private var nextBatch = 1
    @State private var isLoadingMore = false
    @State private var hasMorePages = true
    @State private var lastLoadedPage = 0

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
                SharedReaderView(title: gallery.title, pageCount: pageLinks.count, initialIndex: min(startIndex, max(0, pageLinks.count - 1)), onIndexChange: { index in
                    reading.save(gallery: gallery, pageIndex: index)
                    lastLoadedPage = max(lastLoadedPage, index)
                    if index >= pageLinks.count - 3 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }, onPageAppear: { index in
                    lastLoadedPage = max(lastLoadedPage, index)
                    if index >= pageLinks.count - 3 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }) { index, fit, scale in
                    ReaderPageImage(url: imageURLs[index], pageNumber: index + 1, fit: fit, scale: scale, onRetry: {
                        Task { await loadPage(index, force: true) }
                    })
                    .task { await loadPage(index) }
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
            nextBatch = max(1, (pageLinks.count + 19) / 20)
            lastLoadedPage = max(0, pageLinks.count - 1)
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func loadMorePagesIfNeeded() async {
        guard hasMorePages, !isLoadingMore, let base = gallery.sourceURL else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "p", value: String(nextBatch))]
        guard let url = components?.url else { hasMorePages = false; return }
        do {
            let data = try await SiteClient.shared.request(url, cookieHeader: session.cookieHeader())
            guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
            let batch = SiteParser.imagePageLinks(from: html, base: base)
            let known = Set(pageLinks.map(\.absoluteString))
            let fresh = batch.filter { !known.contains($0.absoluteString) }
            guard !fresh.isEmpty else { hasMorePages = false; return }
            pageLinks.append(contentsOf: fresh)
            pageLinks.sort { pageNumber($0) < pageNumber($1) }
            ImageURLCache.shared.appendPages(fresh, gallery: gallery)
            nextBatch += 1
            if pageLinks.count >= gallery.pageCount && gallery.pageCount > 0 { hasMorePages = false }
        } catch {
            // Keep hasMorePages true so the next threshold crossing retries.
        }
    }

    private func pageNumber(_ url: URL) -> Int {
        let name = url.path.split(separator: "/").last.map(String.init) ?? ""
        guard let dash = name.lastIndex(of: "-") else { return Int.max }
        return Int(name[name.index(after: dash)...]) ?? Int.max
    }
    private func loadPage(_ index: Int, force: Bool = false) async {
        guard pageLinks.indices.contains(index), force || imageURLs[index] == nil else { return }
        do {
            let url = try await SiteClient.shared.imageURL(pageURL: pageLinks[index], cookieHeader: session.cookieHeader())
            imageURLs[index] = url
            ImageURLCache.shared.setImage(url, gallery: gallery, index: index)
            // Warm the next two image URLs so the following page has less blank time.
            for offset in 1...2 {
                let next = index + offset
                guard pageLinks.indices.contains(next), imageURLs[next] == nil else { continue }
                Task { await loadPage(next) }
            }
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
