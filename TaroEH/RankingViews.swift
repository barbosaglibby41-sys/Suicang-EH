import SwiftUI

/// Compact ranking preview matching the home layout: two horizontal columns,
/// three entries per period, and a full-list action for deeper browsing.
struct HomeRankingsSection: View {
    @EnvironmentObject private var rankings: RankingStore
    @Binding var showAll: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("排行").font(.title2.bold())
                Spacer()
                Button("显示全部") { showAll = true }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if rankings.isLoading && rankings.yesterday.isEmpty && rankings.month.isEmpty {
                HStack { Spacer(); ProgressView("正在加载排行…"); Spacer() }
                    .frame(minHeight: 180)
            } else if rankings.yesterday.isEmpty && rankings.month.isEmpty {
                Text(rankings.error ?? "暂无排行数据")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 18) {
                        RankingPreviewColumn(period: .yesterday, galleries: Array(rankings.yesterday.prefix(3)))
                        RankingPreviewColumn(period: .month, galleries: Array(rankings.month.prefix(3)))
                    }
                }
            }
        }
    }
}

private struct RankingPreviewColumn: View {
    let period: RankingPeriod
    let galleries: [Gallery]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(period.rawValue, systemImage: period.icon)
                .font(.headline)
            VStack(spacing: 0) {
                ForEach(Array(galleries.enumerated()), id: \.element.id) { index, gallery in
                    NavigationLink(value: gallery) {
                        RankingRow(gallery: gallery, rank: index + 1)
                    }
                    .buttonStyle(.plain)
                    if index < galleries.count - 1 {
                        Divider().padding(.leading, 54)
                    }
                }
                if galleries.isEmpty {
                    Text("暂无数据").font(.caption).foregroundStyle(.secondary).frame(width: 320, height: 100)
                }
            }
            .frame(width: 350)
        }
    }
}

struct RankingRow: View {
    let gallery: Gallery
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            GalleryCover(url: gallery.thumbnailURL)
                .frame(width: 54, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text("\(rank)")
                .font(.title3.weight(.semibold))
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 4) {
                Text(gallery.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(gallery.uploader.isEmpty ? "未知作者" : gallery.uploader)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: 92)
        .contentShape(Rectangle())
    }
}

struct RankingListView: View {
    @EnvironmentObject private var rankings: RankingStore
    @State private var period: RankingPeriod = .yesterday
    @Environment(\.dismiss) private var dismiss
    @AppStorage("taro.eh.siteURL") private var siteAddress = "https://e-hentai.org/"
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    @EnvironmentObject private var session: SessionStore

    private var galleries: [Gallery] { rankings.galleries(for: period) }

    var body: some View {
        NavigationStack {
            Group {
                if rankings.isLoading && galleries.isEmpty {
                    ProgressView("正在加载排行…")
                } else if galleries.isEmpty {
                    ContentUnavailableView("暂无排行", systemImage: "chart.bar", description: Text(rankings.error ?? "请稍后重试"))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(galleries.enumerated()), id: \.element.id) { index, gallery in
                                NavigationLink(value: gallery) {
                                    RankingRow(gallery: gallery, rank: index + 1)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(.plain)
                                Divider().padding(.leading, 20)
                                    .onAppear {
                                        if index == galleries.count - 1 {
                                            Task { await rankings.loadMore(period) }
                                        }
                                    }
                            }
                            if rankings.loadingMore.contains(period) {
                                ProgressView("正在加载更多…").padding()
                            } else if rankings.canLoadMore(period) {
                                Text("继续下滑加载更多").font(.caption).foregroundStyle(.secondary).padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("排行 · \(period.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(RankingPeriod.allCases) { value in
                            Button {
                                period = value
                                if rankings.galleries(for: value).isEmpty {
                                    Task { await loadPeriod(value) }
                                }
                            } label: {
                                Label(value.rawValue, systemImage: value.icon)
                            }
                        }
                    } label: { Image(systemName: "line.3.horizontal.decrease.circle") }
                }
            }
            .navigationDestination(for: Gallery.self) { GalleryDetailView(gallery: $0) }
            .task { await loadPeriod(.yesterday) }
        }
    }

    private func loadPeriod(_ value: RankingPeriod) async {
        if rankings.galleries(for: value).isEmpty,
           let base = URL(string: siteAddress) {
            await rankings.loadPeriod(value)
            // The store is already configured by DiscoverView in normal use.
            // Configure it here too when the full list is opened directly.
            if rankings.galleries(for: value).isEmpty {
                await rankings.load(source: EHSource(rawValue: sourceRaw) ?? .eHentai, baseURL: base, cookieHeader: session.cookieHeader())
                await rankings.loadPeriod(value)
            }
        }
    }
}
