import SwiftUI
import UIKit

actor ImagePipeline {
    static let shared = ImagePipeline()
    private let session: URLSession
    private let memory = NSCache<NSURL, UIImage>()
    private var inFlight: [URL: Task<UIImage, Error>] = [:]

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = .shared
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
        memory.countLimit = 100
        memory.totalCostLimit = 80 * 1024 * 1024
    }

    func image(for url: URL, cookieHeader: String? = nil) async throws -> UIImage {
        if let cached = memory.object(forKey: url as NSURL) { return cached }
        if let task = inFlight[url] { return try await task.value }
        let task = Task<UIImage, Error> {
            if url.isFileURL, let image = UIImage(contentsOfFile: url.path) { return image }
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            if let cookieHeader, !cookieHeader.isEmpty { request.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<400 ~= http.statusCode, let image = UIImage(data: data) else { throw SiteError.invalidResponse }
            return image
        }
        inFlight[url] = task
        defer { inFlight[url] = nil }
        let value = try await task.value
        memory.setObject(value, forKey: url as NSURL, cost: value.jpegData(compressionQuality: 0.75)?.count ?? 1)
        return value
    }

    func removeAllMemory() { memory.removeAllObjects() }
}

struct PipelineImage: View {
    let url: URL?
    var cookieHeader: String? = nil
    var contentMode: ContentMode = .fit
    var body: some View {
        Group {
            if let url {
                PipelineImageContent(url: url, cookieHeader: cookieHeader, contentMode: contentMode)
            } else { Color.clear }
        }
    }
}

private struct PipelineImageContent: View {
    let url: URL
    let cookieHeader: String?
    let contentMode: ContentMode
    @State private var image: UIImage?
    @State private var failed = false
    var body: some View {
        Group {
            if let image { Image(uiImage: image).resizable().aspectRatio(contentMode: contentMode) }
            else if failed { Image(systemName: "photo.badge.exclamationmark").foregroundStyle(.secondary) }
            else { ProgressView() }
        }
        .task(id: url) {
            do { image = try await ImagePipeline.shared.image(for: url, cookieHeader: cookieHeader) }
            catch { failed = true }
        }
    }
}
