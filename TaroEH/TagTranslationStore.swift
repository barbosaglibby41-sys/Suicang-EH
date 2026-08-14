import Foundation
import Combine

struct TranslatedTag: Codable, Hashable, Identifiable {
    let namespace: String
    let key: String
    let name: String
    /// Optional short description from the upstream database (only newer builds have it).
    var intro: String?
    var id: String { "\(namespace):\(key)" }
}

struct TagDatabaseEnvelope: Codable {
    let version: Int
    let updatedAt: String
    /// Upstream Database commit SHA. Optional for bundled and legacy local databases.
    let revision: String?
    let tags: [TranslatedTag]
}

@MainActor
final class TagTranslationStore: ObservableObject {
    @Published private(set) var enabled: Bool
    @Published private(set) var translateChineseSearch = true
    @Published private(set) var fillMode = true
    @Published private(set) var displayMode: DisplayMode = .chineseOnly
    @Published private(set) var isUpdating = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var databaseVersion = 0
    @Published private(set) var updatedAt = ""
    @Published private(set) var tagCount = 0
    @Published private(set) var errorMessage: String?
    @Published private(set) var statusMessage: String?
    @Published private(set) var dataSource = "内置版本"

    private let enabledKey = "taro.eh.tags.enabled"
    private let chineseKey = "taro.eh.tags.translateChineseSearch"
    private let fillKey = "taro.eh.tags.fillMode"
    private let displayModeKey = "taro.eh.tags.displayMode"
    private let sourceKey = "taro.eh.tags.source"
    private let databaseFile = "tag_translation.json"
    private var tags: [TranslatedTag] = []
    private var byID: [String: TranslatedTag] = [:]
    private var byEnglish: [String: TranslatedTag] = [:]
    private var byChinese: [String: TranslatedTag] = [:]
    private var searchBuckets: [String: [TranslatedTag]] = [:]

    var bundledDatabaseVersion: Int { 7 }

    /// Mirrors are tried in order; GitHub raw is the primary source (real-time),
    /// jsDelivr CDNs are fallbacks (they may lag behind by a few hours).
    static let remoteSources: [URL] = [
        URL(string: "https://raw.githubusercontent.com/EhTagTranslation/DatabaseReleases/master/db.html.json")!,
        URL(string: "https://cdn.jsdelivr.net/gh/EhTagTranslation/DatabaseReleases/db.html.json")!,
        URL(string: "https://fastly.jsdelivr.net/gh/EhTagTranslation/DatabaseReleases/db.html.json")!
    ]

    init() {
        enabled = UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
        translateChineseSearch = UserDefaults.standard.object(forKey: chineseKey) as? Bool ?? true
        fillMode = UserDefaults.standard.object(forKey: fillKey) as? Bool ?? true
        displayMode = DisplayMode(rawValue: UserDefaults.standard.string(forKey: displayModeKey) ?? "") ?? .chineseOnly
        dataSource = UserDefaults.standard.string(forKey: sourceKey) ?? "内置版本"
        loadLocalOrSeed()
    }

    var isReady: Bool { !tags.isEmpty }

    /// How translated tag names are rendered in the UI.
    enum DisplayMode: String, CaseIterable, Codable, Identifiable {
        case chineseOnly = "仅中文"
        case bilingual = "中文 + 英文"
        case original = "仅英文"
        var id: String { rawValue }
    }

    /// Chinese label for a tag namespace, falling back to the raw namespace.
    static func namespaceName(_ namespace: String) -> String {
        switch namespace.lowercased() {
        case "female": return "女性"
        case "male": return "男性"
        case "mixed": return "混合"
        case "artist": return "作者"
        case "parody": return "原作"
        case "character": return "角色"
        case "group": return "团队"
        case "language": return "语言"
        case "reclass": return "重新分类"
        case "cosplayer": return "Coser"
        case "temp": return "临时"
        case "other": return "其他"
        case "location": return "地点"
        default: return namespace
        }
    }
    var formattedUpdatedAt: String {
        guard let date = ISO8601DateFormatter().date(from: updatedAt) else { return updatedAt.isEmpty ? "内置版本" : updatedAt }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    func setEnabled(_ value: Bool) { enabled = value; UserDefaults.standard.set(value, forKey: enabledKey) }
    func setTranslateChineseSearch(_ value: Bool) { translateChineseSearch = value; UserDefaults.standard.set(value, forKey: chineseKey) }
    func setFillMode(_ value: Bool) { fillMode = value; UserDefaults.standard.set(value, forKey: fillKey) }
    func setDisplayMode(_ value: DisplayMode) { displayMode = value; UserDefaults.standard.set(value.rawValue, forKey: displayModeKey) }

    func translatedTag(for raw: String) -> TranslatedTag? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = byID[value] { return exact }
        if let exact = byEnglish[value] { return exact }
        return tags.first { $0.key.lowercased() == value || $0.name.lowercased() == value }
    }

    func displayName(for raw: String) -> String {
        guard enabled, let tag = translatedTag(for: raw) else { return raw }
        switch displayMode {
        case .chineseOnly:
            return tag.name
        case .bilingual:
            return "\(tag.name) · \(tag.namespace):\(tag.key)"
        case .original:
            return tag.namespace.isEmpty ? tag.key : "\(tag.namespace):\(tag.key)"
        }
    }

    /// Converts Chinese terms to E-Hentai's English tag syntax while preserving ordinary words.
    func queryForSite(_ query: String) -> String {
        guard enabled && translateChineseSearch else { return query }
        return query.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).map { token in
            var original = String(token)
            if original.contains(":") || original.hasPrefix("-") || original.hasPrefix("~") {
                let prefix = original.first == "-" || original.first == "~" ? String(original.removeFirst()) : ""
                let pieces = original.split(separator: ":", maxSplits: 1).map(String.init)
                if pieces.count == 2, let tag = lookupChinese(pieces[1]) { return prefix + tag.namespace + ":\"" + tag.key + "$\"" }
                if let tag = lookupChinese(pieces.joined(separator: ":")) { return prefix + tag.namespace + ":\"" + tag.key + "$\"" }
            }
            if let tag = lookupChinese(original) { return "\(tag.namespace):\"\(tag.key)$\"" }
            return original
        }.joined(separator: fillMode ? " " : " ")
    }

    func currentToken(in query: String) -> String {
        guard let last = query.last, !last.isWhitespace else { return "" }
        return String(query.split(whereSeparator: { $0.isWhitespace }).last ?? "")
    }

    func replacingCurrentToken(in query: String, with tag: TranslatedTag) -> String {
        let token = currentToken(in: query)
        let replacement = "\(tag.namespace):\(tag.key) "
        guard !token.isEmpty else { return query + replacement }
        let end = query.index(query.endIndex, offsetBy: -token.count)
        let prefix = String(query[..<end])
        return prefix + replacement
    }

    func suggestions(for query: String, limit: Int = 30) -> [TranslatedTag] {
        let term = currentToken(in: query).lowercased()
        guard !term.isEmpty else { return [] }
        // Chinese users commonly search one character at a time (for example, "足").
        // Latin input still needs two characters to avoid noise.
        let containsCJK = term.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
        guard containsCJK || term.count >= 2 else { return [] }
        let initial = String(term.prefix(1))
        let candidates = searchBuckets[initial] ?? tags
        let scored: [(TranslatedTag, Int)] = candidates.map { ($0, score($0, term)) }
        let filtered = scored.filter { $0.1 > 0 }
        let sorted = filtered.sorted { $0.1 == $1.1 ? $0.0.name < $1.0.name : $0.1 > $1.1 }
        return sorted.prefix(limit).map { $0.0 }
    }

    func update() async {
        guard !isUpdating else { return }
        isUpdating = true; progress = 0; errorMessage = nil; statusMessage = "正在检查更新…"
        defer { isUpdating = false; progress = 1 }
        var lastError: Error?
        for source in Self.remoteSources {
            let host = source.host ?? "镜像源"
            do {
                var request = URLRequest(url: source)
                request.timeoutInterval = 25
                request.cachePolicy = .reloadIgnoringLocalCacheData
                request.setValue("TaroEH/1.7 (tag database updater)", forHTTPHeaderField: "User-Agent")
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { throw URLError(.badServerResponse) }
                let envelope = try decodeRemote(data)
                guard !envelope.tags.isEmpty else { throw URLError(.cannotDecodeContentData) }
                // Skip CDN mirrors whose cached copy is older than what we already have,
                // so a stale fallback can never downgrade the local database.
                if let localDate = Self.dateFormatter.date(from: updatedAt),
                   let remoteDate = Self.dateFormatter.date(from: envelope.updatedAt),
                   remoteDate < localDate {
                    lastError = URLError(.resourceUnavailable)
                    continue
                }
                if envelope.version == databaseVersion && envelope.updatedAt == updatedAt {
                    statusMessage = "当前已经是最新版本（\(host)）"
                    return
                }
                let canonical = try JSONEncoder().encode(envelope)
                try save(envelope, data: canonical)
                UserDefaults.standard.set("本地更新", forKey: sourceKey)
                dataSource = "本地更新"
                apply(envelope)
                statusMessage = "已更新到数据库版本 \(envelope.version)（来源：\(host)）"
                return
            } catch {
                lastError = error
            }
        }
        errorMessage = "无法从任何镜像源获取更新：\(lastError?.localizedDescription ?? "未知错误")。请检查网络后重试。"
        statusMessage = "继续使用当前数据"
    }

    func restoreBundled() {
        guard let url = Bundle.main.url(forResource: "tag_translation_seed", withExtension: "json"), let data = try? Data(contentsOf: url), let envelope = try? JSONDecoder().decode(TagDatabaseEnvelope.self, from: data) else { errorMessage = "内置数据库不可用"; return }
        try? save(envelope, data: data)
        UserDefaults.standard.set("内置版本", forKey: sourceKey)
        dataSource = "内置版本"
        errorMessage = nil
        statusMessage = "已恢复内置数据库版本 \(envelope.version)"
        apply(envelope)
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private func loadLocalOrSeed() {
        if let data = try? Data(contentsOf: localURL()), let envelope = try? JSONDecoder().decode(TagDatabaseEnvelope.self, from: data) { apply(envelope); return }
        restoreBundled()
    }
    private func localURL() -> URL { FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(databaseFile) }
    private func save(_ envelope: TagDatabaseEnvelope, data: Data) throws { let folder = localURL().deletingLastPathComponent(); try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true); try data.write(to: localURL(), options: .atomic) }
    private func apply(_ envelope: TagDatabaseEnvelope) {
        tags = envelope.tags
        byID = tags.reduce(into: [:]) { $0[$1.id.lowercased()] = $1 }
        byEnglish = tags.reduce(into: [:]) { if $0[$1.key.lowercased()] == nil { $0[$1.key.lowercased()] = $1 } }
        byChinese = tags.reduce(into: [:]) { if $0[$1.name.lowercased()] == nil { $0[$1.name.lowercased()] = $1 } }
        searchBuckets = [:]
        for tag in tags {
            let keys = Set([String(tag.key.lowercased().prefix(1)), String(tag.name.lowercased().prefix(1))])
            for key in keys where !key.isEmpty { searchBuckets[key, default: []].append(tag) }
        }
        databaseVersion = envelope.version; updatedAt = envelope.updatedAt; tagCount = tags.count
    }
    private func decodeRemote(_ data: Data) throws -> TagDatabaseEnvelope {
        let raw = try JSONDecoder().decode(RemoteEnvelope.self, from: data)
        let values = raw.data.flatMap { group in
            group.data.map { key, value in
                let name = Self.stripHTML(value.name)
                let intro = value.intro.map(Self.stripHTML)
                return TranslatedTag(namespace: group.namespace, key: key, name: name, intro: intro)
            }
        }
        return TagDatabaseEnvelope(version: raw.version, updatedAt: raw.head.committer.when, revision: raw.head.sha, tags: values)
    }
    private func lookupChinese(_ text: String) -> TranslatedTag? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = byChinese[t] { return exact }
        return tags.first { $0.name.lowercased().contains(t) }
    }
    private func score(_ tag: TranslatedTag, _ term: String) -> Int { let n = tag.name.lowercased(), k = tag.key.lowercased(); if n == term || k == term { return 100 }; if n.hasPrefix(term) || k.hasPrefix(term) { return 70 }; if n.contains(term) || k.contains(term) { return 30 }; return 0 }
    private static func stripHTML(_ input: String) -> String { input.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression).replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&#039;", with: "'").trimmingCharacters(in: .whitespacesAndNewlines) }
}

private struct RemoteEnvelope: Decodable {
    struct Head: Decodable {
        struct Committer: Decodable { let when: String }
        let sha: String?
        let committer: Committer
    }
    struct Group: Decodable {
        struct Value: Decodable {
            let name: String
            let intro: String?
        }
        let namespace: String
        let data: [String: Value]
    }
    let version: Int
    let head: Head
    let data: [Group]
}
