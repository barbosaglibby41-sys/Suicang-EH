import Foundation

/// Stores only URLs and timestamps, never cookies or image bytes.
struct ImageURLCacheEntry: Codable { var pageLinks: [URL]; var imageURLs: [Int: URL]; var updatedAt: Date }
@MainActor final class ImageURLCache: ObservableObject {
    static let shared = ImageURLCache(); private var entries: [String: ImageURLCacheEntry] = [:]
    private let key = "taro.eh.image-url-cache.v4"; private let lifetime: TimeInterval = 86_400
    private init() {
        if let data = UserDefaults.standard.data(forKey: key), let value = try? JSONDecoder().decode([String: ImageURLCacheEntry].self, from: data) { entries = value; removeExpired() }
    }
    func pages(for gallery: Gallery) -> [URL] { valid(gallery.stableKey)?.pageLinks ?? [] }
    func image(for gallery: Gallery, at index: Int) -> URL? { valid(gallery.stableKey)?.imageURLs[index] }
    func appendPages(_ links: [URL], gallery: Gallery) {
        guard !links.isEmpty else { return }
        var v = entries[gallery.stableKey] ?? ImageURLCacheEntry(pageLinks: [], imageURLs: [:], updatedAt: .now)
        let existing = Set(v.pageLinks.map(\.absoluteString))
        v.pageLinks.append(contentsOf: links.filter { !existing.contains($0.absoluteString) })
        v.pageLinks.sort { pageNumber($0) < pageNumber($1) }
        v.updatedAt = .now
        entries[gallery.stableKey] = v
        save()
    }

    private func pageNumber(_ url: URL) -> Int {
        let name = url.path.split(separator: "/").last.map(String.init) ?? ""
        guard let dash = name.lastIndex(of: "-") else { return Int.max }
        return Int(name[name.index(after: dash)...]) ?? Int.max
    }
    func setPages(_ links: [URL], gallery: Gallery) {
        entries[gallery.stableKey] = ImageURLCacheEntry(pageLinks: links, imageURLs: entries[gallery.stableKey]?.imageURLs ?? [:], updatedAt: .now)
        save()
    }

    func setImage(_ url: URL, gallery: Gallery, index: Int) {
        var v = entries[gallery.stableKey] ?? ImageURLCacheEntry(pageLinks: [], imageURLs: [:], updatedAt: .now)
        v.imageURLs[index] = url
        v.updatedAt = .now
        entries[gallery.stableKey] = v
        save()
    }

    func clear(gallery: Gallery) { entries.removeValue(forKey: gallery.stableKey); save() }
    func clearAll() { entries = [:]; save() }
    func removeExpired() { entries = entries.filter { Date.now.timeIntervalSince($0.value.updatedAt) < lifetime }; save() }
    var count: Int { entries.count }
    private func valid(_ key: String) -> ImageURLCacheEntry? { guard let v = entries[key], Date.now.timeIntervalSince(v.updatedAt) < lifetime else { entries.removeValue(forKey: key); save(); return nil }; return v }
    private func save() { if let data = try? JSONEncoder().encode(entries) { UserDefaults.standard.set(data, forKey: key) } }
}
