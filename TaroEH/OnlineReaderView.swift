import SwiftUI

struct OnlineReaderView: View {
    let gallery: Gallery
    var startIndex: Int = 0
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var reading: ReadingStore
    @State private var pageLinks: [URL] = []
    @State private var imageURLs: [Int: URL] = [:]
    @State private var pageStates: [Int: PageState] = [:]
    @State private var loadError: String?
    @State private var nextBatch = 1
    @State private var isLoadingMore = false
    @State private var hasMorePages = true
    @State private var refreshingPageLinks = false
    @State private var setupPhase: SetupPhase = .fetching
    @State private var currentPage = 0
    @State private var resolvedUpTo = -1
    @State private var isBatchResolving = false

    /// URL resolution batch size — how many pages to resolve URLs for at once.
    private let resolveBatchSize = 20
    /// How many pages ahead to ensure images are downloaded.
    private let imagePreloadAhead = 8

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
                    triggerBatchResolveIfNeeded(around: index)
                    if index >= pageLinks.count - 5 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }, onPageAppear: { index in
                    currentPage = index
                    ensurePageLoaded(index)
                    triggerBatchResolveIfNeeded(around: index)
                    if index >= pageLinks.count - 5 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }) { index, fit, scale in
                    ReaderPageImage(
                        url: imageURLs[index],
                        referer: pageLinks.indices.contains(index) ? pageLinks[index] : gallery.sourceURL,
                        pageNumber: index + 1,
                        status: pageState(for: index),
                        fit: fit,
                        scale: scale,
                        onRetry: {
                            setPageState(for: index, .loading)
                            Task { await loadPage(index, force: true) }
                        },
                        onAutoRetry: {
                            setPageState(for: index, .loading)
                            Task { await loadPage(index, force: false) }
                        }
                    )
                    .onAppear { ensurePageLoaded(index) }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: setupPhase)
        .animation(.easeInOut(duration: 0.35), value: pageLinks.isEmpty)
        .onChange(of: pageLinks.count) { _, _ in triggerBatchResolveIfNeeded(around: currentPage) }
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
        pageStates = Dictionary(uniqueKeysWithValues: pageLinks.indices.map { ($0, .waiting) })
        do {
            setupPhase = .fetching
            if pageLinks.isEmpty {
                let detail = try await SiteClient.shared.detail(gallery, cookieHeader: session.cookieHeader())
                pageLinks = detail.pageLinks
                pageStates = Dictionary(uniqueKeysWithValues: detail.pageLinks.indices.map { ($0, .waiting) })
                cache.setPages(detail.pageLinks, gallery: gallery)
            }
            imageURLs = Dictionary(uniqueKeysWithValues: pageLinks.indices.compactMap { index in cache.image(for: gallery, at: index).map { (index, $0) } })
            if pageLinks.isEmpty {
                loadError = "未能从页面中提取图片目录。"
                setupPhase = .error
                return
            }
            nextBatch = max(1, (pageLinks.count + 19) / 20)
            // Track which pages already have cached URLs
            resolvedUpTo = imageURLs.keys.max() ?? -1
            withAnimation(.easeInOut(duration: 0.35)) {
                setupPhase = .ready
            }
        } catch {
            loadError = error.localizedDescription
            setupPhase = .error
        }
        let startPos = min(startIndex, max(0, pageLinks.count - 1))
        currentPage = startPos
        // Immediately batch-resolve URLs for the first 20 pages
        triggerBatchResolveIfNeeded(around: startPos)
        ensurePageLoaded(startPos)
    }

    // MARK: - Batch URL Resolution (JHenTai-style parallel pipeline)

    /// Checks if we need to batch-resolve more URLs. Triggers when the current
    /// page is within `resolveBatchSize/2` pages of the last resolved URL.
    func triggerBatchResolveIfNeeded(around center: Int) {
        guard !isBatchResolving, pageLinks.indices.contains(center) else { return }
        // If current page is past the resolved boundary, we need more URLs
        let resolveThreshold = resolvedUpTo - resolveBatchSize / 2
        if center > resolveThreshold {
            let startIdx = max(0, resolvedUpTo + 1)
            let endIdx = min(pageLinks.count, startIdx + resolveBatchSize)
            guard startIdx < endIdx else { return }
            Task { await batchResolveURLs(startIdx..<endIdx) }
        }
    }

    /// Resolves image URLs for a range of pages IN PARALLEL using TaskGroup.
    /// This is the key optimization: 20 URLs resolve in ~3s (6 concurrent),
    /// vs 20s if done one-by-one.
    func batchResolveURLs(_ range: Range<Int>) async {
        guard !isBatchResolving else { return }
        isBatchResolving = true
        defer { isBatchResolving = false }

        let cookie = session.cookieHeader()
        let referer = gallery.sourceURL
        let pages = pageLinks

        // Mark all as loading
        await MainActor.run {
            for i in range {
                if pageStates[i] != .loaded { pageStates[i] = .loading }
            }
        }

        // Resolve URLs in parallel with TaskGroup (6 concurrent)
        await withTaskGroup(of: (Int, URL?).self) { group in
            var next = range.lowerBound
            func addNext() {
                guard next < range.upperBound, pages.indices.contains(next) else { return }
                let idx = next
                let pageURL = pages[idx]
                next += 1
                group.addTask {
                    do {
                        let url = try await SiteClient.shared.imageURL(pageURL: pageURL, cookieHeader: cookie, referer: referer)
                        return (idx, url)
                    } catch {
                        return (idx, nil)
                    }
                }
            }
            // Start 6 concurrent resolution tasks
            for _ in 0..<min(6, range.count) { addNext() }
            while let (idx, url) = await group.next() {
                if let url {
                    await MainActor.run {
                        imageURLs[idx] = url
                        pageStates[idx] = .loaded
                        ImageURLCache.shared.setImage(url, gallery: gallery, index: idx)
                    }
                } else {
                    await MainActor.run {
                        pageStates[idx] = .failed
                    }
                    // Retry failed page after 1.5s
                    Task { try? await Task.sleep(for: .seconds(1.5)); await loadPage(idx, force: false) }
                }
                addNext()
            }
        }

        await MainActor.run {
            resolvedUpTo = max(resolvedUpTo, range.upperBound - 1)
        }
    }

    // MARK: - Page Loading

    func ensurePageLoaded(_ index: Int) {
        guard pageLinks.indices.contains(index) else { return }
        if imageURLs[index] != nil {
            setPageState(for: index, .loaded)
            return
        }
        let state = pageState(for: index)
        if state == .waiting || state == .failed {
            startPageLoad(index, delay: 0)
        }
    }

    func startPageLoad(_ index: Int, delay: TimeInterval) {
        Task {
            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            await loadPage(index, force: false)
        }
    }

    private func loadPage(_ index: Int, force: Bool = false) async {
        guard pageLinks.indices.contains(index) else { return }
        if !force, imageURLs[index] != nil {
            await MainActor.run { setPageState(for: index, .loaded) }
            return
        }
        await MainActor.run { setPageState(for: index, .loading) }
        do {
            let resolved: URL
            if force {
                ImageURLCache.shared.removeImage(for: gallery, at: index)
                await MainActor.run { imageURLs[index] = nil }
                resolved = try await resolveImageURL(index: index, refreshPage: true)
            } else if let cached = imageURLs[index] {
                resolved = cached
            } else {
                resolved = try await resolveImageURL(index: index, refreshPage: false)
            }
            await MainActor.run {
                imageURLs[index] = resolved
                setPageState(for: index, .loaded)
                resolvedUpTo = max(resolvedUpTo, index)
            }
            ImageURLCache.shared.setImage(resolved, gallery: gallery, index: index)
        } catch {
            await MainActor.run { setPageState(for: index, .failed) }
            Task { try? await Task.sleep(for: .seconds(1.5)); await loadPage(index, force: false) }
        }
    }

    private func resolveImageURL(index: Int, refreshPage: Bool) async throws -> URL {
        guard pageLinks.indices.contains(index) else { throw SiteError.invalidResponse }
        let page = pageLinks[index]
        let detailURL = gallery.sourceURL
        do {
            return try await SiteClient.shared.imageURL(pageURL: page, cookieHeader: session.cookieHeader(), referer: detailURL, forceReload: refreshPage)
        } catch {
            guard !refreshPage else { throw error }
            return try await SiteClient.shared.imageURL(pageURL: page, cookieHeader: session.cookieHeader(), referer: detailURL, forceReload: true)
        }
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
                for i in oldCount..<pageLinks.count { pageStates[i] = .waiting }
            }
            ImageURLCache.shared.appendPages(fresh, gallery: gallery)
            nextBatch += 1
            if pageLinks.count >= gallery.pageCount && gallery.pageCount > 0 { hasMorePages = false }
            await MainActor.run { triggerBatchResolveIfNeeded(around: currentPage) }
        } catch {
            hasMorePages = true
        }
    }

    private func pageNumber(_ url: URL) -> Int {
        let name = url.path.split(separator: "/").last.map(String.init) ?? ""
        guard let dash = name.lastIndex(of: "-") else { return Int.max }
        return Int(name[name.index(after: dash)...]) ?? Int.max
    }

    // MARK: - State Helpers

    private func pageState(for index: Int) -> PageState {
        pageLinks.indices.contains(index) ? pageStates[index] ?? .waiting : .empty
    }

    private func setPageState(for index: Int, _ state: PageState) {
        pageStates[index] = state
    }

    private func refreshPageLinksIfNeeded() async {
        guard !refreshingPageLinks, let source = gallery.sourceURL else { return }
        refreshingPageLinks = true
        defer { refreshingPageLinks = false }
        do {
            let detail = try await SiteClient.shared.detail(gallery, cookieHeader: session.cookieHeader())
            guard !detail.pageLinks.isEmpty else { return }
            await MainActor.run {
                pageLinks = detail.pageLinks
                pageStates = Dictionary(uniqueKeysWithValues: detail.pageLinks.indices.map { ($0, .waiting) })
            }
            ImageURLCache.shared.setPages(detail.pageLinks, gallery: gallery)
            triggerBatchResolveIfNeeded(around: currentPage)
        } catch { }
    }
}
