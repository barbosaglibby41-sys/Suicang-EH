import Foundation

/// Stores only URLs and timestamps, never cookies or image bytes.
struct ImageURLCacheEntry: Codable { var pageLinks: [URL]; var imageURLs: [Int: URL]; var updatedAt: Date }
@MainActor final class ImageURLCache: ObservableObject {
    static let shared = ImageURLCache(); private var entries: [String: ImageURLCacheEntry] = [:]
    private let key = "taro.eh.image-url-cache.v2"; private let lifetime: TimeInterval = 86_400
    private init() {
        if let data = UserDefaults.standard.data(forKey: key), let value = try? JSONDecoder().decode([String: ImageURLCacheEntry].self, from: data) { entries = value; removeExpired() }
    }
    func pages(for gallery: Gallery) -> [URL] { valid(gallery.stableKey)?.pageLinks ?? [] }
    func image(for gallery: Gallery, at index: Int) -> URL? { valid(gallery.stableKey)?.imageURLs[index] }
    func setPages(_ links: [URL], gallery: Gallery) { var v = entries[gallery.stableKey] ?? ImageURLCacheEntry(pageLinks: [], imageURLs: [:], updatedAt: .now); v.pageLinks = links; v.updatedAt = .now; entries[gallery.stableKey] = v; save() }
    func setImage(_ url: URL, gallery: Gallery, index: Int) { var v = entries[gallery.stableKey] ?? ImageURLCacheEntry(pageLinks: [], imageURLs: [:], updatedAt: .now); v.imageURLs[index] = url; v.updatedAt = .now; entries[gallery.stableKey] = v; save() }
    func clear(gallery: Gallery) { entries.removeValue(forKey: gallery.stableKey); save() }
    func clearAll() { entries = [:]; save() }
    func removeExpired() { entries = entries.filter { Date.now.timeIntervalSince($0.value.updatedAt) < lifetime }; save() }
    var count: Int { entries.count }
    private func valid(_ key: String) -> ImageURLCacheEntry? { guard let v = entries[key], Date.now.timeIntervalSince(v.updatedAt) < lifetime else { entries.removeValue(forKey: key); save(); return nil }; return v }
    private func save() { if let data = try? JSONEncoder().encode(entries) { UserDefaults.standard.set(data, forKey: key) } }
}
