import SwiftUI
import UIKit

/// Lightweight haptic feedback helpers.
enum Haptics {
    static func light() {
        guard !SettingsState.reduceMotion else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    static func medium() {
        guard !SettingsState.reduceMotion else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    static func success() {
        guard !SettingsState.reduceMotion else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    static func warning() {
        guard !SettingsState.reduceMotion else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

/// Global settings state for feature flags.
enum SettingsState {
    static var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}

/// A smooth loading overlay with fade transition.
struct LoadingOverlay: View {
    let isLoading: Bool
    var text: String = "加载中…"
    var body: some View {
        VStack(spacing: 12) {
            ProgressView().controlSize(.large)
            Text(text).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(40)
        .opacity(isLoading ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: isLoading)
        .allowsHitTesting(isLoading)
    }
}

/// Smooth appear-from-bottom transition for content sections.
extension AnyTransition {
    static var appearFromBottom: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity
        )
    }
    static var scaleFade: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.92)),
            removal: .opacity.combined(with: .scale(scale: 0.96))
        )
    }
}
