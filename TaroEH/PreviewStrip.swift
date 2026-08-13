import SwiftUI
import UIKit

/// Horizontal strip of gallery page thumbnails extracted from the detail
/// page's sprite sheet. One sprite download yields many tiles (cropped in the
/// background); tapping a tile opens the reader at that page.
struct PreviewStrip: View {
    let gallery: Gallery
    let previews: [PagePreview]
    @EnvironmentObject private var session: SessionStore
    @State private var tiles: [Int: UIImage] = [:]
    @State private var failed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "photo.stack").font(.subheadline).foregroundStyle(.purple)
                Text("内容预览").font(.headline)
                Text("前 \(previews.count) 页").font(.caption).foregroundStyle(.secondary)
            }
            if tiles.isEmpty && !failed {
                HStack { Spacer(); ProgressView().controlSize(.small); Spacer() }.frame(height: 120)
            } else if failed && tiles.isEmpty {
                Text("预览图加载失败，点按开始阅读查看内容").font(.caption).foregroundStyle(.secondary).padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(previews, id: \.page) { preview in
                            tile(preview)
                        }
                    }.padding(.vertical, 2)
                }
            }
        }
        .task { await loadTiles() }
    }

    private func tile(_ preview: PagePreview) -> some View {
        NavigationLink { OnlineReaderView(gallery: gallery, startIndex: preview.page - 1) } label: {
            ZStack(alignment: .bottomTrailing) {
                if let image = tiles[preview.page] {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 141).clipped()
                } else {
                    Color.secondary.opacity(0.15)
                }
                Text("\(preview.page)")
                    .font(.caption2.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 4))
            }
            .frame(width: 100, height: 141)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.3), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func loadTiles() async {
        guard tiles.isEmpty, !previews.isEmpty else { return }
        let grouped = Dictionary(grouping: previews) { $0.spriteURL }
        for (spriteURL, group) in grouped {
            do {
                let sprite = try await ImagePipeline.shared.image(for: spriteURL, cookieHeader: session.cookieHeader())
                let cropped = await Self.crop(sprite, previews: group)
                await MainActor.run { tiles.merge(cropped) { _, new in new } }
            } catch {
                failed = true
            }
        }
    }

    private static func crop(_ sprite: UIImage, previews: [PagePreview]) async -> [Int: UIImage] {
        await Task.detached(priority: .utility) {
            guard let cg = sprite.cgImage else { return [:] }
            var result: [Int: UIImage] = [:]
            for p in previews {
                let rect = CGRect(x: p.xOffset, y: 0, width: min(p.width, cg.width - p.xOffset), height: min(p.height, cg.height))
                guard rect.width > 0, rect.height > 0, let tile = cg.cropping(to: rect) else { continue }
                result[p.page] = UIImage(cgImage: tile)
            }
            return result
        }.value
    }
}
