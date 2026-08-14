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
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 25
        config.httpMaximumConnectionsPerHost = 10
        session = URLSession(configuration: config)
    }

    func request(_ url: URL, cookieHeader: String?, referer: URL? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        applyHeaders(to: &request, cookieHeader: cookieHeader, referer: referer)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SiteError.invalidResponse }
        if http.statusCode == 401 || http.statusCode == 403 { throw SiteError.accessDenied }
        guard 200..<400 ~= http.statusCode else { throw SiteError.invalidResponse }
        return data
    }

    private func applyHeaders(to request: inout URLRequest, cookieHeader: String?, referer: URL?) {
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
        if let referer { request.setValue(referer.absoluteString, forHTTPHeaderField: "Referer") }
        if let cookieHeader, !cookieHeader.isEmpty { request.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
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
    /// The cursor is drawn from three ranges (recent / middle / older) so the
    /// feed doesn't bias too heavily toward only the newest uploads.
    func randomGalleries(source: EHSource, baseURL: URL, cookieHeader: String?, count: Int = 25, excluding: Set<Int> = []) async throws -> [Gallery] {
        let newest = try await frontPage(source: source, baseURL: baseURL, cookieHeader: cookieHeader)
            .map(\.id)
            .max() ?? 1
        var output: [Gallery] = []
        var seen = excluding
        var usedCursors = Set<Int>()
        var attempts = 0
        let perPage = max(1, Int(ceil(Double(count) / 3.0)))

        while output.count < count && attempts < 12 {
            attempts += 1
            let cursor = randomCursor(maxID: newest, excluding: usedCursors)
            usedCursors.insert(cursor)
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "next", value: String(cursor))]
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

    /// Generates a cursor from recent / middle / old ranges with weighted odds.
    private func randomCursor(maxID: Int, excluding: Set<Int>) -> Int {
        guard maxID > 1 else { return 1 }
        let ranges = [
            (weight: 0.45, lower: Int(Double(maxID) * 0.67), upper: maxID),
            (weight: 0.35, lower: Int(Double(maxID) * 0.34), upper: Int(Double(maxID) * 0.66)),
            (weight: 0.20, lower: 1, upper: max(1, Int(Double(maxID) * 0.33)))
        ]
        for _ in 0..<20 {
            let roll = Double.random(in: 0...1)
            let chosen = roll < ranges[0].weight ? ranges[0] : roll < ranges[0].weight + ranges[1].weight ? ranges[1] : ranges[2]
            let cursor = Int.random(in: min(chosen.lower, chosen.upper)...max(chosen.lower, chosen.upper))
            if !excluding.contains(cursor) { return cursor }
        }
        return Int.random(in: 1...maxID)
    }

    /// Loads one toplist page. E-Hentai uses tl=15 yesterday, 13 month,
    /// 12 year and 11 all-time; each page contains up to 50 galleries.
    func toplistPage(period: RankingPeriod, source: EHSource, baseURL: URL, cookieHeader: String?, page: Int = 0) async throws -> (galleries: [Gallery], nextPage: Int?) {
        let endpoint = period.endpointValue
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = "/toplist.php"
        components?.queryItems = [
            URLQueryItem(name: "tl", value: endpoint),
            URLQueryItem(name: "p", value: String(page))
        ]
        guard let url = components?.url else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        let galleries = SiteParser.galleries(from: html, source: source, baseURL: baseURL)
        let next = SiteParser.toplistNextPage(from: html, currentPage: page)
        return (galleries, next)
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
    func imageURL(pageURL: URL, cookieHeader: String?, referer: URL? = nil, forceReload: Bool = false) async throws -> URL {
        var target = pageURL
        if forceReload {
            var components = URLComponents(url: pageURL, resolvingAgainstBaseURL: false)
            var items = components?.queryItems ?? []
            items.removeAll { $0.name == "nl" }
            items.append(URLQueryItem(name: "nl", value: "\(Int(Date().timeIntervalSince1970 * 1000))"))
            components?.queryItems = items
            target = components?.url ?? pageURL
        }
        let data = try await request(target, cookieHeader: cookieHeader, referer: referer)
        guard let html = String(data: data, encoding: .utf8), let image = SiteParser.imageURL(from: html) else { throw SiteError.parseFailed }
        return image
    }

    private func request(_ request: URLRequest, cookieHeader: String?) async throws -> Data {
        var r = request
        r.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile", forHTTPHeaderField: "User-Agent")
        r.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
        if let cookieHeader, !cookieHeader.isEmpty { r.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
        let (data, response) = try await session.data(for: r)
        guard let http = response as? HTTPURLResponse else { throw SiteError.invalidResponse }
        if http.statusCode == 401 || http.statusCode == 403 { throw SiteError.accessDenied }
        guard 200..<400 ~= http.statusCode else { throw SiteError.invalidResponse }
        return data
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
            while let (index, url) = try await group.next() { output[index] = url; addNext() }
        }
        return output.compactMap { $0 }
    }

    func validateAccount(source: EHSource, cookieHeader: String?) async throws -> AccountValidationResult {
        let data = try await request(source.baseURL, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        let authenticated = SiteParser.isAuthenticatedAccountPage(html)
        let username = SiteParser.accountUsername(from: html)
        return AccountValidationResult(authenticated: authenticated, username: username, site: source, message: authenticated ? "\(source.title) 会话有效" : "\(source.title) 拒绝了当前会话")
    }

    func refreshExHentaiCookie(cookieHeader: String?) async throws -> String? {
        var request = URLRequest(url: EHSource.exHentai.baseURL)
        applyHeaders(to: &request, cookieHeader: cookieHeader, referer: EHSource.eHentai.baseURL)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<400 ~= http.statusCode else { throw SiteError.accessDenied }
        var values = cookieHeader?.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        if let fields = http.allHeaderFields as? [String: String], let setCookie = fields.first(where: { $0.key.lowercased() == "set-cookie" })?.value {
            for cookie in setCookie.split(separator: ",") {
                let pair = cookie.split(separator: ";", maxSplits: 1).first.map(String.init) ?? ""
                if pair.lowercased().hasPrefix("igneous=") {
                    values.removeAll { $0.lowercased().hasPrefix("igneous=") }
                    values.append(pair)
                }
            }
        }
        guard let html = String(data: data, encoding: .utf8), SiteParser.isAuthenticatedAccountPage(html) else { return nil }
        return values.joined(separator: "; ")
    }
    func cloudFavorites(source: EHSource, category: Int, cookieHeader: String?) async throws -> CloudFavoritePage {
        var components = URLComponents(url: source.baseURL.appendingPathComponent("favorites.php"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "favcat", value: String(category))]
        guard let url = components.url else { throw SiteError.invalidResponse }
        return try await cloudFavorites(url: url, source: source, cookieHeader: cookieHeader)
    }

    func cloudFavorites(url: URL, source: EHSource, cookieHeader: String?) async throws -> CloudFavoritePage {
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return CloudFavoritesParser.page(from: html, source: source, baseURL: source.baseURL)
    }

    func setCloudFavorite(gallery: Gallery, category: Int, cookieHeader: String?) async throws {
        guard let detailURL = gallery.sourceURL else { throw SiteError.invalidResponse }
        let tokenFromURL = detailURL.path.split(separator: "/").dropFirst().dropFirst().first.map(String.init)
        let token: String
        if let tokenFromURL, !tokenFromURL.isEmpty {
            token = tokenFromURL
        } else {
            let data = try await request(detailURL, cookieHeader: cookieHeader)
            guard let html = String(data: data, encoding: .utf8), let parsed = SiteParser.favoriteToken(from: html) else { throw SiteError.parseFailed }
            token = parsed
        }
        var components = URLComponents(url: gallery.source.baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/gallerypopups.php"
        components.queryItems = [URLQueryItem(name: "gid", value: String(gallery.id)), URLQueryItem(name: "t", value: token), URLQueryItem(name: "act", value: "addfav")]
        guard let url = components.url else { throw SiteError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(detailURL.absoluteString, forHTTPHeaderField: "Referer")
        let favoriteCategory = category == -1 ? "favdel" : String(max(0, min(9, category)))
        let apply = category == -1 ? "Apply Changes" : "Add to Favorites"
        let form = URLComponents(queryItems: [
            URLQueryItem(name: "favcat", value: favoriteCategory),
            URLQueryItem(name: "favnote", value: ""),
            URLQueryItem(name: "apply", value: apply),
            URLQueryItem(name: "update", value: "1")
        ]).percentEncodedQuery ?? ""
        request.httpBody = form.data(using: .utf8)
        applyHeaders(to: &request, cookieHeader: cookieHeader, referer: detailURL)
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<400 ~= http.statusCode else { throw SiteError.invalidResponse }
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
