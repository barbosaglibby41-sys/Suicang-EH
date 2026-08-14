import SwiftUI

/// Gallery list layouts inspired by JHenTai, EhPanda and EhViewer-Apple.
enum GalleryListStyle: String, CaseIterable, Identifiable {
    case flat = "flat"
    case flatNoTags = "flatNoTags"
    case card = "card"
    case cardNoTags = "cardNoTags"
    case waterfallSmall = "waterfallSmall"
    case waterfallMedium = "waterfallMedium"
    case waterfallLarge = "waterfallLarge"

    var id: String { rawValue }
    var title: String {
        switch self {
        case .flat: return "平坦"
        case .flatNoTags: return "平坦 - 无标签"
        case .card: return "卡片"
        case .cardNoTags: return "卡片 - 无标签"
        case .waterfallSmall: return "瀑布流（小）"
        case .waterfallMedium: return "瀑布流（中）"
        case .waterfallLarge: return "瀑布流（大）"
        }
    }
    var icon: String {
        switch self {
        case .flat, .flatNoTags: return "list.bullet"
        case .card, .cardNoTags: return "rectangle.grid.1x2"
        case .waterfallSmall, .waterfallMedium, .waterfallLarge: return "rectangle.grid.2x2"
        }
    }
    var includesTags: Bool {
        self == .flat || self == .card
    }
    var waterfallColumns: Int? {
        switch self {
        case .waterfallSmall: return 3
        case .waterfallMedium: return 2
        case .waterfallLarge: return 1
        default: return nil
        }
    }
}

// MARK: - Press Scale Button Style

struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    var opacity: Double = 0.85
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? opacity : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

// MARK: - Settings

struct GalleryListSettingsView: View {
    @AppStorage("taro.eh.gallery.listStyle") private var styleRaw = GalleryListStyle.card.rawValue
    private var style: Binding<GalleryListStyle> {
        Binding(
            get: { GalleryListStyle(rawValue: styleRaw) ?? .card },
            set: { styleRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section("画廊列表样式") {
                Picker("样式", selection: style) {
                    ForEach(GalleryListStyle.allCases) { item in
                        Label(item.title, systemImage: item.icon).tag(item)
                    }
                }
                .pickerStyle(.inline)
            }
            Section("说明") {
                Text("平坦适合快速浏览，卡片适合查看封面信息，瀑布流会根据屏幕宽度显示更多作品。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("画廊列表样式")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Flat Row

struct GalleryFlatRow: View {
    let gallery: Gallery
    let showTags: Bool

    var body: some View {
        HStack(spacing: 12) {
            GalleryCover(url: gallery.thumbnailURL)
                .frame(width: 92, height: 122)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                Text(gallery.title)
                    .font(.headline)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showTags && !gallery.tags.isEmpty {
                    GalleryTagPreview(tags: gallery.tags, maxTags: 4, maxRows: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer(minLength: 2)
                Text(gallery.uploader.isEmpty ? "未知作者" : gallery.uploader)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 10) {
                    if let rating = gallery.rating {
                        Label(String(format: "%.1f", rating), systemImage: "star.fill")
                            .foregroundStyle(.orange)
                    }
                    Label(gallery.pageCount > 0 ? "\(gallery.pageCount)P" : "未知页数", systemImage: "book.pages")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .frame(minHeight: 122)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Tag Preview

struct GalleryTagPreview: View {
    let tags: [GalleryTag]
    var maxTags: Int = 3
    var maxRows: Int = 1
    @EnvironmentObject private var translations: TagTranslationStore

    var body: some View {
        let rows = max(1, maxRows)
        FlowLayout(spacing: 5) {
            ForEach(Array(tags.prefix(maxTags))) { tag in
                Text(translations.displayName(for: tag.rawName))
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.12), in: Capsule())
            }
        }
        .frame(maxHeight: CGFloat(rows) * 24, alignment: .topLeading)
        .clipped()
    }
}

// MARK: - Waterfall Card

struct GalleryWaterfallCard: View {
    let gallery: Gallery
    let showTags: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            GalleryCover(url: gallery.thumbnailURL)
                .frame(maxWidth: .infinity)
                .aspectRatio(0.72, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(gallery.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(3)
            HStack {
                Text(gallery.pageCount > 0 ? "\(gallery.pageCount)P" : "—")
                Spacer()
                if let rating = gallery.rating { Label(String(format: "%.1f", rating), systemImage: "star.fill").foregroundStyle(.orange) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if showTags && !gallery.tags.isEmpty { GalleryTagPreview(tags: gallery.tags, maxTags: 3, maxRows: 2) }
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}
