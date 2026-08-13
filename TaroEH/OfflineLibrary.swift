import Foundation

enum OfflineLibrary {
    // Directory listings are cached briefly so repeated lookups (detail view
    // onAppear, reader button availability, offline reader) don't rescan
    // thousands of files on the main thread. Invalidated on download/delete.
    private static let cacheTTL: TimeInterval = 30
    private static var pageURLCache: [String: (urls: [URL], date: Date)] = [:]
    private static let lock = NSLock()

    static func folder(for gallery: Gallery) -> URL? {
        guard let root = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
        return root.appendingPathComponent("Offline", isDirectory: true).appendingPathComponent(directoryName(for: gallery), isDirectory: true)
    }
    static func pageURLs(for gallery: Gallery) -> [URL] {
        let key = gallery.stableKey
        lock.lock(); defer { lock.unlock() }
        if let cached = pageURLCache[key], Date().timeIntervalSince(cached.date) < cacheTTL {
            return cached.urls
        }
        let urls = computePageURLs(for: gallery)
        pageURLCache[key] = (urls, Date())
        return urls
    }
    static func hasCompleteCopy(_ gallery: Gallery) -> Bool { pageURLs(for: gallery).count >= gallery.pageCount }
    static func size(for gallery: Gallery) -> Int64 { pageURLs(for: gallery).reduce(0) { $0 + ((try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0) } }
    static func totalSize() -> Int64 {
        guard let root = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false), let enumerator = FileManager.default.enumerator(at: root.appendingPathComponent("Offline"), includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        return enumerator.compactMap { item -> Int64? in
            guard let url = item as? URL, let value = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return nil }
            return Int64(value)
        }.reduce(0, +)
    }
    static func formatted(_ bytes: Int64) -> String { ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file) }
    static func delete(_ gallery: Gallery) {
        invalidateCache(for: gallery)
        [folder(for: gallery), legacyFolder(for: gallery)].compactMap { $0 }.forEach { try? FileManager.default.removeItem(at: $0) }
    }
    /// Drops the cached listing after a download finishes or files change.
    static func invalidateCache(for gallery: Gallery) {
        lock.lock(); pageURLCache.removeValue(forKey: gallery.stableKey); lock.unlock()
    }
    static func directoryName(for gallery: Gallery) -> String { gallery.stableKey.replacingOccurrences(of: ":", with: "_") }

    private static func computePageURLs(for gallery: Gallery) -> [URL] {
        let folders = [folder(for: gallery), legacyFolder(for: gallery)].compactMap { $0 }
        for folder in folders {
            if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                let pages = files.filter { ["jpg", "jpeg", "png", "webp"].contains($0.pathExtension.lowercased()) }.sorted {
                    let left = naturalPageNumber($0)
                    let right = naturalPageNumber($1)
                    return left == right ? $0.lastPathComponent < $1.lastPathComponent : left < right
                }
                if !pages.isEmpty { return pages }
            }
        }
        return []
    }

    /// Numeric-aware ordering keeps 1, 2, 10 instead of lexical 1, 10, 2.
    private static func naturalPageNumber(_ url: URL) -> Int {
        let digits = url.deletingPathExtension().lastPathComponent
            .split(whereSeparator: { !$0.isNumber })
            .last
        return digits.flatMap { Int($0) } ?? Int.max
    }
    private static func legacyFolder(for gallery: Gallery) -> URL? { guard let root = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }; return root.appendingPathComponent("Offline", isDirectory: true).appendingPathComponent(String(gallery.id), isDirectory: true) }
}
