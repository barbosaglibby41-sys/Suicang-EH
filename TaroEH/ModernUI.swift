import SwiftUI

// MARK: - Taro visual system

enum TaroTheme {
    static let accent = Color(red: 0.68, green: 0.18, blue: 0.92)
    static let accentDeep = Color(red: 0.34, green: 0.08, blue: 0.48)
    static let accentSoft = Color(red: 0.76, green: 0.42, blue: 0.98)
    static let canvasLight = Color(red: 0.965, green: 0.955, blue: 0.98)
    static let canvasDark = Color(red: 0.055, green: 0.045, blue: 0.07)
    static let cardDark = Color(red: 0.105, green: 0.095, blue: 0.125)

    static var brandGradient: LinearGradient {
        LinearGradient(colors: [accent, accentSoft], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [accentDeep, accent.opacity(0.86), Color.indigo.opacity(0.74)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct TaroPageBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        (colorScheme == .dark ? TaroTheme.canvasDark : TaroTheme.canvasLight)
            .ignoresSafeArea()
    }
}

struct TaroCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content
    var padding: CGFloat = 16

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(colorScheme == .dark ? TaroTheme.cardDark : Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.045), lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.06), radius: 16, y: 7)
    }
}

struct TaroSectionHeader: View {
    let title: String
    var subtitle: String?
    var icon: String?

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TaroTheme.accent)
            }
            Text(title).font(.title3.weight(.bold))
            Spacer()
            if let subtitle {
                Text(subtitle).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            }
        }
    }
}

struct TaroStatusPill: View {
    let title: String
    let icon: String
    var tint: Color = TaroTheme.accent

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.13), in: Capsule())
    }
}

struct TaroEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var body: some View {
        TaroCard {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(TaroTheme.brandGradient)
                Text(title).font(.headline)
                Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct TaroAvatar: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background(TaroTheme.brandGradient, in: Circle())
            .shadow(color: TaroTheme.accent.opacity(0.3), radius: 10, y: 5)
    }
}

struct TaroPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 17)
            .frame(minHeight: 44)
            .background(TaroTheme.brandGradient, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(color: TaroTheme.accent.opacity(configuration.isPressed ? 0.12 : 0.28), radius: 10, y: 5)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
