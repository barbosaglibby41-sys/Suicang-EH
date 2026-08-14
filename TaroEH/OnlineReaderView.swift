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
    @State private var setupPhase: SetupPhase = .fetching
    @State private var currentPage = 0
    @State private var resolvingIndices: Set<Int> = []

    enum SetupPhase: Equatable {
        case fetching
        case ready
        case error
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if setupPhase == .error, let loadError {
                errorView(message: loadError)
                    .transition(.opacity)
            } else if setupPhase == .fetching || pageLinks.isEmpty {
                initialLoadingView
                    .transition(.opacity)
            } else {
                SharedReaderView(gallery: gallery, title: gallery.title, pageCount: pageLinks.count, initialIndex: min(startIndex, max(0, pageLinks.count - 1)), onIndexChange: { index in
                    reading.save(gallery: gallery, pageIndex: index)
                    currentPage = index
                    preloadAround(index)
                    if index >= pageLinks.count - 5 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }, onPageAppear: { index in
                    currentPage = index
                    ensurePageLoaded(index)
                    preloadAround(index)
                    if index >= pageLinks.count - 5 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }) { index, fit, scale in
                    ReaderPageImage(
                        url: imageURLs[index],
                        referer: gallery.sourceURL,
                        pageNumber: index + 1,
                        status: .loading,
                        fit: fit,
                        scale: scale,
                        onRetry: {
                            Task { await resolveAndStore(index: index, force: true) }
                        },
                        onAutoRetry: {
                            Task { await resolveAndStore(index: index, force: true) }
                        }
                    )
                    .onAppear { ensurePageLoaded(index) }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: setupPhase)
        .animation(.easeInOut(duration: 0.35), value: pageLinks.isEmpty)
        .onChange(of: pageLinks.count) { _, _ in preloadAround(currentPage) }
        .task { await setup() }
    }

    // MARK: - Initial Loading

    private var initialLoadingView: some View {
        VStack(spacing: 24) {
            if let coverURL = gallery.thumbnailURL {
                GalleryCover(url: coverURL, cookieHeader: session.cookieHeader())
                    .frame(width: 130, height: 175)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .opacity(0.4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            }

            VStack(spacing: 12) {
                Text(gallery.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)

                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white.opacity(0.5))
                        .controlSize(.small)
                    Text("正在获取阅读目录…")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.orange.opacity(0.7))
            Text("无法加载在线页面")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            Text(message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            Button("重试") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    setupPhase = .fetching
                    loadError = nil
                }
                Task { await setup() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange.opacity(0.8))
        }
    }

    // MARK: - Setup

    private func setup() async {
        let cache = ImageURLCache.shared
        pageLinks = cache.pages(for: gallery)
        do {
            setupPhase = .fetching
            if pageLinks.isEmpty {
                let detail = try await SiteClient.shared.detail(gallery, cookieHeader: session.cookieHeader())
                pageLinks = detail.pageLinks
                cache.setPages(detail.pageLinks, gallery: gallery)
            }
            imageURLs = Dictionary(uniqueKeysWithValues: pageLinks.indices.compactMap { index in
                cache.image(for: gallery, at: index).map { (index, $0) }
            })
            if pageLinks.isEmpty {
                loadError = "未能从页面中提取图片目录。"
                setupPhase = .error
                return
            }
            nextBatch = max(1, (pageLinks.count + 19) / 20)
            withAnimation(.easeInOut(duration: 0.35)) {
                setupPhase = .ready
            }
        } catch {
            loadError = error.localizedDescription
            setupPhase = .error
        }
        let startPos = min(startIndex, max(0, pageLinks.count - 1))
        currentPage = startPos
        ensurePageLoaded(startPos)
        preloadAround(startPos)
    }

    // MARK: - Page Loading (Simple & Reliable)

    func ensurePageLoaded(_ index: Int) {
        guard pageLinks.indices.contains(index) else { return }
        if imageURLs[index] == nil {
            Task { await resolveAndStore(index: index) }
        }
    }

    func preloadAround(_ center: Int) {
        // Resolve URLs and download/decode the actual bitmaps ahead of time.
        // The visible reader then normally hits ImagePipeline.memory directly.
        for offset in 0...8 {
            let idx = center + offset
            if pageLinks.indices.contains(idx) {
                Task { await resolveAndStore(index: idx) }
            }
        }
        for offset in 1...2 {
            let idx = center - offset
            if pageLinks.indices.contains(idx) {
                Task { await resolveAndStore(index: idx) }
            }
        }
    }

    private func resolveAndStore(index: Int, force: Bool = false) async {
        guard pageLinks.indices.contains(index) else { return }
        guard force || !resolvingIndices.contains(index) else { return }
        if !force, imageURLs[index] != nil {
            await prefetchBitmap(index: index)
            return
        }
        await MainActor.run { resolvingIndices.insert(index) }
        defer { Task { @MainActor in resolvingIndices.remove(index) } }
        if force {
            ImageURLCache.shared.removeImage(for: gallery, at: index)
            await MainActor.run { imageURLs[index] = nil }
        }
        if !force, let cached = ImageURLCache.shared.image(for: gallery, at: index) {
            await MainActor.run { imageURLs[index] = cached }
            await prefetchBitmap(index: index)
            return
        }
        do {
            let page = pageLinks[index]
            let url = try await SiteClient.shared.imageURL(
                pageURL: page,
                cookieHeader: session.cookieHeader(),
                referer: gallery.sourceURL,
                forceReload: force
            )
            ImageURLCache.shared.setImage(url, gallery: gallery, index: index)
            await MainActor.run { imageURLs[index] = url }
            // Do not wait for the visible cell; download and decode now.
            await prefetchBitmap(index: index, url: url)
        } catch {
            guard !force else { return }
            await resolveAndStore(index: index, force: true)
        }
    }

    private func prefetchBitmap(index: Int, url: URL? = nil) async {
        let target = url ?? imageURLs[index]
        guard let target else { return }
        await ImagePipeline.shared.prefetch(
            url: target,
            cookieHeader: session.cookieHeader(),
            referer: nil
        )
    }

    // MARK: - More Pages

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
            let oldCount = pageLinks.count
            await MainActor.run {
                pageLinks.append(contentsOf: fresh)
                pageLinks.sort { pageNumber($0) < pageNumber($1) }
            }
            ImageURLCache.shared.appendPages(fresh, gallery: gallery)
            nextBatch += 1
            if pageLinks.count >= gallery.pageCount && gallery.pageCount > 0 { hasMorePages = false }
            await preloadAround(currentPage)
        } catch {
            hasMorePages = true
        }
    }

    private func pageNumber(_ url: URL) -> Int {
        let name = url.path.split(separator: "/").last.map(String.init) ?? ""
        guard let dash = name.lastIndex(of: "-") else { return Int.max }
        return Int(name[name.index(after: dash)...]) ?? Int.max
    }
}
