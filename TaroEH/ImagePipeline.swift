import SwiftUI
import UIKit

actor ImagePipeline {
    static let shared = ImagePipeline()
    private let session: URLSession
    private let memory = NSCache<NSURL, UIImage>()
    private var inFlight: [URL: Task<UIImage, Error>] = [:]
    private var activeRequests = 0
    private let maxConcurrentRequests = 3

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = .shared
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 45
        config.httpMaximumConnectionsPerHost = 4
        session = URLSession(configuration: config)
        memory.countLimit = 100
        memory.totalCostLimit = 80 * 1024 * 1024
    }

    func image(for url: URL, cookieHeader: String? = nil) async throws -> UIImage {
        if let cached = memory.object(forKey: url as NSURL) { return cached }
        if let task = inFlight[url] { return try await task.value }
        let task = Task<UIImage, Error> {
            while await self.canStartRequest() == false {
                try await Task.sleep(for: .milliseconds(40))
            }
            await self.beginRequest()
            defer { Task { await self.endRequest() } }
            if url.isFileURL {
                let data = try Data(contentsOf: url, options: [.mappedIfSafe])
                guard let image = UIImage(data: data) else { throw SiteError.parseFailed }
                return image
            }
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

    private func canStartRequest() -> Bool { activeRequests < maxConcurrentRequests }
    private func beginRequest() { activeRequests += 1 }
    private func endRequest() { activeRequests = max(0, activeRequests - 1) }

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
            do {
                var lastError: Error?
                for attempt in 0..<3 {
                    do {
                        if attempt > 0 { try await Task.sleep(for: .milliseconds(350 * attempt)) }
                        image = try await ImagePipeline.shared.image(for: url, cookieHeader: cookieHeader)
                        lastError = nil
                        break
                    } catch { lastError = error }
                }
                if image == nil, lastError != nil { failed = true }
            } catch { failed = true }
        }
    }
}

/// A cover image whose loaded bitmap is constrained to its caller's fixed viewport.
struct GalleryCover: View {
    let url: URL?
    var cookieHeader: String? = nil
    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.secondary.opacity(0.14)
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else if failed {
                    Image(systemName: "photo.badge.exclamationmark").foregroundStyle(.secondary)
                } else {
                    ProgressView()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .task(id: url) {
            image = nil
            failed = false
            guard let url else { return }
            do { image = try await ImagePipeline.shared.image(for: url, cookieHeader: cookieHeader) }
            catch { failed = true }
        }
    }
}
