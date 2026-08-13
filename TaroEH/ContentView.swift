import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.modelContext) private var modelContext
    @StateObject private var library = LibraryStore()
    @State private var path = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                DiscoverView()
                    .navigationDestination(for: Gallery.self) { GalleryDetailView(gallery: $0) }
            }.tabItem { Label("发现", systemImage: "sparkles") }
            NavigationStack { ShelfView() }.tabItem { Label("书架", systemImage: "books.vertical") }
            NavigationStack { DownloadsView() }.tabItem { Label("离线", systemImage: "arrow.down.circle") }
            NavigationStack { SettingsView() }.tabItem { Label("设置", systemImage: "gear") }
        }
        .environmentObject(session)
        .environmentObject(library)
        .tint(.purple)
        .task { library.configure(modelContext) }
    }
}

struct DiscoverView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var discovery: DiscoveryStore
    @EnvironmentObject private var tagTranslations: TagTranslationStore
    @AppStorage("taro.eh.siteURL") private var siteAddress = "https://e-hentai.org/"
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    @State private var query = ""
    @State private var results: [Gallery] = []
    @State private var isLoading = false
    @State private var networkError: String?
    @State private var showFilters = false
    @State private var sort: GallerySort = .recent
    @State private var advanced = AdvancedSearchConfig()
    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 14)]

    private var currentSource: EHSource { EHSource(rawValue: sourceRaw) ?? .eHentai }
    private var filtered: [Gallery] {
        var config = advanced
        config.keyword = query
        return sort.apply(results.filter { config.matches($0) })
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
                HStack(spacing: 12) {
                    Button { randomGallery() } label: { FeatureCard(icon: "die.face.5", title: "随机一本") }
                    Button { showFilters = true } label: { FeatureCard(icon: "slider.horizontal.3", title: "筛选排序") }
                }
                searchBar
                suggestions
                if let networkError { Label(networkError, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange) }
                recentQueries
                HStack { Text("画廊").font(.title3.bold()); Spacer(); Text("\(filtered.count) 项").foregroundStyle(.secondary).font(.caption) }
                if !isLoading && filtered.isEmpty {
                    ContentUnavailableView("暂无画廊", systemImage: "rectangle.stack", description: Text("下拉刷新或使用搜索查找作品。"))
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filtered) { gallery in NavigationLink(value: gallery) { GalleryCard(gallery: gallery) }.buttonStyle(.plain) }
                    }
                }
            }.padding()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFilters) { FilterView(sort: $sort, config: $advanced) }
        .task { loadFrontPage() }
        .onChange(of: sourceRaw) { _, _ in results = []; loadFrontPage() }
        .onChange(of: siteAddress) { _, _ in results = []; loadFrontPage() }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("搜索标题、作者或标签", text: $query)
                .textInputAutocapitalization(.never)
                .onSubmit { onlineSearch() }
            if isLoading { ProgressView().controlSize(.small) }
            else if !query.isEmpty { Button { onlineSearch() } label: { Image(systemName: "arrow.right.circle.fill") } }
        }.padding(13).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder private var suggestions: some View {
        if tagTranslations.enabled && !query.isEmpty {
            let values = tagTranslations.suggestions(for: query)
            if !values.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("标签补全").font(.caption).foregroundStyle(.secondary)
                    ForEach(values) { tag in
                        Button {
                            if tagTranslations.fillMode { query = tagTranslations.replacingCurrentToken(in: query, with: tag) }
                        } label: {
                            HStack { Text(tag.name); Spacer(); Text("\(tag.namespace):\(tag.key)").font(.caption).foregroundStyle(.secondary) }
                        }.buttonStyle(.plain).disabled(!tagTranslations.fillMode)
                    }
                }.padding(12).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @ViewBuilder private var recentQueries: some View {
        if !discovery.recentQueries.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack { Text("最近搜索").font(.caption).foregroundStyle(.secondary); Spacer(); Button("清除") { discovery.clearQueries() }.font(.caption) }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { ForEach(discovery.recentQueries, id: \.self) { item in Button(item) { query = item; onlineSearch() }.font(.caption).padding(.horizontal, 10).padding(.vertical, 7).background(.purple.opacity(0.18), in: Capsule()) } }
                }
            }
        }
    }

    private func loadFrontPage() {
        guard results.isEmpty, let base = URL(string: siteAddress) else { return }
        isLoading = true; networkError = nil
        Task {
            do { results = try await SiteClient.shared.frontPage(source: currentSource, baseURL: base, cookieHeader: session.cookieHeader()) }
            catch { networkError = "无法加载首页：\(error.localizedDescription)" }
            isLoading = false
        }
    }
    private func randomGallery() {
        guard let base = URL(string: siteAddress) else { return }
        isLoading = true; networkError = nil
        Task {
            do { if let gallery = try await SiteClient.shared.randomGallery(source: currentSource, baseURL: base, cookieHeader: session.cookieHeader()) { results = [gallery] } }
            catch { networkError = "随机发现失败：\(error.localizedDescription)" }
            isLoading = false
        }
    }
    private func onlineSearch() {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty, let base = URL(string: siteAddress) else { return }
        isLoading = true; networkError = nil
        var config = advanced; config.keyword = term
        Task {
            do {
                let raw = ([config.keyword] + config.tags).filter { !$0.isEmpty }.joined(separator: " ")
                let found = try await SiteClient.shared.search(config: config, cookieHeader: session.cookieHeader(), baseURL: base, source: currentSource, translatedQuery: tagTranslations.queryForSite(raw))
                discovery.record(query: term); results = found
                if found.isEmpty { networkError = "没有匹配结果，或站点页面结构发生变化。" }
            } catch { networkError = "无法完成直连搜索：\(error.localizedDescription)" }
            isLoading = false
        }
    }
}

enum GallerySort: String, CaseIterable, Identifiable {
    case recent = "最近", pages = "页数", title = "标题"
    var id: String { rawValue }
    func apply(_ values: [Gallery]) -> [Gallery] { switch self { case .recent: return values; case .pages: return values.sorted { $0.pageCount > $1.pageCount }; case .title: return values.sorted { $0.title < $1.title } } }
}

struct FeatureCard: View {
    let icon: String; let title: String
    var body: some View { VStack(alignment: .leading, spacing: 12) { Image(systemName: icon).font(.title2).foregroundStyle(.purple); Text(title).font(.headline) }.frame(maxWidth: .infinity, minHeight: 88, alignment: .leading).padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16)) }
}
struct GalleryCard: View {
    let gallery: Gallery
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PipelineImage(url: gallery.thumbnailURL, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .aspectRatio(0.72, contentMode: .fit)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(gallery.title).font(.subheadline.bold()).lineLimit(2)
            HStack(spacing: 8) {
                Label(gallery.pageCount > 0 ? "\(gallery.pageCount) 页" : "页数未知", systemImage: "book.pages")
                if let rating = gallery.rating, rating > 0 {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill").foregroundStyle(.yellow)
                } else {
                    Label("暂无评分", systemImage: "star").foregroundStyle(.secondary)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
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
    init(gallery: Gallery) { self.gallery = gallery; _item = State(initialValue: gallery) }
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 18) {
            PipelineImage(url: item.thumbnailURL, cookieHeader: session.cookieHeader(), contentMode: .fit).frame(maxWidth: .infinity).frame(height: 300)
            HStack(alignment: .top) { VStack(alignment: .leading) { Text(item.title).font(.title2.bold()); Text("\(item.uploader) · \(item.pageCount) 页").foregroundStyle(.secondary) }; Spacer(); Button { library.toggleFavorite(item) } label: { Image(systemName: library.isFavorite(item) ? "star.fill" : "star").font(.title2) } }
            if let detailError { Text(detailError).font(.caption).foregroundStyle(.orange) }
            HStack { NavigationLink { item.sourceURL == nil ? AnyView(ReaderView(gallery: item)) : AnyView(OnlineReaderView(gallery: item)) } label: { Label("开始阅读", systemImage: "book.fill").frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent); Button { downloadOnline() } label: { Image(systemName: "arrow.down.to.line") }.buttonStyle(.bordered); if let source = item.sourceURL { Link(destination: source) { Image(systemName: "safari") }.buttonStyle(.bordered) }; ShareLink(item: item.title) { Image(systemName: "square.and.arrow.up") }.buttonStyle(.bordered) }
            Text("标签").font(.headline); FlowTags(tags: item.tags)
        }.padding() }
        .navigationTitle("详情").navigationBarTitleDisplayMode(.inline).onAppear { library.record(item) }.task { await hydrate() }
    }
    private func hydrate() async { guard item.sourceURL != nil else { return }; do { item = try await SiteClient.shared.detail(item, cookieHeader: session.cookieHeader()).gallery; library.record(item) } catch { detailError = "详情加载失败：\(error.localizedDescription)" } }
    private func downloadOnline() { Task { do { if item.sourceURL == nil { downloads.enqueue(item); return }; let detail = try await SiteClient.shared.detail(item, cookieHeader: session.cookieHeader()); let urls = try await SiteClient.shared.imageURLs(for: detail, cookieHeader: session.cookieHeader()); guard !urls.isEmpty else { detailError = "未解析到可下载图片。"; return }; item = detail.gallery; downloads.enqueue(item, imageURLs: urls) } catch { detailError = "无法创建下载任务：\(error.localizedDescription)" } } }
}

struct FlowTags: View {
    let tags: [GalleryTag]
    @EnvironmentObject private var discovery: DiscoveryStore
    @EnvironmentObject private var translations: TagTranslationStore
    var body: some View { LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), alignment: .leading)], alignment: .leading) { ForEach(tags) { tag in Button { discovery.toggleTag(tag.rawName) } label: { HStack(spacing: 5) { Text(translations.displayName(for: tag.rawName)); if discovery.isSubscribed(tag.rawName) { Image(systemName: "bell.fill") } }.font(.caption).padding(.horizontal, 10).padding(.vertical, 7).background(discovery.isSubscribed(tag.rawName) ? .purple.opacity(0.35) : .purple.opacity(0.2), in: Capsule()) } } } }
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
        Section("最近阅读") { ForEach(library.history) { gallery in GalleryRow(gallery: gallery) } }
    }.navigationTitle("书架") }
}

struct GalleryRow: View {
    let gallery: Gallery
    var body: some View { HStack { PipelineImage(url: gallery.thumbnailURL, contentMode: .fill).frame(width: 48, height: 66).clipShape(RoundedRectangle(cornerRadius: 7)); VStack(alignment: .leading) { Text(gallery.title).lineLimit(2); Text("\(gallery.pageCount) 页 · \(gallery.category)").font(.caption).foregroundStyle(.secondary) } } }
}
