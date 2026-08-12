import Foundation

/// Direct sandbox downloader. Uses system HTTPS validation and waits for connectivity.
actor DownloadService {
    static let shared = DownloadService()
    private let session: URLSession
    private init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.allowsCellularAccess = !UserDefaults.standard.bool(forKey: "taro.eh.wifiOnly")
        config.httpMaximumConnectionsPerHost = max(1, min(6, UserDefaults.standard.integer(forKey: "taro.eh.concurrent") == 0 ? 2 : UserDefaults.standard.integer(forKey: "taro.eh.concurrent")))
        session = URLSession(configuration: config)
    }
    func start(task: OfflineTask, onPage: @escaping @Sendable (Int) async -> Void, onFinish: @escaping @Sendable (Result<Void, Error>) async -> Void) {
        do {
            let folder = try folder(for: task.gallery)
            for (index, pageURL) in task.imageURLs.enumerated() {
                if Task.isCancelled { throw CancellationError() }
                let hint = pageURL.pathExtension.lowercased()
                let ext = ["jpg", "jpeg", "png", "webp"].contains(hint) ? hint : "jpg"
                let destination = folder.appendingPathComponent(String(format: "%04d.%@", index + 1, ext))
                if FileManager.default.fileExists(atPath: destination.path) { await onPage(index + 1); continue }
                let data = try await fetch(pageURL, attempts: 3)
                try data.write(to: destination, options: .atomic)
                await onPage(index + 1)
            }
            await onFinish(.success(()))
        } catch { await onFinish(.failure(error)) }
    }
    private func fetch(_ url: URL, attempts: Int) async throws -> Data {
        var last: Error?
        for attempt in 0..<attempts {
            if Task.isCancelled { throw CancellationError() }
            do {
                var request = URLRequest(url: url)
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
                if let cookieHeader = KeychainStore.read(key: "taro_eh_cookie"), !cookieHeader.isEmpty { request.setValue(cookieHeader, forHTTPHeaderField: "Cookie") }
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { throw URLError(.badServerResponse) }
                return data
            } catch { last = error; if attempt + 1 < attempts { try await Task.sleep(for: .seconds(Double(attempt + 1))) } }
        }
        throw last ?? URLError(.unknown)
    }
    private func folder(for gallery: Gallery) throws -> URL {
        guard let folder = OfflineLibrary.folder(for: gallery) else { throw URLError(.cannotCreateFile) }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}
