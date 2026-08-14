import Foundation

/// The server-side ranking periods exposed by E-Hentai's toplist endpoint.
enum RankingPeriod: String, CaseIterable, Identifiable, Hashable {
    case yesterday = "昨日"
    case month = "上月"
    case year = "去年"
    case allTime = "总榜"

    var id: String { rawValue }
    var endpointValue: String {
        switch self {
        case .yesterday: return "15"
        case .month: return "13"
        case .year: return "12"
        case .allTime: return "11"
        }
    }
    var icon: String {
        switch self {
        case .yesterday: return "calendar"
        case .month: return "calendar.badge.clock"
        case .year: return "chart.bar"
        case .allTime: return "trophy"
        }
    }
}

/// Loads and caches the site's toplists for the home preview and full list.
@MainActor
final class RankingStore: ObservableObject {
    @Published private(set) var yesterday: [Gallery] = []
    @Published private(set) var month: [Gallery] = []
    @Published private(set) var year: [Gallery] = []
    @Published private(set) var allTime: [Gallery] = []
    @Published private(set) var isLoading = false
    @Published private(set) var loadingMore: Set<RankingPeriod> = []
    @Published private(set) var error: String?

    private var nextPage: [RankingPeriod: Int?] = [:]
    private var hasMore: [RankingPeriod: Bool] = [:]
    private var loadedKey: String?
    private var currentSource: EHSource = .eHentai
    private var currentBaseURL: URL?
    private var currentCookieHeader: String?

    func galleries(for period: RankingPeriod) -> [Gallery] {
        switch period {
        case .yesterday: return yesterday
        case .month: return month
        case .year: return year
        case .allTime: return allTime
        }
    }

    func load(source: EHSource, baseURL: URL, cookieHeader: String?, force: Bool = false) async {
        let key = "\(source.rawValue)|\(baseURL.absoluteString)"
        if !force, loadedKey == key, !yesterday.isEmpty || !month.isEmpty { return }
        loadedKey = key
        currentSource = source
        currentBaseURL = baseURL
        currentCookieHeader = cookieHeader
        isLoading = true
        error = nil
        resetData()
        defer { isLoading = false }
        do {
            async let yesterdayPage = SiteClient.shared.toplistPage(period: .yesterday, source: source, baseURL: baseURL, cookieHeader: cookieHeader, page: 0)
            async let monthPage = SiteClient.shared.toplistPage(period: .month, source: source, baseURL: baseURL, cookieHeader: cookieHeader, page: 0)
            let y = try await yesterdayPage
            set(galleries: y.galleries, for: .yesterday)
            nextPage[.yesterday] = y.nextPage
            hasMore[.yesterday] = y.nextPage != nil
            let m = try await monthPage
            set(galleries: m.galleries, for: .month)
            nextPage[.month] = m.nextPage
            hasMore[.month] = m.nextPage != nil
        } catch {
            self.error = "排行榜加载失败：\(error.localizedDescription)"
        }
        isLoading = false
    }

    func loadPeriod(_ period: RankingPeriod) async {
        guard let baseURL = currentBaseURL, !isLoading else { return }
        if !galleries(for: period).isEmpty { return }
        isLoading = true
        error = nil
        do {
            let response = try await SiteClient.shared.toplistPage(period: period, source: currentSource, baseURL: baseURL, cookieHeader: currentCookieHeader, page: 0)
            set(galleries: response.galleries, for: period)
            nextPage[period] = response.nextPage
            hasMore[period] = response.nextPage != nil
        } catch {
            self.error = "\(period.rawValue)排行加载失败：\(error.localizedDescription)"
        }
        isLoading = false
    }

    func loadMore(_ period: RankingPeriod) async {
        guard !loadingMore.contains(period), hasMore[period] != false,
              let page = nextPage[period] ?? nil,
              let baseURL = currentBaseURL else { return }
        loadingMore.insert(period)
        defer { loadingMore.remove(period) }
        do {
            let response = try await SiteClient.shared.toplistPage(period: period, source: currentSource, baseURL: baseURL, cookieHeader: currentCookieHeader, page: page)
            let existing = Set(galleries(for: period).map(\.id))
            let fresh = response.galleries.filter { !existing.contains($0.id) }
            append(fresh, to: period)
            nextPage[period] = response.nextPage
            hasMore[period] = response.nextPage != nil && !fresh.isEmpty
        } catch {
            self.error = "\(period.rawValue)排行加载失败：\(error.localizedDescription)"
        }
    }

    func canLoadMore(_ period: RankingPeriod) -> Bool { hasMore[period] == true }

    private func resetData() {
        yesterday = []; month = []; year = []; allTime = []
        nextPage = [:]; hasMore = [:]
    }

    private func set(galleries: [Gallery], for period: RankingPeriod) {
        switch period {
        case .yesterday: yesterday = galleries
        case .month: month = galleries
        case .year: year = galleries
        case .allTime: allTime = galleries
        }
    }

    private func append(_ galleries: [Gallery], to period: RankingPeriod) {
        switch period {
        case .yesterday: yesterday.append(contentsOf: galleries)
        case .month: month.append(contentsOf: galleries)
        case .year: year.append(contentsOf: galleries)
        case .allTime: allTime.append(contentsOf: galleries)
        }
    }
}
