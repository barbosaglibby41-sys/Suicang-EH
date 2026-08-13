import SwiftUI
import UIKit

/// Gallery page preview strip. Each sprite tile is cropped in pixel space
/// before it reaches SwiftUI; this avoids transparent/black sprite padding
/// leaking into the preview frame on landscape and long-strip pages.
struct PreviewStrip: View {
    let gallery: Gallery
    @EnvironmentObject private var session: SessionStore
    @State private var previews: [PagePreview]
    @State private var tiles: [Int: UIImage] = [:]
    @State private var loadedSprites: Set<URL> = []
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
                    ForEach(previews, id: \.page) { preview in tile(preview) }
                    if hasMore {
                        ProgressView().controlSize(.small).frame(width: 40, height: 80)
                            // Recreate the sentinel after every appended batch;
                            // horizontal ScrollView otherwise fires onAppear only once.
                            .id("preview-loader-\(previews.count)")
                            .onAppear { Task { await loadMore() } }
                    }
                }.padding(.vertical, 2)
            }
            if failed && tiles.isEmpty {
                Text("预览图加载失败，点按开始阅读查看内容").font(.caption).foregroundStyle(.secondary)
            }
        }
        .task { await loadTiles(for: previews) }
    }

    private func tile(_ preview: PagePreview) -> some View {
        let width = CGFloat(max(preview.width, 1))
        let height = CGFloat(max(preview.height, 1))
        let tileHeight = tileWidth * height / width
        return NavigationLink { OnlineReaderView(gallery: gallery, startIndex: preview.page - 1) } label: {
            ZStack(alignment: .bottomTrailing) {
                if let image = tiles[preview.page] {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: tileWidth, height: tileHeight)
                } else {
                    Color.secondary.opacity(0.15)
                }
                Text("\(preview.page)")
                    .font(.caption2.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 4))
                    .padding(3)
            }
            .frame(width: tileWidth, height: tileHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.3), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func loadTiles(for batch: [PagePreview]) async {
        let groups = Dictionary(grouping: batch) { $0.spriteURL }
        for (spriteURL, group) in groups where !loadedSprites.contains(spriteURL) {
            do {
                let sprite = try await ImagePipeline.shared.image(for: spriteURL, cookieHeader: session.cookieHeader())
                let result = await crop(sprite, previews: group)
                await MainActor.run {
                    tiles.merge(result) { _, new in new }
                    loadedSprites.insert(spriteURL)
                }
            } catch {
                await MainActor.run { failed = true }
            }
        }
    }

    /// Converts CSS pixel coordinates to CGImage pixel coordinates and crops
    /// exactly the tile rectangle. No SwiftUI offset or UIImage point units.
    private func crop(_ sprite: UIImage, previews: [PagePreview]) async -> [Int: UIImage] {
        await Task.detached(priority: .userInitiated) {
            guard let cg = sprite.cgImage else { return [:] }
            var result: [Int: UIImage] = [:]
            for preview in previews {
                let x = max(0, min(preview.xOffset, cg.width - 1))
                let y = max(0, min(preview.yOffset, cg.height - 1))
                let width = min(preview.width, cg.width - x)
                let height = min(preview.height, cg.height - y)
                guard width > 0, height > 0,
                      let cropped = cg.cropping(to: CGRect(x: x, y: y, width: width, height: height)) else { continue }
                result[preview.page] = UIImage(cgImage: cropped, scale: 1, orientation: sprite.imageOrientation)
            }
            return result
        }.value
    }

    private func loadMore() async {
        guard hasMore, !isLoadingMore, let base = gallery.sourceURL else { return }
        await MainActor.run { isLoadingMore = true }
        defer { Task { @MainActor in isLoadingMore = false } }
        let next = loadedBatch + 1
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "p", value: String(next))]
        guard let url = components?.url else { await MainActor.run { hasMore = false }; return }
        do {
            let data = try await SiteClient.shared.request(url, cookieHeader: session.cookieHeader())
            guard let html = String(data: data, encoding: .utf8) else { await MainActor.run { hasMore = false }; return }
            let batch = SiteParser.previews(from: html, limit: 20)
            guard !batch.isEmpty else { await MainActor.run { hasMore = false }; return }
            let known = Set(previews.map(\.page))
            let fresh = batch.filter { !known.contains($0.page) }
            guard !fresh.isEmpty else { await MainActor.run { hasMore = false }; return }
            await MainActor.run {
                loadedBatch = next
                previews.append(contentsOf: fresh)
            }
            await loadTiles(for: fresh)
        } catch {
            await MainActor.run { hasMore = false }
        }
    }
}
