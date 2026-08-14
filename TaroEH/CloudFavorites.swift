import Foundation
import SwiftUI

struct CloudFavoriteCategory: Identifiable, Hashable {
    let id: Int
    var name: String

    static let defaults: [CloudFavoriteCategory] = (0..<10).map {
        CloudFavoriteCategory(id: $0, name: "收藏夹 \($0 + 1)")
    }
}

struct CloudFavoritePage {
    var categories: [CloudFavoriteCategory]
    var galleries: [Gallery]
    var nextURL: URL?
}

@MainActor
final class CloudFavoritesStore: ObservableObject {
    @Published private(set) var favorites: [Gallery] = []
    @Published private(set) var categories = CloudFavoriteCategory.defaults
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var selectedCategory = 0
    private var nextURL: URL?
    private var loadedKey = ""
    private var loadedKeys = Set<String>()

    var hasMore: Bool { nextURL != nil }
    var selectedCategoryName: String {
        categories.first(where: { $0.id == selectedCategory })?.name ?? "收藏夹 \(selectedCategory + 1)"
    }

    func selectCategory(_ category: Int, session: SessionStore, source: EHSource) async {
        selectedCategory = category
        await load(session: session, source: source)
    }

    func loadCategories(session: SessionStore, source: EHSource) async {
        guard session.isLoggedIn else { return }
        do {
            let page = try await SiteClient.shared.cloudFavorites(source: source, category: selectedCategory, cookieHeader: session.cookieHeader())
            if !page.categories.isEmpty { categories = page.categories }
        } catch {
            // The favorites list remains usable with the standard ten categories.
        }
    }

    func load(session: SessionStore, source: EHSource) async {
        guard session.isLoggedIn else {
            favorites = []
            errorMessage = nil
            return
        }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        nextURL = nil
        let key = "\(source.rawValue):\(selectedCategory)"
        loadedKey = key
        loadedKeys.removeAll()
        do {
            let page = try await SiteClient.shared.cloudFavorites(source: source, category: selectedCategory, cookieHeader: session.cookieHeader())
            if !page.categories.isEmpty { categories = page.categories }
            favorites = page.galleries
            loadedKeys = Set(favorites.map(\.stableKey))
            nextURL = page.nextURL
        } catch {
            errorMessage = "账户收藏加载失败：\(error.localizedDescription)"
        }
        isLoading = false
    }

    func loadMore(session: SessionStore, source: EHSource) async {
        guard session.isLoggedIn, !isLoading, let nextURL else { return }
        isLoading = true
        errorMessage = nil
        do {
            let page = try await SiteClient.shared.cloudFavorites(url: nextURL, source: source, cookieHeader: session.cookieHeader())
            let newItems = page.galleries.filter { loadedKeys.insert($0.stableKey).inserted }
            favorites.append(contentsOf: newItems)
            self.nextURL = page.nextURL
        } catch {
            errorMessage = "账户收藏加载失败：\(error.localizedDescription)"
        }
        isLoading = false
    }

    func isFavorite(_ gallery: Gallery) -> Bool {
        loadedKeys.contains(gallery.stableKey)
    }

    func setFavorite(_ gallery: Gallery, category: Int, session: SessionStore, source: EHSource) async {
        guard session.isLoggedIn else {
            errorMessage = "请先登录站点账户。"
            return
        }
        isLoading = true
        errorMessage = nil
        let removing = loadedKeys.contains(gallery.stableKey)
        do {
            try await SiteClient.shared.setCloudFavorite(gallery: gallery, category: removing ? -1 : category, cookieHeader: session.cookieHeader())
            if removing {
                loadedKeys.remove(gallery.stableKey)
                favorites.removeAll { $0.stableKey == gallery.stableKey }
            } else {
                loadedKeys.insert(gallery.stableKey)
                if selectedCategory == category && !favorites.contains(where: { $0.stableKey == gallery.stableKey }) {
                    favorites.insert(gallery, at: 0)
                }
            }
        } catch {
            errorMessage = "账户收藏更新失败：\(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct FavoriteTargetSheet: View {
    let gallery: Gallery
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var library: LibraryStore
    @EnvironmentObject private var cloud: CloudFavoritesStore
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    @State private var category = 0
    @State private var isWorking = false

    private var source: EHSource { EHSource(rawValue: sourceRaw) ?? .eHentai }

    var body: some View {
        NavigationStack {
            List {
                Section("本机") {
                    Button {
                        library.toggleFavorite(gallery)
                        dismiss()
                    } label: {
                        Label(library.isFavorite(gallery) ? "移出本地收藏" : "加入本地收藏", systemImage: library.isFavorite(gallery) ? "star.slash" : "star")
                    }
                }
                Section("站点账户") {
                    if session.isLoggedIn {
                        Picker("收藏夹", selection: $category) {
                            ForEach(cloud.categories) { item in
                                Text(item.name).tag(item.id)
                            }
                        }
                        Button {
                            isWorking = true
                            Task {
                                await cloud.setFavorite(gallery, category: category, session: session, source: source)
                                isWorking = false
                                if cloud.errorMessage == nil { dismiss() }
                            }
                        } label: {
                            HStack {
                                Label(cloud.isFavorite(gallery) ? "移出账户收藏" : "加入账户收藏", systemImage: cloud.isFavorite(gallery) ? "cloud.slash" : "cloud")
                                Spacer()
                                if isWorking { ProgressView().controlSize(.small) }
                            }
                        }.disabled(isWorking)
                        if let error = cloud.errorMessage {
                            Text(error).font(.footnote).foregroundStyle(.orange)
                        }
                    } else {
                        NavigationLink {
                            WebLoginView()
                        } label: {
                            Label("登录站点账户后使用", systemImage: "person.crop.circle.badge.plus")
                        }
                        Text("账户收藏由 E-Hentai / ExHentai 保存，可在其他客户端同步。")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("选择收藏位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
            .task {
                category = cloud.selectedCategory
                await cloud.loadCategories(session: session, source: source)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct CloudFavoritesView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var cloud: CloudFavoritesStore
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue

    private var source: EHSource { EHSource(rawValue: sourceRaw) ?? .eHentai }

    var body: some View {
        Group {
            if !session.isLoggedIn {
                VStack(spacing: 12) {
                    Image(systemName: "cloud.slash").font(.system(size: 42)).foregroundStyle(.secondary)
                    Text("登录后查看账户收藏").font(.headline)
                    NavigationLink("前往登录") { WebLoginView() }.buttonStyle(.borderedProminent)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        Picker("收藏夹", selection: Binding(get: { cloud.selectedCategory }, set: { value in
                            Task { await cloud.selectCategory(value, session: session, source: source) }
                        })) {
                            ForEach(cloud.categories) { category in Text(category.name).tag(category.id) }
                        }.pickerStyle(.menu)
                    }
                    Section("\(cloud.selectedCategoryName) · \(cloud.favorites.count)") {
                        if cloud.favorites.isEmpty && !cloud.isLoading {
                            Text("这个收藏夹还是空的").foregroundStyle(.secondary)
                        }
                        ForEach(cloud.favorites) { gallery in
                            NavigationLink(value: gallery) { GalleryRow(gallery: gallery) }
                        }
                        if cloud.hasMore {
                            HStack { Spacer(); if cloud.isLoading { ProgressView() } else { Text("加载更多").foregroundStyle(.secondary) }; Spacer() }
                                .task { await cloud.loadMore(session: session, source: source) }
                        }
                    }
                    if let error = cloud.errorMessage { Text(error).font(.footnote).foregroundStyle(.orange) }
                }
                .refreshable { await cloud.load(session: session, source: source) }
                .navigationDestination(for: Gallery.self) { GalleryDetailView(gallery: $0) }
            }
        }
        .navigationTitle("账户收藏")
        .task {
            await cloud.loadCategories(session: session, source: source)
            await cloud.load(session: session, source: source)
        }
        .onChange(of: sourceRaw) { _, _ in
            Task { await cloud.load(session: session, source: source) }
        }
    }
}
