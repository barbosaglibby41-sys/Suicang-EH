import SwiftUI

struct DiscoverHeroBanner: View {
    let source: EHSource
    let isLoggedIn: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(TaroTheme.heroGradient)
                .shadow(color: TaroTheme.accent.opacity(0.24), radius: 18, y: 9)
            Circle()
                .fill(.white.opacity(0.09))
                .frame(width: 110, height: 110)
                .offset(x: 45, y: -38)
            HStack(spacing: 11) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text("芋头 E 站").font(.headline.weight(.bold)).foregroundStyle(.white)
                    HStack(spacing: 6) {
                        Text("探索 · 收藏 · 阅读")
                        Text("·")
                        Label(source.title, systemImage: source == .exHentai ? "lock.fill" : "globe")
                        Text(isLoggedIn ? "· 已连接" : "· 直连")
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 13)
        }
        .frame(minHeight: 88, maxHeight: 96)
        .clipped()
    }
}

struct DiscoverSearchHeader: View {
    let isFocused: Bool
    let isLoading: Bool
    let hasQuery: Bool
    let submit: () -> Void
    let clear: () -> Void
    let focus: () -> Void
    let field: () -> AnyView

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.medium))
                .foregroundStyle(isFocused ? TaroTheme.accent : .secondary)
            field()
            if isLoading {
                ProgressView().controlSize(.small)
            } else if hasQuery {
                Button(action: clear) { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                    .buttonStyle(.plain)
                Button(action: submit) { Image(systemName: "arrow.up.right.circle.fill").foregroundStyle(TaroTheme.accent).font(.title3) }
                    .buttonStyle(.plain)
            } else {
                Button(action: focus) {
                    Text("搜索").font(.caption.weight(.bold)).foregroundStyle(TaroTheme.accent)
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 54)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(isFocused ? TaroTheme.accent.opacity(0.45) : TaroTheme.accent.opacity(0.12), lineWidth: isFocused ? 1.2 : 0.8))
        .shadow(color: TaroTheme.accent.opacity(isFocused ? 0.12 : 0.05), radius: 13, y: 5)
        .animation(.easeOut(duration: 0.18), value: isFocused)
    }
}

struct DiscoverResultsHeader: View {
    let title: String
    let count: Int
    let sortTitle: String
    let sortAction: () -> Void
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "rectangle.stack.fill")
                .foregroundStyle(TaroTheme.accent)
                .frame(width: 34, height: 34)
                .background(TaroTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.weight(.bold))
                Text("已加载 \(count) 项").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: sortAction) {
                Label(sortTitle, systemImage: "arrow.up.arrow.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TaroTheme.accent)
                    .padding(.horizontal, 11).padding(.vertical, 8)
                    .background(TaroTheme.accent.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}
