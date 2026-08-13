import SwiftUI

struct GalleryInfoCard: View {
    let gallery: Gallery
    @EnvironmentObject private var session: SessionStore
    @State private var isLoadingTorrent = false
    @State private var torrentURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                infoItem("globe", "语言", gallery.language ?? "未知")
                infoItem("square.stack.3d.up", "页数", "\(gallery.pageCount)")
                infoItem("calendar", "发布", gallery.postedAt ?? "未知")
            }
            HStack(alignment: .top, spacing: 14) {
                infoItem("internaldrive", "大小", gallery.fileSize ?? "未知")
                infoItem("heart", "收藏", gallery.favoriteCount.map(String.init) ?? "—")
                infoItem("star", "评分", gallery.rating.map { String(format: "%.2f", $0) } ?? "—")
            }
            HStack(spacing: 8) {
                if let category = gallery.category.isEmpty ? nil : gallery.category {
                    Text(category).font(.caption.weight(.semibold)).foregroundStyle(.white).padding(.horizontal, 9).padding(.vertical, 5).background(.purple, in: Capsule())
                }
                if let ratingCount = gallery.ratingCount { Label("\(ratingCount) 次评分", systemImage: "star.fill").font(.caption).foregroundStyle(.secondary) }
                Spacer()
                if let torrent = torrentURL ?? gallery.torrentURL {
                    ShareLink(item: torrent) { Label("种子", systemImage: "arrow.down.circle").font(.caption.weight(.semibold)) }.buttonStyle(.bordered).controlSize(.small)
                } else {
                    Button { loadTorrent() } label: { Label(isLoadingTorrent ? "获取中" : "种子", systemImage: "arrow.down.circle").font(.caption.weight(.semibold)) }.buttonStyle(.bordered).controlSize(.small).disabled(isLoadingTorrent)
                }
            }
            if let errorMessage { Text(errorMessage).font(.caption2).foregroundStyle(.orange) }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func infoItem(_ icon: String, _ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption.weight(.medium)).lineLimit(1)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func loadTorrent() {
        guard gallery.sourceURL != nil else { return }
        isLoadingTorrent = true
        Task {
            do { torrentURL = try await SiteClient.shared.torrentURL(for: gallery, cookieHeader: session.cookieHeader()); if torrentURL == nil { errorMessage = "官网暂无可用种子" } }
            catch { errorMessage = "种子获取失败：\(error.localizedDescription)" }
            isLoadingTorrent = false
        }
    }
}
