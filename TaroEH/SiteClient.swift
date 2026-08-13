import Foundation

/// Direct HTTPS client. Uses system certificate validation and never routes through a relay.
final class SiteClient {
    static let shared = SiteClient()
    private let session: URLSession
    private static let detailCacheTTL: TimeInterval = 300
    private let detailLock = NSLock()
    private var detailCache: [String: (gallery: Gallery, date: Date)] = [:]
    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = .shared
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.timeoutIntervalForRequest = 25
        session = URLSession(configuration: config)
    }

    func request(_ url: URL, cookieHeader: String?) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile", forHTTPHeaderField: "User-Agent")
        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
        if let cookieHeader, !cookieHeader.isEmpty { request.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SiteError.invalidResponse }
        if http.statusCode == 401 || http.statusCode == 403 { throw SiteError.accessDenied }
        guard 200..<400 ~= http.statusCode else { throw SiteError.invalidResponse }
        return data
    }

    func search(config: AdvancedSearchConfig, cookieHeader: String?, baseURL: URL, source: EHSource? = nil, translatedQuery: String? = nil) async throws -> [Gallery] {
        try await searchPage(config: config, cookieHeader: cookieHeader, baseURL: baseURL, source: source, translatedQuery: translatedQuery).galleries
    }

    func searchPage(config: AdvancedSearchConfig, cookieHeader: String?, baseURL: URL, source: EHSource? = nil, translatedQuery: String? = nil, cursor: Int? = nil) async throws -> (galleries: [Gallery], nextCursor: Int?) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let raw = ([config.keyword] + config.tags).filter { !$0.isEmpty }.joined(separator: " ")
        var items = [URLQueryItem(name: "f_search", value: translatedQuery ?? raw)]
        if let cursor { items.append(URLQueryItem(name: "next", value: String(cursor))) }
        components?.queryItems = items
        guard let url = components?.url else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        let resolvedSource = source ?? (baseURL.host?.contains("exhentai") == true ? .exHentai : .eHentai)
        return SiteParser.galleriesPage(from: html, source: resolvedSource, baseURL: baseURL)
    }

    func frontPage(source: EHSource, baseURL: URL, cookieHeader: String?, mode: String = "") async throws -> [Gallery] {
        let url = mode.isEmpty ? baseURL : baseURL.appendingPathComponent(mode)
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return SiteParser.galleries(from: html, source: source, baseURL: baseURL)
    }

    /// Loads one latest/popular feed page. Latest uses the site's `next` cursor;
    /// popular currently exposes one complete fixed collection and returns nil.
    func discoveryPage(source: EHSource, baseURL: URL, cookieHeader: String?, mode: String = "", cursor: Int? = nil, query: String? = nil) async throws -> (galleries: [Gallery], nextCursor: Int?) {
        var components = URLComponents(url: mode.isEmpty ? baseURL : baseURL.appendingPathComponent(mode), resolvingAgainstBaseURL: false)
        var items: [URLQueryItem] = []
        if let query, !query.isEmpty { items.append(URLQueryItem(name: "f_search", value: query)) }
        if let cursor { items.append(URLQueryItem(name: "next", value: String(cursor))) }
        components?.queryItems = items.isEmpty ? nil : items
        guard let url = components?.url else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return SiteParser.galleriesPage(from: html, source: source, baseURL: baseURL)
    }

    /// Samples fresh server pages using E-Hentai's supported `next=<gid>` cursor.
    /// It returns a unique random feed batch rather than reordering the currently visible list.
    func randomGalleries(source: EHSource, baseURL: URL, cookieHeader: String?, count: Int = 25, excluding: Set<Int> = []) async throws -> [Gallery] {
        let newest = try await frontPage(source: source, baseURL: baseURL, cookieHeader: cookieHeader)
            .map(\.id)
            .max() ?? 1
        var output: [Gallery] = []
        var seen = excluding
        var attempts = 0
        let perPage = max(1, Int(ceil(Double(count) / 3.0)))

        while output.count < count && attempts < 8 {
            attempts += 1
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "next", value: String(Int.random(in: 1...newest)))]
            guard let url = components?.url else { throw SiteError.invalidResponse }
            let data = try await request(url, cookieHeader: cookieHeader)
            guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
            var accepted = 0
            for gallery in SiteParser.galleries(from: html, source: source, baseURL: baseURL).shuffled() where seen.insert(gallery.id).inserted {
                output.append(gallery)
                accepted += 1
                if output.count == count || accepted == perPage { break }
            }
        }
        return output
    }

    func detail(_ gallery: Gallery, cookieHeader: String?) async throws -> NetworkGalleryDetail {
        guard let url = gallery.sourceURL else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return SiteParser.detail(from: html, sourceURL: url, fallback: gallery)
    }

    /// Lightweight detail fetch for the details screen: parses metadata, tags
    /// and comments but skips the (potentially thousands of) page links, so
    /// long galleries open without the parsing stall. Results are cached for
    /// a few minutes so re-opening a gallery from the shelf is instant.
    func detailMetadata(_ gallery: Gallery, cookieHeader: String?) async throws -> Gallery {
        let key = gallery.stableKey
        detailLock.lock()
        if let cached = detailCache[key], Date().timeIntervalSince(cached.date) < Self.detailCacheTTL {
            detailLock.unlock()
            return cached.gallery
        }
        detailLock.unlock()
        guard let url = gallery.sourceURL else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        let resolved = SiteParser.detail(from: html, sourceURL: url, fallback: gallery, includePageLinks: false).gallery
        detailLock.lock()
        detailCache[key] = (resolved, Date())
        detailLock.unlock()
        return resolved
    }

    /// Drops the cached detail after a comment post so the list refreshes.
    func invalidateDetailCache(for gallery: Gallery) {
        detailLock.lock()
        detailCache.removeValue(forKey: gallery.stableKey)
        detailLock.unlock()
    }

    /// Fetches the torrent popup and extracts the direct .torrent URL.
    func torrentURL(for gallery: Gallery, cookieHeader: String?) async throws -> URL? {
        guard let source = gallery.sourceURL,
              let components = URLComponents(url: source, resolvingAgainstBaseURL: false),
              let gid = components.path.split(separator: "/").dropFirst().first,
              let token = components.path.split(separator: "/").dropFirst().dropFirst().first else { return nil }
        var popup = URLComponents(url: source, resolvingAgainstBaseURL: false)
        popup?.path = "/gallerytorrents.php"
        popup?.queryItems = [URLQueryItem(name: "gid", value: String(gid)), URLQueryItem(name: "t", value: String(token))]
        guard let url = popup?.url else { return nil }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { return nil }
        return SiteParser.torrentURL(from: html)
    }
    func imageURL(pageURL: URL, cookieHeader: String?) async throws -> URL {
        let data = try await request(pageURL, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8), let image = SiteParser.imageURL(from: html) else { throw SiteError.parseFailed }
        return image
    }

    func imageURLs(for detail: NetworkGalleryDetail, cookieHeader: String?) async throws -> [URL] {
        let pages = detail.pageLinks
        var output = Array<URL?>(repeating: nil, count: pages.count)
        try await withThrowingTaskGroup(of: (Int, URL).self) { group in
            var next = 0
            func addNext() {
                guard next < pages.count else { return }
                let index = next; next += 1
                let page = pages[index]
                group.addTask { (index, try await self.imageURL(pageURL: page, cookieHeader: cookieHeader)) }
            }
            for _ in 0..<min(6, pages.count) { addNext() }
            while let (index, url) = try await group.next() {
                output[index] = url
                addNext()
            }
        }
        return output.compactMap { $0 }
    }

    /// Posts a new comment to the gallery. Returns the re-fetched detail page
    /// so the caller can refresh the comment list.
    func postComment(gallery: Gallery, content: String, cookieHeader: String?) async throws -> NetworkGalleryDetail {
        guard let url = gallery.sourceURL else { throw SiteError.invalidResponse }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else { throw SiteError.commentTooShort }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile", forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let cookieHeader, !cookieHeader.isEmpty { request.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "commenttext_new", value: trimmed),
            URLQueryItem(name: "comment_submit_new", value: "Post")
        ]
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SiteError.invalidResponse }
        guard http.statusCode == 302 || (200..<300 ~= http.statusCode) else { throw SiteError.invalidResponse }
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        let result = SiteParser.detail(from: html, sourceURL: url, fallback: gallery)
        detailLock.lock()
        detailCache[gallery.stableKey] = (result.gallery, Date())
        detailLock.unlock()
        return result
    }
}
