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

    /// Chooses a random gallery cursor across the site's full gid range, then samples that server page.
    /// E-Hentai has no public one-gallery random endpoint; `next=<gid>` is its supported pagination cursor.
    func randomGallery(source: EHSource, baseURL: URL, cookieHeader: String?, excluding: Set<Int> = []) async throws -> Gallery? {
        let newest = try await frontPage(source: source, baseURL: baseURL, cookieHeader: cookieHeader)
            .map(\.id)
            .max() ?? 1

        for _ in 0..<4 {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "next", value: String(Int.random(in: 1...newest)))]
            guard let url = components?.url else { throw SiteError.invalidResponse }
            let data = try await request(url, cookieHeader: cookieHeader)
            guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
            let galleries = SiteParser.galleries(from: html, source: source, baseURL: baseURL)
            if let gallery = galleries.shuffled().first(where: { !excluding.contains($0.id) }) { return gallery }
            if let gallery = galleries.randomElement() { return gallery }
        }
        return nil
    }

    func detail(_ gallery: Gallery, cookieHeader: String?) async throws -> NetworkGalleryDetail {
        guard let url = gallery.sourceURL else { throw SiteError.invalidResponse }
        let data = try await request(url, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8) else { throw SiteError.parseFailed }
        return SiteParser.detail(from: html, sourceURL: url, fallback: gallery)
    }

    func imageURL(pageURL: URL, cookieHeader: String?) async throws -> URL {
        let data = try await request(pageURL, cookieHeader: cookieHeader)
        guard let html = String(data: data, encoding: .utf8), let image = SiteParser.imageURL(from: html) else { throw SiteError.parseFailed }
        return image
    }

    func imageURLs(for detail: NetworkGalleryDetail, cookieHeader: String?) async throws -> [URL] {
        var output: [URL] = []
        for page in detail.pageLinks { output.append(try await imageURL(pageURL: page, cookieHeader: cookieHeader)) }
        return output
    }
}
