import SwiftUI

struct ShelfMetricCard: View {
    let value: String
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(value).font(.title2.weight(.bold)).lineLimit(1)
            Text(title).font(.caption.weight(.medium)).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.primary.opacity(0.06), lineWidth: 0.8))
    }
}

struct ShelfGalleryCard: View {
    let gallery: Gallery
    var progress: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            GalleryCover(url: gallery.thumbnailURL)
                .frame(width: 132, height: 174)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if let progress {
                        Text("\(Int(progress * 100))%")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.62), in: Capsule())
                            .padding(8)
                    }
                }
            Text(gallery.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .frame(width: 132, alignment: .leading)
            if let progress {
                ProgressView(value: progress)
                    .tint(TaroTheme.accent)
                    .frame(width: 132)
            } else {
                Text(gallery.pageCount > 0 ? "\(gallery.pageCount) 页" : "页数未知")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

struct ShelfHorizontalSection<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let content: Content

    init(title: String, subtitle: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TaroSectionHeader(title: title, subtitle: subtitle, icon: icon)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) { content }
            }
        }
    }
}
