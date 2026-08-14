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
    @State private var lastLoadedPage = 0
    @State private var loadingPageIndices: Set<Int> = []
    @State private var refreshingPageLinks = false
    @State private var autoRetryWorkItems: [Int: Task<Void, Never>] = [:]
    @State private var setupPhase: SetupPhase = .fetching

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
                    lastLoadedPage = max(lastLoadedPage, index)
                    if index >= pageLinks.count - 3 {
                        Task { await loadMorePagesIfNeeded() }
                    }
                }, onPageAppear: { index in
                    lastLoadedPage = max(lastLoadedPage, index)
                    scheduleAutoRetryIfNeeded(for: index)
                    if index >= pageLinks.count - 3 {
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
                    .onAppear { scheduleAutoRetryIfNeeded(for: index) }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: setupPhase)
        .animation(.easeInOut(duration: 0.35), value: pageLinks.isEmpty)
        .onChange(of: pageLinks.count) { _, _ in refreshVisibleLoadSchedules() }
        .task { await setup() }
    }

    // MARK: - Initial Loading

    private var initialLoadingView: some View {
        VStack(spacing: 24) {
            // Gallery cover as faded backdrop context
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
            lastLoadedPage = max(0, pageLinks.count - 1)
            withAnimation(.easeInOut(duration: 0.35)) {
                setupPhase = .ready
            }
        } catch {
            loadError = error.localizedDescription
            setupPhase = .error
        }
        refreshVisibleLoadSchedules()
        // Preload first 3 pages
        for index in pageLinks.indices.prefix(3) where imageURLs[index] == nil {
            Task { await loadPage(index) }
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
            let existing = pageStates.count
            pageStates = Dictionary(uniqueKeysWithValues: pageLinks.indices.map { ($0, $0 < existing ? pageStates[$0] ?? .waiting : .waiting) })
            ImageURLCache.shared.appendPages(fresh, gallery: gallery)
            nextBatch += 1
            if pageLinks.count >= gallery.pageCount && gallery.pageCount > 0 { hasMorePages = false }
        } catch {
            hasMorePages = true
        }
    }

    private func pageNumber(_ url: URL) -> Int {
        let name = url.path.split(separator: "/").last.map(String.init) ?? ""
        guard let dash = name.lastIndex(of: "-") else { return Int.max }
        return Int(name[name.index(after: dash)...]) ?? Int.max
    }

    private func pageState(for index: Int) -> PageState {
        pageLinks.indices.contains(index) ? pageStates[index] ?? .waiting : .empty
    }

    private func setPageState(for index: Int, _ state: PageState) {
        pageStates[index] = state
        if state == .loading {
            autoRetryWorkItems[index]?.cancel()
            autoRetryWorkItems[index] = nil
        }
    }

    private func scheduleAutoRetryIfNeeded(for index: Int) {
        let state = pageState(for: index)
        guard state == .waiting || state == .failed || (state == .loading && imageURLs[index] == nil) else { return }
        let delay = state == .failed ? 1.5 : 0.1
        autoRetryWorkItems[index]?.cancel()
        autoRetryWorkItems[index] = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                let current = pageState(for: index)
                if current == .waiting || current == .failed || (current == .loading && imageURLs[index] == nil) {
                    setPageState(for: index, .loading)
                    Task { await loadPage(index, force: current == .failed) }
                }
            }
        }
    }

    private func refreshVisibleLoadSchedules() {
        pageLinks.indices.prefix(6).forEach { scheduleAutoRetryIfNeeded(for: $0) }
    }

    private func loadPage(_ index: Int, force: Bool = false) async {
        guard pageLinks.indices.contains(index), force || imageURLs[index] == nil else {
            if imageURLs[index] != nil { setPageState(for: index, .loaded) }
            return
        }
        setPageState(for: index, .loading)
        loadingPageIndices.insert(index)
        defer { loadingPageIndices.remove(index) }
        do {
            let resolved: URL
            if force {
                ImageURLCache.shared.removeImage(for: gallery, at: index)
                imageURLs[index] = nil
                resolved = try await resolveImageURL(index: index, refreshPage: true)
            } else if let cached = imageURLs[index] {
                resolved = cached
            } else {
                resolved = try await resolveImageURL(index: index, refreshPage: false)
            }
            imageURLs[index] = resolved
            setPageState(for: index, .loaded)
            ImageURLCache.shared.setImage(resolved, gallery: gallery, index: index)
            scheduleLoadAheadIfNeeded(after: index)
        } catch {
            setPageState(for: index, .failed)
            if force { await refreshPageLinksIfNeeded() }
            if imageURLs.isEmpty { loadError = error.localizedDescription }
        }
    }

    private func scheduleLoadAheadIfNeeded(after index: Int) {
        // Preload next 3 pages for smooth continuous reading
        for ahead in 1...3 {
            let next = index + ahead
            if pageLinks.indices.contains(next), imageURLs[next] == nil {
                scheduleAutoRetryIfNeeded(for: next)
            }
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

    private func refreshPageLinksIfNeeded() async {
        guard !refreshingPageLinks, let source = gallery.sourceURL else { return }
        refreshingPageLinks = true
        defer { refreshingPageLinks = false }
        do {
            let detail = try await SiteClient.shared.detail(gallery, cookieHeader: session.cookieHeader())
            guard !detail.pageLinks.isEmpty else { return }
            pageLinks = detail.pageLinks
            pageStates = Dictionary(uniqueKeysWithValues: detail.pageLinks.indices.map { ($0, .waiting) })
            ImageURLCache.shared.setPages(detail.pageLinks, gallery: gallery)
            refreshVisibleLoadSchedules()
        } catch { }
    }
}
