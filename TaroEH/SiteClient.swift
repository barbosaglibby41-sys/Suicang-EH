import Foundation

/// Direct HTTPS client. Uses system certificate validation and never routes through a relay.
final class SiteClient {
    static let shared = SiteClient()
    private let session: URLSession
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
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let raw = ([config.keyword] + config.tags).filter { !$0.isEmpty }.joined(separator: " ")
        components?.queryItems = raw.isEmpty && translatedQuery == nil ? [] : [URLQueryItem(name: "f_search", value: translatedQuery ?? raw)]
        guard let url = components?.url else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        let resolvedSource = source ?? (baseURL.host?.contains("exhentai") == true ? .exHentai : .eHentai)
        return SiteParser.galleries(from: html, source: resolvedSource, baseURL: baseURL)
    }

    func frontPage(source: EHSource, baseURL: URL, cookieHeader: String?, mode: String = "") async throws -> [Gallery] {
        let url = mode.isEmpty ? baseURL : baseURL.appendingPathComponent(mode)
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return SiteParser.galleries(from: html, source: source, baseURL: baseURL)
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
    /// long galleries open without the parsing stall.
    func detailMetadata(_ gallery: Gallery, cookieHeader: String?) async throws -> Gallery {
        guard let url = gallery.sourceURL else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return SiteParser.detail(from: html, sourceURL: url, fallback: gallery, includePageLinks: false).gallery
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
        return SiteParser.detail(from: html, sourceURL: url, fallback: gallery)
    }
}
