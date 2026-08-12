import Foundation

@MainActor
final class DiscoveryStore: ObservableObject {
    @Published private(set) var recentQueries: [String] = []
    @Published private(set) var subscribedTags: [String] = []
    private let queryKey = "taro.eh.recent-searches.v1"
    private let tagKey = "taro.eh.subscribed-tags.v1"
    init() {
        recentQueries = UserDefaults.standard.stringArray(forKey: queryKey) ?? []
        subscribedTags = UserDefaults.standard.stringArray(forKey: tagKey) ?? []
    }
    func record(query: String) {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        recentQueries.removeAll { $0.caseInsensitiveCompare(value) == .orderedSame }
        recentQueries.insert(value, at: 0); recentQueries = Array(recentQueries.prefix(12)); saveQueries()
    }
    func removeQuery(_ query: String) { recentQueries.removeAll { $0 == query }; saveQueries() }
    func clearQueries() { recentQueries = []; saveQueries() }
    func toggleTag(_ tag: String) {
        if let index = subscribedTags.firstIndex(of: tag) { subscribedTags.remove(at: index) }
        else { subscribedTags.append(tag) }
        UserDefaults.standard.set(subscribedTags, forKey: tagKey)
    }
    func isSubscribed(_ tag: String) -> Bool { subscribedTags.contains(tag) }
    private func saveQueries() { UserDefaults.standard.set(recentQueries, forKey: queryKey) }
}
