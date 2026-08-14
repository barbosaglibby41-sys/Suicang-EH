import SwiftUI
import UIKit
import ImageIO

actor ImagePipeline {
    static let shared = ImagePipeline()
    private let session: URLSession
    private let memory = NSCache<NSString, UIImage>()
    private var inFlight: [String: Task<UIImage, Error>] = [:]
    private var activeRequests = 0
    private let maxConcurrentRequests = 10

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = .shared
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpMaximumConnectionsPerHost = 10
        session = URLSession(configuration: config)
        memory.countLimit = 180
        memory.totalCostLimit = 120 * 1024 * 1024
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil, queue: nil
        ) { [weak memory] _ in
            memory?.removeAllObjects()
        }
    }

    func image(for url: URL, cookieHeader: String? = nil, referer: URL? = nil) async throws -> UIImage {
        let cacheKey = url.absoluteString + "\n" + (referer?.absoluteString ?? "")
        let nsKey = cacheKey as NSString
        if let cached = memory.object(forKey: nsKey) { return cached }
        if let task = inFlight[cacheKey] { return try await task.value }
        let task = Task<UIImage, Error> {
            while await self.canStartRequest() == false {
                try await Task.sleep(for: .milliseconds(20))
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
            request.setValue("image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
            if let cookieHeader, !cookieHeader.isEmpty { request.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
            if let referer { request.setValue(referer.absoluteString, forHTTPHeaderField: "Referer") }
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<400 ~= http.statusCode else { throw SiteError.invalidResponse }
            guard let contentType = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type"),
                  contentType.lowercased().contains("image") else {
                throw SiteError.imageDataInvalid
            }
            guard let image = UIImage(data: data) else { throw SiteError.imageDataInvalid }
            let maxDim: CGFloat = 1200
            let scale = min(maxDim / image.size.width, maxDim / image.size.height, 1)
            if scale < 1 {
                let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
                return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
            }
            return image
        }
        inFlight[cacheKey] = task
        defer { inFlight[cacheKey] = nil }
        let value = try await task.value
        let cost = value.jpegData(compressionQuality: 0.6)?.count ?? 1
        memory.setObject(value, forKey: nsKey, cost: cost)
        return value
    }

    private func canStartRequest() -> Bool { activeRequests < maxConcurrentRequests }
    private func beginRequest() { activeRequests += 1 }
    private func endRequest() { activeRequests = max(0, activeRequests - 1) }

    func removeAllMemory() { memory.removeAllObjects() }

    /// Starts an image request and stores the decoded bitmap in the memory cache.
    /// The in-flight table deduplicates this with the reader's visible request.
    func prefetch(url: URL, cookieHeader: String? = nil, referer: URL? = nil) async {
        _ = try? await image(for: url, cookieHeader: cookieHeader, referer: referer)
    }
}

// Static placeholder keeps scrolling cheap; the reader's actual bitmap
// prefetch is responsible for perceived loading smoothness.
struct ShimmerView: View {
    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.1))
    }
}

// MARK: - Pipeline Image

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
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if failed {
                Image(systemName: "photo.badge.exclamationmark")
                    .foregroundStyle(.secondary)
            } else {
                ShimmerView()
            }
        }
        .task(id: url) {
            do {
                var lastError: Error?
                for attempt in 0..<3 {
                    do {
                        if attempt > 0 { try await Task.sleep(for: .milliseconds(300 * attempt)) }
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
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else if failed {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(.secondary)
                } else {
                    ShimmerView()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .task(id: url) {
            image = nil
            failed = false
            guard let url else { return }
            do {
                image = try await ImagePipeline.shared.image(for: url, cookieHeader: cookieHeader)
            } catch { failed = true }
        }
    }
}
