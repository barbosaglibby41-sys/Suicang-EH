import SwiftUI
import UIKit

extension Notification.Name {
    static let taroSearchTag = Notification.Name("taro.eh.searchTag")
}

private struct DiscoverSearchDestination: Hashable {
    let query: String
}

struct ContentView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.modelContext) private var modelContext
    @StateObject private var library = LibraryStore()
    @State private var path = NavigationPath()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                DiscoverView()
                    .navigationDestination(for: Gallery.self) { GalleryDetailView(gallery: $0) }
                    .navigationDestination(for: DiscoverSearchDestination.self) { destination in
                        DiscoverView(initialQuery: destination.query, autoSearch: true)
                    }
            }.tabItem { Label("发现", systemImage: "sparkles") }.tag(0)
            NavigationStack { ShelfView() }.tabItem { Label("书架", systemImage: "books.vertical") }.tag(1)
            NavigationStack { DownloadsView() }.tabItem { Label("离线", systemImage: "arrow.down.circle") }.tag(2)
            NavigationStack { SettingsView() }.tabItem { Label("设置", systemImage: "gear") }.tag(3)
        }
        .environmentObject(session)
        .environmentObject(library)
        .tint(.purple)
        .onReceive(NotificationCenter.default.publisher(for: .taroSearchTag)) { notification in
            guard let raw = notification.userInfo?["tag"] as? String, !raw.isEmpty else { return }
            // From the shelf, reset any stale discovery path first. From a
            // discovery detail, keep that path so Back returns to the detail.
            if selectedTab != 0 { path = NavigationPath() }
            selectedTab = 0
            path.append(DiscoverSearchDestination(query: raw))
        }
        .task { library.configure(modelContext) }
    }
}

private enum DiscoverFeed: String, CaseIterable, Identifiable {
    case latest = "最新"
    case popular = "热门"
    case random = "随机画廊"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .latest: return "clock.arrow.circlepath"
        case .popular: return "flame"
        case .random: return "shuffle"
        }
    }
}

struct DiscoverView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var discovery: DiscoveryStore
    @EnvironmentObject private var tagTranslations: TagTranslationStore
    @EnvironmentObject private var rankings: RankingStore
    @AppStorage("taro.eh.siteURL") private var siteAddress = "https://e-hentai.org/"
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    @State private var query = ""
    @State private var results: [Gallery] = []
    @State private var selectedFeed: DiscoverFeed = .latest
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var isRandomFeed = false
    @State private var isSearchResults = false
    @State private var nextDiscoveryCursor: Int?
    @State private var discoveryExhausted = false
    @State private var feedGeneration = 0
    @State private var networkError: String?
    @State private var showFilters = false
    @State private var showAllRankings = false
    @State private var sort: GallerySort = .recent
    @State private var randomOrder: [Int] = []
    @State private var advanced = AdvancedSearchConfig()
    @FocusState private var searchFocused: Bool
    private let initialQuery: String?
    private let autoSearch: Bool
    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 12, alignment: .top),
        GridItem(.flexible(minimum: 0), spacing: 12, alignment: .top)
    ]

    init(initialQuery: String? = nil, autoSearch: Bool = false) {
        self.initialQuery = initialQuery
        self.autoSearch = autoSearch
        _query = State(initialValue: initialQuery ?? "")
    }

    private var currentSource: EHSource { EHSource(rawValue: sourceRaw) ?? .eHentai }
    private var filtered: [Gallery] {
        var config = advanced
        if isSearchResults {
            config.keyword = ""
            config.tags = []
        } else {
            config.keyword = query
        }
        let matched = results.filter { config.matches($0) }
        // Random feed preserves the server-provided random order and does not
        // participate in the result sorting menu.
        guard selectedFeed != .random else { return matched }
        switch sort {
        case .recent: return matched
        case .popular: return matched.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .random:
            let order = randomOrder.isEmpty ? matched.map(\.id).shuffled() : randomOrder
            let byID = Dictionary(uniqueKeysWithValues: matched.map { ($0.id, $0) })
            return order.compactMap { byID[$0] } + matched.filter { !order.contains($0.id) }
        case .pages: return matched.sorted { $0.pageCount > $1.pageCount }
        case .title: return matched.sorted { $0.title < $1.title }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("芋头 E 站").font(.largeTitle.bold())
                        Text("E-Hentai / ExHentai · 中文标签搜索").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "person.crop.circle").font(.title)
                }
                HStack {
                    feedSelector
                    if isRandomFeed {
                        Button { selectFeed(.random) } label: {
                            Image(systemName: "arrow.clockwise")
                                .frame(width: 42, height: 42)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("换一批随机画廊")
                    }
                    Button { showFilters = true } label: {
                        Image(systemName: "slider.horizontal.3")
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("筛选排序")
                }
                searchBar
                suggestions
                if let networkError { Label(networkError, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange) }
                recentQueries
                if !isSearchResults {
                    HomeRankingsSection(showAll: $showAllRankings)
                }
                HStack {
                    if autoSearch {
                        Button { dismissSearchDestination() } label: {
                            Label("返回详情", systemImage: "chevron.left").font(.subheadline)
                        }
                    }
                    Text(isSearchResults ? "搜索结果" : selectedFeed.rawValue).font(.title3.bold())
                    Spacer()
                    if !isRandomFeed {
                        Menu {
                            ForEach(GallerySort.allCases) { option in
                                Button {
                                    sort = option
                                    if option == .random { randomOrder = results.map(\.id).shuffled() }
                                    else { randomOrder = [] }
                                } label: {
                                    Label(option.rawValue, systemImage: option.icon)
                                }
                            }
                        } label: {
                            Label(sort.rawValue, systemImage: "arrow.up.arrow.down").font(.caption.weight(.semibold))
                        }.buttonStyle(.bordered).controlSize(.small)
                    }
                    Text("\(filtered.count) 项").foregroundStyle(.secondary).font(.caption)
                }
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView().controlSize(.large)
                        Text("正在搜索网络…").font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 180)
                } else if filtered.isEmpty {
                    ContentUnavailableView("暂无画廊", systemImage: "rectangle.stack", description: Text("下拉刷新或使用搜索查找作品。"))
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filtered) { gallery in
                            NavigationLink(value: gallery) { GalleryCard(gallery: gallery) }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if gallery.id == filtered.last?.id {
                                        if isRandomFeed { loadMoreRandomGalleries() }
                                        else if selectedFeed == .latest || selectedFeed == .popular || isSearchResults { loadMoreDiscovery() }
                                    }
                                }
                        }
                    }
                    if isRandomFeed {
                        randomFeedFooter
                    } else if (selectedFeed == .latest || selectedFeed == .popular || isSearchResults) && !discoveryExhausted {
                        HStack { Spacer(); if isLoadingMore { ProgressView("正在加载更多…") } else { Text("继续下滑加载更多").font(.caption).foregroundStyle(.secondary) }; Spacer() }.padding(.vertical, 18)
                    }
                }
            }.padding()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFilters) { FilterView(sort: $sort, config: $advanced) }
        .sheet(isPresented: $showAllRankings) { RankingListView() }
        .task {
            if autoSearch, !(initialQuery ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                onlineSearch()
            } else {
                loadFrontPage()
            }
            // Rankings load independently so the main gallery feed is never blocked.
            if let base = URL(string: siteAddress) {
                Task { await rankings.load(source: currentSource, baseURL: base, cookieHeader: session.cookieHeader()) }
            }
        }
        .refreshable {
            await refreshFrontPage()
        }
        .onChange(of: sourceRaw) { _, _ in
            results = []
            loadFrontPage()
            reloadRankings()
        }
        .onChange(of: siteAddress) { _, _ in
            results = []
            loadFrontPage()
            reloadRankings()
        }
    }

    private func dismissSearchDestination() {
        dismiss()
    }

    private var feedSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DiscoverFeed.allCases) { feed in
                    Button {
                        selectFeed(feed)
                    } label: {
                        Label(feed.rawValue, systemImage: feed.icon)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 13)
                            .frame(height: 42)
                            .background(selectedFeed == feed ? Color.purple : Color.secondary.opacity(0.15), in: Capsule())
                            .foregroundStyle(selectedFeed == feed ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(feed.rawValue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var randomFeedFooter: some View {
        HStack {
            Spacer()
            if isLoadingMore { ProgressView("正在获取更多随机画廊…") }
            else { Text("继续下滑以加载更多随机画廊").font(.caption).foregroundStyle(.secondary) }
            Spacer()
        }
        .padding(.vertical, 18)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("搜索标题、作者或标签", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($searchFocused)
                .onSubmit { searchFocused = false; onlineSearch() }
            if isLoading { ProgressView().controlSize(.small) }
            else if !query.isEmpty {
                Button { query = ""; results = []; isSearchResults = false; searchFocused = true; loadFrontPage() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }.accessibilityLabel("清空搜索")
                Button { searchFocused = false; onlineSearch() } label: { Image(systemName: "arrow.right.circle.fill").foregroundStyle(.purple) }.accessibilityLabel("执行搜索")
            }
        }.padding(13).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder private var suggestions: some View {
        let values = tagTranslations.enabled ? tagTranslations.suggestions(for: query) : []
        if searchFocused && !values.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Label("标签建议", systemImage: "tag").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text("点击直接搜索").font(.caption2).foregroundStyle(.secondary)
                }.padding(.bottom, 8)
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(values) { tag in
                            Button { searchSuggestion(tag) } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass").foregroundStyle(.purple)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(tag.namespace):\(tag.key)").font(.subheadline).lineLimit(1)
                                        Text("\(TagTranslationStore.namespaceName(tag.namespace)) · \(tag.name)").font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                    }
                                    Spacer(minLength: 20)
                                    Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 360)
            }.padding(12).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func searchSuggestion(_ tag: TranslatedTag) {
        query = tagTranslations.replacingCurrentToken(in: query, with: tag)
        searchFocused = true
        // Filling a suggestion intentionally does not start network search;
        // users can append more tags and submit the complete query afterward.
    }

    @ViewBuilder private var recentQueries: some View {
        if !discovery.recentQueries.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack { Label("最近搜索", systemImage: "clock.arrow.circlepath").font(.caption).foregroundStyle(.secondary); Spacer(); Button("清除全部") { discovery.clearQueries() }.font(.caption).foregroundStyle(.purple) }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { ForEach(discovery.recentQueries, id: \.self) { item in Button { query = item; searchFocused = false; onlineSearch() } label: { Text(item).font(.caption).lineLimit(1).padding(.horizontal, 11).padding(.vertical, 8).background(.purple.opacity(0.18), in: Capsule()) } } }
                }
            }
        }
    }

    private func reloadRankings() {
        guard let base = URL(string: siteAddress) else { return }
        Task { await rankings.load(source: currentSource, baseURL: base, cookieHeader: session.cookieHeader(), force: true) }
    }

    private func loadFrontPage() {
        guard results.isEmpty else { return }
        selectFeed(.latest)
    }


    private func refreshFrontPage() async {
        guard let base = URL(string: siteAddress) else { return }
        feedGeneration += 1
        let generation = feedGeneration
        let source = currentSource
        let cookieHeader = session.cookieHeader()
        isLoading = true
        networkError = nil
        do {
            let page = try await SiteClient.shared.discoveryPage(source: source, baseURL: base, cookieHeader: cookieHeader)
            guard generation == feedGeneration else { return }
            results = page.galleries
            selectedFeed = .latest
            isSearchResults = false
            isRandomFeed = false
            nextDiscoveryCursor = page.nextCursor
            discoveryExhausted = page.nextCursor == nil
        } catch {
            guard generation == feedGeneration else { return }
            networkError = "刷新失败：\(error.localizedDescription)"
        }
        if generation == feedGeneration { isLoading = false }
        Task { await rankings.load(source: source, baseURL: base, cookieHeader: cookieHeader, force: true) }
    }
    private func selectFeed(_ feed: DiscoverFeed) {
        guard let base = URL(string: siteAddress) else { return }
        feedGeneration += 1
        let generation = feedGeneration
        let source = currentSource
        let cookieHeader = session.cookieHeader()
        selectedFeed = feed
        isSearchResults = false
        isRandomFeed = feed == .random
        nextDiscoveryCursor = nil
        discoveryExhausted = false
        isLoading = true
        isLoadingMore = false
        networkError = nil
        query = ""

        Task {
            do {
                let galleries: [Gallery]
                switch feed {
                case .latest:
                    let page = try await SiteClient.shared.discoveryPage(source: source, baseURL: base, cookieHeader: cookieHeader)
                    galleries = page.galleries
                    nextDiscoveryCursor = page.nextCursor
                    discoveryExhausted = page.nextCursor == nil
                case .popular:
                    let page = try await SiteClient.shared.discoveryPage(source: source, baseURL: base, cookieHeader: cookieHeader, mode: "popular")
                    galleries = page.galleries
                    nextDiscoveryCursor = page.nextCursor
                    discoveryExhausted = page.nextCursor == nil
                case .random:
                    galleries = try await SiteClient.shared.randomGalleries(source: source, baseURL: base, cookieHeader: cookieHeader, count: 25)
                    discoveryExhausted = false
                }
                guard generation == feedGeneration else { return }
                results = galleries
                if galleries.isEmpty { networkError = "站点没有返回可用画廊。" }
            } catch {
                guard generation == feedGeneration else { return }
                networkError = "\(feed.rawValue)加载失败：\(error.localizedDescription)"
            }
            guard generation == feedGeneration else { return }
            isLoading = false
        }
    }

    private func loadMoreDiscovery() {
        guard !isLoading, !isLoadingMore, !discoveryExhausted, let base = URL(string: siteAddress) else { return }
        isLoadingMore = true
        let generation = feedGeneration
        let source = currentSource
        let cookieHeader = session.cookieHeader()
        let cursor = nextDiscoveryCursor
        let mode = selectedFeed == .popular ? "popular" : ""
        let searchQuery = isSearchResults ? tagTranslations.queryForSite(([query] + advanced.tags).filter { !$0.isEmpty }.joined(separator: " ")) : nil
        Task {
            defer { isLoadingMore = false }
            do {
                let page: (galleries: [Gallery], nextCursor: Int?)
                if let searchQuery {
                    var config = advanced
                    config.keyword = query
                    page = try await SiteClient.shared.searchPage(config: config, cookieHeader: cookieHeader, baseURL: base, source: source, translatedQuery: searchQuery, cursor: cursor)
                } else {
                    page = try await SiteClient.shared.discoveryPage(source: source, baseURL: base, cookieHeader: cookieHeader, mode: mode, cursor: cursor)
                }
                guard generation == feedGeneration else { return }
                let known = Set(results.map(\.id))
                let fresh = page.galleries.filter { !known.contains($0.id) }
                if fresh.isEmpty || page.nextCursor == cursor {
                    discoveryExhausted = true
                    return
                }
                results.append(contentsOf: fresh)
                nextDiscoveryCursor = page.nextCursor
                discoveryExhausted = page.nextCursor == nil
            } catch {
                guard generation == feedGeneration else { return }
                networkError = "更多\(isSearchResults ? "搜索结果" : selectedFeed.rawValue)加载失败：\(error.localizedDescription)"
                // Keep the footer available for retry.
            }
        }
    }

    private func loadMoreRandomGalleries() {
        guard selectedFeed == .random, !isLoading, !isLoadingMore, let base = URL(string: siteAddress) else { return }
        isLoadingMore = true
        let generation = feedGeneration
        let source = currentSource
        let cookieHeader = session.cookieHeader()
        let existingIDs = Set(results.map(\.id))
        Task {
            do {
                let galleries = try await SiteClient.shared.randomGalleries(source: source, baseURL: base, cookieHeader: cookieHeader, count: 25, excluding: existingIDs)
                guard generation == feedGeneration, selectedFeed == .random else { return }
                results.append(contentsOf: galleries)
            } catch {
                guard generation == feedGeneration, selectedFeed == .random else { return }
                networkError = "更多随机画廊加载失败：\(error.localizedDescription)"
            }
            guard generation == feedGeneration else { return }
            isLoadingMore = false
        }
    }
    private func onlineSearch() {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty, let base = URL(string: siteAddress) else { return }
        feedGeneration += 1
        let generation = feedGeneration
        let source = currentSource
        let cookieHeader = session.cookieHeader()
        let translated = tagTranslations.queryForSite(([term] + advanced.tags).filter { !$0.isEmpty }.joined(separator: " "))
        isSearchResults = true
        isRandomFeed = false
        isLoading = true
        isLoadingMore = false
        networkError = nil
        var config = advanced
        config.keyword = term
        Task {
            do {
                let foundPage = try await SiteClient.shared.searchPage(config: config, cookieHeader: cookieHeader, baseURL: base, source: source, translatedQuery: translated)
                guard generation == feedGeneration else { return }
                discovery.record(query: term)
                results = foundPage.galleries
                nextDiscoveryCursor = foundPage.nextCursor
                discoveryExhausted = foundPage.nextCursor == nil
                withAnimation(.easeOut(duration: 0.2)) { isLoading = false }
                if foundPage.galleries.isEmpty { networkError = "没有匹配结果，或站点页面结构发生变化。" }
            } catch {
                guard generation == feedGeneration else { return }
                networkError = "无法完成直连搜索：\(error.localizedDescription)"
            }
            guard generation == feedGeneration else { return }
            isLoading = false
        }
    }
}

enum GallerySort: String, CaseIterable, Identifiable {
    case recent = "最新", popular = "热门", random = "随机", pages = "页数最多", title = "标题"
    var id: String { rawValue }
    var icon: String {
        switch self { case .recent: return "clock.arrow.circlepath"; case .popular: return "flame"; case .random: return "shuffle"; case .pages: return "book.pages"; case .title: return "textformat" }
    }
}

struct FeatureCard: View {
    let icon: String; let title: String
    var body: some View { VStack(alignment: .leading, spacing: 12) { Image(systemName: icon).font(.title2).foregroundStyle(.purple); Text(title).font(.headline) }.frame(maxWidth: .infinity, minHeight: 88, alignment: .leading).padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16)) }
}
struct GalleryCard: View {
    let gallery: Gallery
    private let coverHeight: CGFloat = 220
    private let cardHeight: CGFloat = 302

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GalleryCover(url: gallery.thumbnailURL)
                .frame(height: coverHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .bottomLeading) {
                    if let postedAt = gallery.postedAt, !postedAt.isEmpty {
                        Label("发布 \(postedAt)", systemImage: "calendar")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7).padding(.vertical, 4)
                            .background(.black.opacity(0.65), in: Capsule())
                            .padding(6)
                    }
                }

            Text(gallery.title)
                .font(.subheadline.bold())
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: 42, maxHeight: 42, alignment: .topLeading)

            HStack(spacing: 8) {
                Label(gallery.uploader.isEmpty ? "未知作者" : gallery.uploader, systemImage: "person")
                Label(gallery.pageCount > 0 ? "\(gallery.pageCount) 页" : "页数未知", systemImage: "book.pages")
                if let rating = gallery.rating, rating > 0 {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                } else {
                    Label("暂无评分", systemImage: "star")
                }
            }
            .lineLimit(1)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(height: 18, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight, alignment: .topLeading)
        .contentShape(Rectangle())
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sort: GallerySort
    @Binding var config: AdvancedSearchConfig
    var body: some View {
        NavigationStack { Form {
            Section("排序") { Picker("排序方式", selection: $sort) { ForEach(GallerySort.allCases) { Text($0.rawValue).tag($0) } } }
            Section("页数范围") { HStack { Text("最少"); TextField("不限", value: $config.pageAtLeast, format: .number).keyboardType(.numberPad); Text("最多"); TextField("不限", value: $config.pageAtMost, format: .number).keyboardType(.numberPad) } }
            Section("分类") { ForEach(GalleryCategory.allCases) { category in Toggle(category.rawValue, isOn: Binding(get: { config.categories.contains(category) }, set: { if $0 { config.categories.insert(category) } else { config.categories.remove(category) } })) } }
            Section("标签") { TextField("例如: artist:xxx", text: Binding(get: { config.tags.joined(separator: ", ") }, set: { config.tags = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } })) }
            Section { Button("清除筛选") { config = AdvancedSearchConfig() }.foregroundStyle(.red) }
        }.navigationTitle("高级筛选").toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } } }
    }
}

struct GalleryDetailView: View {
    let gallery: Gallery
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var discovery: DiscoveryStore
    @EnvironmentObject private var library: LibraryStore
    @EnvironmentObject private var downloads: DownloadStore
    @State private var item: Gallery
    @State private var detailError: String?
    @State private var showCommentEditor = false
    @State private var commentDraft = ""
    @State private var isPostingComment = false
    @State private var offlineAvailable = false
    init(gallery: Gallery) { self.gallery = gallery; _item = State(initialValue: gallery) }
    var body: some View {
        ScrollView { LazyVStack(alignment: .leading, spacing: 18) {
            PipelineImage(url: item.thumbnailURL, cookieHeader: session.cookieHeader(), contentMode: .fit).frame(maxWidth: .infinity).frame(height: 300)
            HStack(alignment: .top) { VStack(alignment: .leading) { Text(item.title).font(.title2.bold()); Text("\(item.uploader) · \(item.pageCount) 页").foregroundStyle(.secondary); if let postedAt = item.postedAt, !postedAt.isEmpty { Label("发布于 \(postedAt)", systemImage: "calendar").font(.caption).foregroundStyle(.secondary) } }; Spacer(); Button { library.toggleFavorite(item) } label: { Image(systemName: library.isFavorite(item) ? "star.fill" : "star").font(.title2) } }
            GalleryInfoCard(gallery: item)
            if let detailError { Text(detailError).font(.caption).foregroundStyle(.orange) }
            HStack { NavigationLink { ReaderDestination.view(for: item) } label: { Label("开始阅读", systemImage: "book.fill").frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent).disabled(!offlineAvailable && item.sourceURL == nil); Button { downloadOnline() } label: { Image(systemName: "arrow.down.to.line") }.buttonStyle(.bordered).disabled(item.sourceURL == nil); if let source = item.sourceURL { Link(destination: source) { Image(systemName: "safari") }.buttonStyle(.bordered) }; ShareLink(item: item.title) { Image(systemName: "square.and.arrow.up") }.buttonStyle(.bordered) }
            if item.sourceURL == nil && !offlineAvailable { Text("缺少在线地址且无离线副本，无法阅读或下载。").font(.caption).foregroundStyle(.orange) }
            if !item.previews.isEmpty { PreviewStrip(gallery: item, previews: item.previews) }
            HStack(spacing: 6) {
                Image(systemName: "tag.fill").font(.subheadline).foregroundStyle(.purple)
                Text("标签").font(.headline)
                Text("\(item.tags.count) 个").font(.caption).foregroundStyle(.secondary)
            }
            ForEach(groupedTags, id: \.0) { section in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: sectionIcon(section.2))
                            .font(.subheadline)
                            .foregroundStyle(TagStyle.foreground(for: section.2))
                            .frame(width: 22, height: 22)
                            .background(TagStyle.background(for: section.2), in: Circle())
                        Text(section.0).font(.subheadline.bold())
                        Text("\(section.1.count)").font(.caption).foregroundStyle(.secondary)
                    }
                    FlowTags(tags: section.1)
                }
            }
            if !item.tags.isEmpty && groupedTags.isEmpty {
                FlowTags(tags: item.tags)
            }
            commentsSection
        }.padding() }
        .navigationTitle("详情").navigationBarTitleDisplayMode(.inline).onAppear { offlineAvailable = OfflineLibrary.hasCompleteCopy(item); library.record(item) }.task { await hydrate() }
        .sheet(isPresented: $showCommentEditor) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $commentDraft)
                        .frame(minHeight: 140)
                        .padding(8)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    HStack {
                        Text("\(commentDraft.count)/2000").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        if isPostingComment { ProgressView().controlSize(.small) }
                        Button("发送") { postComment() }.buttonStyle(.borderedProminent).disabled(commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 || isPostingComment)
                    }
                }.padding()
                .navigationTitle("发表评论").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消") { showCommentEditor = false } } }
            }
            .presentationDetents([.medium])
        }
    }
    @ViewBuilder private var commentsSection: some View {
        if item.sourceURL != nil {
            HStack(spacing: 6) {
                Image(systemName: "bubble.left.and.bubble.right.fill").font(.subheadline).foregroundStyle(.purple)
                Text("评论").font(.headline)
                Text("\(item.comments.count) 条").font(.caption).foregroundStyle(.secondary)
                Spacer()
                if session.isLoggedIn {
                    Button { commentDraft = ""; showCommentEditor = true } label: {
                        Label("写评论", systemImage: "square.and.pencil").font(.caption).labelStyle(.titleAndIcon)
                    }.buttonStyle(.bordered).controlSize(.small)
                }
            }
            if item.comments.isEmpty {
                Text(session.isLoggedIn ? "暂无评论，抢先发表第一条？" : "暂无评论").font(.caption).foregroundStyle(.secondary).padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(item.comments) { comment in CommentRow(comment: comment) }
                }
            }
        }
    }
    private func postComment() {
        let content = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        isPostingComment = true
        Task {
            defer { isPostingComment = false }
            do {
                let detail = try await SiteClient.shared.postComment(gallery: item, content: content, cookieHeader: session.cookieHeader())
                item = detail.gallery
                commentDraft = ""
                showCommentEditor = false
            } catch {
                detailError = "评论发送失败：\(error.localizedDescription)"
            }
        }
    }
    private func sectionIcon(_ namespace: String) -> String {
        switch namespace.lowercased() {
        case "artist": return "person.fill"
        case "group": return "person.3.fill"
        case "parody": return "book.closed.fill"
        case "character": return "person.crop.square.fill"
        case "language": return "globe"
        case "female": return "figure.stand.dress"
        case "male": return "figure.stand"
        case "mixed": return "person.2.fill"
        case "cosplayer": return "camera.fill"
        case "location": return "mappin.and.ellipse"
        case "reclass": return "arrow.triangle.2.circlepath"
        default: return "tag.fill"
        }
    }

    private func sectionTitle(_ namespace: String) -> String {
        TagTranslationStore.namespaceName(namespace)
    }

    private var groupedTags: [(String, [GalleryTag], String)] {
        let order = ["language", "parody", "group", "artist", "character", "female", "male", "mixed", "cosplayer", "reclass", "location", "temp", "other"]
        let grouped = Dictionary(grouping: item.tags) { $0.namespace.lowercased() }
        let known = Set(order)
        let extra = grouped.keys.filter { !known.contains($0) }.sorted()
        return (order + extra).compactMap { ns in
            guard let list = grouped[ns], !list.isEmpty else { return nil }
            return (sectionTitle(ns), list, ns)
        }
    }


    private func hydrate() async { guard item.sourceURL != nil else { return }; do { item = try await SiteClient.shared.detailMetadata(item, cookieHeader: session.cookieHeader()); library.record(item) } catch { detailError = "详情加载失败：\(error.localizedDescription)" } }

    private func downloadOnline() { Task { do { guard item.sourceURL != nil else { detailError = "该作品缺少在线地址，无法下载。"; return }; let detail = try await SiteClient.shared.detail(item, cookieHeader: session.cookieHeader()); let urls = try await SiteClient.shared.imageURLs(for: detail, cookieHeader: session.cookieHeader()); guard !urls.isEmpty else { detailError = "未解析到可下载图片。"; return }; item = detail.gallery; if !downloads.enqueue(item, imageURLs: urls) { detailError = "下载任务创建失败，请检查网络后重试。" } } catch { detailError = "无法创建下载任务：\(error.localizedDescription)" } } }
}

struct FlowTags: View {
    let tags: [GalleryTag]
    @EnvironmentObject private var discovery: DiscoveryStore
    @EnvironmentObject private var translations: TagTranslationStore
    @State private var infoTag: TranslatedTag?
    @State private var expanded = false
    private static let initialLimit = 60
    private var visibleTags: [GalleryTag] { expanded ? tags : Array(tags.prefix(Self.initialLimit)) }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 8) {
                ForEach(visibleTags) { tag in
                    Button { searchTag(tag.rawName) } label: {
                        chip(for: tag)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if let intro = translations.translatedTag(for: tag.rawName)?.intro, !intro.isEmpty {
                            Button("查看简介") { infoTag = translations.translatedTag(for: tag.rawName) }
                        }
                        Button("复制原始标签") { UIPasteboard.general.string = tag.rawName }
                        Button(discovery.isSubscribed(tag.rawName) ? "取消订阅" : "订阅标签") { discovery.toggleTag(tag.rawName) }
                    }
                }
            }
            if tags.count > Self.initialLimit {
                Button { withAnimation(.snappy) { expanded.toggle() } } label: {
                    Label(expanded ? "收起" : "展开全部 \(tags.count) 个标签", systemImage: expanded ? "chevron.up" : "chevron.down").font(.caption).foregroundStyle(.purple)
                }
            }
        }
        .alert(item: $infoTag) { tag in
            Alert(
                title: Text("\(tag.name)"),
                message: Text(tagInfoMessage(tag)),
                primaryButton: .default(Text("订阅标签")) { discovery.toggleTag("\(tag.namespace):\(tag.key)") },
                secondaryButton: .cancel(Text("关闭"))
            )
        }
    }

    private func searchTag(_ rawName: String) {
        NotificationCenter.default.post(name: .taroSearchTag, object: nil, userInfo: ["tag": rawName])
    }

    /// A uniform-height rounded chip. Translated tags get the namespace color;
    /// untranslated ones are dimmed so the two states read at a glance.
    private func chip(for tag: GalleryTag) -> some View {
        let translated = translations.translatedTag(for: tag.rawName) != nil
        let subscribed = discovery.isSubscribed(tag.rawName)
        return HStack(spacing: 5) {
            if subscribed {
                Image(systemName: "bell.fill").font(.system(size: 9))
            }
            Text(translations.displayName(for: tag.rawName))
                .lineLimit(1)
                .font(.system(size: 12, weight: translated ? .medium : .regular))
        }
        .foregroundStyle(translated ? TagStyle.foreground(for: tag.namespace) : Color.secondary)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(
            translated ? TagStyle.background(for: tag.namespace) : Color.secondary.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
        )
        .overlay(
            subscribed
                ? RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color.purple.opacity(0.7), lineWidth: 1.2)
                : nil
        )
    }

    private func tagInfoMessage(_ tag: TranslatedTag) -> String {
        var parts = ["原始标签：\(tag.namespace):\(tag.key)"]
        if let intro = tag.intro, !intro.isEmpty { parts.append("简介：\(intro)") }
        return parts.joined(separator: "\n\n")
    }
}

struct ReaderView: View {
    let gallery: Gallery
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var reading: ReadingStore
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var showUI = true
    @State private var fit = true
    var pages: [GalleryPage] { DemoData.pages(for: gallery) }
    var body: some View { ZStack { Color.black.ignoresSafeArea(); TabView(selection: $index) { ForEach(Array(pages.enumerated()), id: \.element.id) { i, page in PipelineImage(url: page.imageURL, cookieHeader: session.cookieHeader(), contentMode: fit ? .fit : .fill).frame(maxWidth: .infinity, maxHeight: .infinity).clipped().tag(i) } }.tabViewStyle(.page(indexDisplayMode: .never)).onTapGesture { withAnimation { showUI.toggle() } }; if showUI { VStack { HStack { Button { dismiss() } label: { Image(systemName: "chevron.down") }; Spacer(); Text(gallery.title).lineLimit(1); Spacer(); Button { fit.toggle() } label: { Image(systemName: "arrow.up.left.and.arrow.down.right") } }.padding().background(.black.opacity(0.75)); Spacer(); Text("第 \(index + 1) / \(pages.count) 页").font(.caption).padding().background(.black.opacity(0.75)) } } }.foregroundStyle(.white).statusBarHidden(!showUI).onAppear { index = min(reading.page(for: gallery), max(0, pages.count - 1)) }.onChange(of: index) { _, value in reading.save(gallery: gallery, pageIndex: value) } }
}

struct ShelfView: View {
    @EnvironmentObject private var library: LibraryStore
    @EnvironmentObject private var downloads: DownloadStore
    @EnvironmentObject private var reading: ReadingStore
    private var offline: [OfflineTask] { downloads.tasks.filter { $0.state == .complete } }
    var body: some View { List {
        if let recent = library.history.first, reading.page(for: recent) > 0 { Section("继续阅读") { ContinueReadingCard(gallery: recent) } }
        Section("离线作品 · \(offline.count)") { if offline.isEmpty { Text("完成下载的作品会显示在这里").foregroundStyle(.secondary) }; ForEach(offline) { task in NavigationLink { OfflineReaderView(gallery: task.gallery) } label: { GalleryRow(gallery: task.gallery) } } }
        Section("收藏 · \(library.favorites.count)") {
            if library.favorites.isEmpty { Text("还没有收藏").foregroundStyle(.secondary) }
            ForEach(library.favorites) { gallery in
                NavigationLink { GalleryDetailView(gallery: gallery) } label: { GalleryRow(gallery: gallery) }
            }
        }
        Section("最近阅读 · \(library.history.count)") { ForEach(library.history) { gallery in NavigationLink { GalleryDetailView(gallery: gallery) } label: { GalleryRow(gallery: gallery) } } }
    }.navigationTitle("书架") }
}

struct GalleryRow: View {
    let gallery: Gallery
    var body: some View { HStack { PipelineImage(url: gallery.thumbnailURL, contentMode: .fill).frame(width: 48, height: 66).clipShape(RoundedRectangle(cornerRadius: 7)); VStack(alignment: .leading) { Text(gallery.title).lineLimit(2); Text("\(gallery.pageCount) 页 · \(gallery.category)").font(.caption).foregroundStyle(.secondary) } } }
}
