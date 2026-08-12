import Foundation

enum OfflineLibrary {
    static func folder(for gallery: Gallery) -> URL? {
        guard let root = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
        return root.appendingPathComponent("Offline", isDirectory: true).appendingPathComponent(directoryName(for: gallery), isDirectory: true)
    }
    static func pageURLs(for gallery: Gallery) -> [URL] {
        let folders = [folder(for: gallery), legacyFolder(for: gallery)].compactMap { $0 }
        for folder in folders {
            if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                let pages = files.filter { ["jpg", "jpeg", "png", "webp"].contains($0.pathExtension.lowercased()) }.sorted { $0.lastPathComponent < $1.lastPathComponent }
                if !pages.isEmpty { return pages }
            }
        }
        return []
    }
    static func hasCompleteCopy(_ gallery: Gallery) -> Bool { pageURLs(for: gallery).count >= gallery.pageCount }
    static func size(for gallery: Gallery) -> Int64 { pageURLs(for: gallery).reduce(0) { $0 + ((try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0) } }
    static func totalSize() -> Int64 { guard let root = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false), let e = FileManager.default.enumerator(at: root.appendingPathComponent("Offline"), includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }; return e.compactMap { ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey]).fileSize }.reduce(0) { $0 + Int64($1) } }
    static func formatted(_ bytes: Int64) -> String { ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file) }
    static func delete(_ gallery: Gallery) { [folder(for: gallery), legacyFolder(for: gallery)].compactMap { $0 }.forEach { try? FileManager.default.removeItem(at: $0) } }
    static func directoryName(for gallery: Gallery) -> String { gallery.stableKey.replacingOccurrences(of: ":", with: "_") }
    private static func legacyFolder(for gallery: Gallery) -> URL? { guard let root = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }; return root.appendingPathComponent("Offline", isDirectory: true).appendingPathComponent(String(gallery.id), isDirectory: true) }
}
