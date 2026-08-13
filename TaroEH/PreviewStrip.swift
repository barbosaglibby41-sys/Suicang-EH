import SwiftUI
import UIKit

/// Horizontal strip of gallery page thumbnails extracted from the detail
/// page's sprite sheets. Tiles are shown by offsetting the sprite inside a
/// clipped frame sized to each page's true aspect ratio (so landscape pages
/// and long strips render fully, never showing sprite padding). Scrolling to
/// the end loads the next batch via the gallery's pagination (`?p=N`).
struct PreviewStrip: View {
    let gallery: Gallery
    @EnvironmentObject private var session: SessionStore
    @State private var previews: [PagePreview]
    @State private var sprites: [URL: UIImage] = [:]
    @State private var loadedBatch = 0
    @State private var isLoadingMore = false
    @State private var hasMore = true
    @State private var failed = false
    private let tileWidth: CGFloat = 100

    init(gallery: Gallery, previews: [PagePreview]) {
        self.gallery = gallery
        _previews = State(initialValue: previews)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "photo.stack").font(.subheadline).foregroundStyle(.purple)
                Text("内容预览").font(.headline)
                Text("已加载 \(previews.count) 页").font(.caption).foregroundStyle(.secondary)
                Spacer()
                if isLoadingMore { ProgressView().controlSize(.small) }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(previews, id: \.page) { preview in
                        tile(preview)
                    }
                    if hasMore {
                        ProgressView().controlSize(.small).frame(width: 40, height: 80)
                            .onAppear { Task { await loadMore() } }
                    }
                }.padding(.vertical, 2)
            }
            if failed && sprites.isEmpty {
                Text("预览图加载失败，点按开始阅读查看内容").font(.caption).foregroundStyle(.secondary)
            }
        }
        .task { await ensureSprites(for: previews) }
    }

    private func tile(_ preview: PagePreview) -> some View {
        let scale = tileWidth / CGFloat(max(preview.width, 1))
        let tileHeight = tileWidth * CGFloat(max(preview.height, 1)) / CGFloat(max(preview.width, 1))
        return NavigationLink { OnlineReaderView(gallery: gallery, startIndex: preview.page - 1) } label: {
            ZStack(alignment: .bottomTrailing) {
                if let sprite = sprites[preview.spriteURL] {
                    Image(uiImage: sprite)
                        .resizable()
                        .frame(width: sprite.size.width * scale, height: sprite.size.height * scale)
                        .offset(x: -CGFloat(preview.xOffset) * scale, y: -CGFloat(preview.yOffset) * scale)
                } else {
                    Color.secondary.opacity(0.15)
                }
                Text("\(preview.page)")
                    .font(.caption2.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 4))
                    .padding(3)
                    .allowsHitTesting(false)
            }
            .frame(width: tileWidth, height: tileHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.3), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    /// Downloads every sprite sheet referenced by the batch, then renders it.
    private func ensureSprites(for batch: [PagePreview]) async {
        let needed = Set(batch.map(\.spriteURL)).subtracting(sprites.keys)
        for url in needed {
            do {
                let image = try await ImagePipeline.shared.image(for: url, cookieHeader: session.cookieHeader())
                await MainActor.run { sprites[url] = image }
            } catch {
                failed = true
            }
        }
    }

    /// Fetches the next 20-page batch via `?p=N` and appends its previews.
    private func loadMore() async {
        guard hasMore, !isLoadingMore, let base = gallery.sourceURL else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        let next = loadedBatch + 1
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "p", value: String(next))]
        guard let url = components?.url else { hasMore = false; return }
        do {
            let data = try await SiteClient.shared.request(url, cookieHeader: session.cookieHeader())
            guard let html = String(data: data, encoding: .utf8) else { hasMore = false; return }
            let batch = SiteParser.previews(from: html, limit: 20)
            guard !batch.isEmpty else { hasMore = false; return }
            loadedBatch = next
            let known = Set(previews.map(\.page))
            let fresh = batch.filter { !known.contains($0.page) }
            guard !fresh.isEmpty else { hasMore = false; return }
            previews.append(contentsOf: fresh)
            await ensureSprites(for: fresh)
        } catch {
            hasMore = false
        }
    }
}
