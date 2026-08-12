import Foundation
import SwiftData

@MainActor
final class LibraryStore: ObservableObject {
    @Published private(set) var favorites: [Gallery] = []
    @Published private(set) var history: [Gallery] = []
    private var context: ModelContext?
    private var configured = false
    private let favoritesKey = "taro.eh.favorites"
    private let historyKey = "taro.eh.history"

    init() { loadLegacy() }

    func configure(_ context: ModelContext) {
        guard !configured else { return }
        self.context = context; configured = true
        let descriptor = FetchDescriptor<GalleryRecord>(sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)])
        let records = (try? context.fetch(descriptor)) ?? []
        if records.isEmpty {
            migrateLegacy()
        } else {
            favorites = records.filter { $0.isFavorite }.compactMap { $0.gallery() }
            history = records.filter { $0.lastOpenedAt != nil }.sorted { ($0.lastOpenedAt ?? .distantPast) > ($1.lastOpenedAt ?? .distantPast) }.compactMap { $0.gallery() }
        }
    }

    func isFavorite(_ gallery: Gallery) -> Bool { favorites.contains { $0.stableKey == gallery.stableKey } }
    func toggleFavorite(_ gallery: Gallery) {
        if let i = favorites.firstIndex(where: { $0.stableKey == gallery.stableKey }) { favorites.remove(at: i) }
        else { favorites.insert(gallery, at: 0) }
        upsert(gallery, isFavorite: isFavorite(gallery), lastOpenedAt: nil); saveLegacyFallback()
    }
    func record(_ gallery: Gallery) {
        history.removeAll { $0.stableKey == gallery.stableKey }; history.insert(gallery, at: 0); history = Array(history.prefix(100))
        upsert(gallery, isFavorite: isFavorite(gallery), lastOpenedAt: .now); saveLegacyFallback()
    }
    func clearHistory() { history = []; if let context { let records = (try? context.fetch(FetchDescriptor<GalleryRecord>())) ?? []; records.forEach { $0.lastOpenedAt = nil }; try? context.save() }; saveLegacyFallback() }

    private func upsert(_ gallery: Gallery, isFavorite: Bool, lastOpenedAt: Date?) {
        guard let context else { return }
        let key = gallery.stableKey
        var descriptor = FetchDescriptor<GalleryRecord>(predicate: #Predicate { $0.recordKey == key })
        descriptor.fetchLimit = 1
        if let records = try? context.fetch(descriptor), let record = records.first {
            record.update(from: gallery); record.isFavorite = isFavorite; if let lastOpenedAt { record.lastOpenedAt = lastOpenedAt }
        } else { context.insert(GalleryRecord(gallery: gallery, isFavorite: isFavorite, lastOpenedAt: lastOpenedAt)) }
        try? context.save()
    }
    private func migrateLegacy() {
        favorites.forEach { upsert($0, isFavorite: true, lastOpenedAt: nil) }
        history.forEach { upsert($0, isFavorite: isFavorite($0), lastOpenedAt: .now) }
    }
    private func loadLegacy() {
        if let d = UserDefaults.standard.data(forKey: favoritesKey), let a = try? JSONDecoder().decode([Gallery].self, from: d) { favorites = a }
        if let d = UserDefaults.standard.data(forKey: historyKey), let a = try? JSONDecoder().decode([Gallery].self, from: d) { history = a }
    }
    private func saveLegacyFallback() {
        if let a = try? JSONEncoder().encode(favorites) { UserDefaults.standard.set(a, forKey: favoritesKey) }
        if let a = try? JSONEncoder().encode(history) { UserDefaults.standard.set(a, forKey: historyKey) }
    }
}
