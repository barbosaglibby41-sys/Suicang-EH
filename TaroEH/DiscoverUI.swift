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
                .fill(.white.opacity(0.10))
                .frame(width: 170, height: 170)
                .offset(x: 50, y: -50)
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 100, height: 100)
                .offset(x: -110, y: 55)
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                VStack(alignment: .leading, spacing: 5) {
                    Text("芋头 E 站").font(.title2.weight(.bold)).foregroundStyle(.white)
                    Text("探索新作品，找到下一本想读的漫画")
                        .font(.caption).foregroundStyle(.white.opacity(0.78))
                    HStack(spacing: 7) {
                        Label(source.title, systemImage: source == .exHentai ? "lock.fill" : "globe")
                        Text("·")
                        Text(isLoggedIn ? "已连接账户" : "直连浏览")
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .frame(minHeight: 132)
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
