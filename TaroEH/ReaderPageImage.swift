import SwiftUI
import UIKit

enum PageState: String, Equatable {
    case waiting
    case loading
    case loaded
    case failed
    case empty
}

struct ReaderPageImage: View {
    let url: URL?
    let referer: URL?
    let pageNumber: Int
    let status: PageState
    let fit: Bool
    let scale: CGFloat
    let onRetry: () -> Void
    let onAutoRetry: () -> Void
    @EnvironmentObject private var session: SessionStore
    @State private var image: UIImage?
    @State private var failed = false
    @State private var retryToken = 0
    @State private var appeared = false
    @State private var autoRetryCount = 0

    var body: some View {
        ZStack {
            Color.black

            // Loading layer — stays visible until image is ready, then crossfades out
            if image == nil && !failed {
                loadingView
                    .opacity(appeared ? 0 : 1)
                    .animation(.easeInOut(duration: 0.35), value: appeared)
            }

            // Image layer — fades in on top
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: fit ? .fit : .fill)
                    .scaleEffect(scale)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeInOut(duration: 0.35), value: appeared)
            }

            // Failed layer
            if failed {
                failedView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .frame(maxWidth: .infinity, minHeight: image == nil && !failed ? 320 : 0)
        .clipped()
        .animation(.easeInOut(duration: 0.3), value: image != nil)
        .animation(.easeInOut(duration: 0.3), value: failed)
        .onChange(of: url) { _, newValue in
            // URL changed (e.g. resolved by batchResolveURLs) → reset and restart
            if newValue != nil {
                failed = false
                image = nil
                appeared = false
                autoRetryCount = 0
            }
        }
        .task(id: "\(url?.absoluteString ?? "nil")-\(retryToken)") {
            guard let url else { return }

            var lastError: Error?
            for attempt in 0..<3 {
                do {
                    if attempt > 0 {
                        try await Task.sleep(for: .milliseconds(500 * attempt))
                    }
                    let value = try await ImagePipeline.shared.image(
                        for: url,
                        cookieHeader: session.cookieHeader(),
                        referer: referer
                    )
                    guard !Task.isCancelled else { return }
                    image = value
                    failed = false
                    appeared = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        withAnimation(.easeInOut(duration: 0.35)) { appeared = true }
                    }
                    lastError = nil
                    break
                } catch {
                    lastError = error
                }
            }

            if image == nil, lastError != nil, !Task.isCancelled {
                // Show failed state
                withAnimation(.easeInOut(duration: 0.3)) { failed = true }

                // Auto-retry: increment retryToken to restart .task after delay
                // This avoids the infinite loop where onAutoRetry → loadPage →
                // .loaded state → onChange → failed=false → stuck loading
                if autoRetryCount < 5 {
                    autoRetryCount += 1
                    let delay = min(2.0 * Double(autoRetryCount), 8.0)
                    Task {
                        try? await Task.sleep(for: .seconds(delay))
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                failed = false
                            }
                            retryToken += 1
                        }
                    }
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.03))
                    .frame(maxWidth: 220, maxHeight: 300)

                Text("\(pageNumber)")
                    .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                    .foregroundStyle(.white.opacity(0.1))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 6) {
                ProgressView()
                    .tint(.white.opacity(0.5))
                    .controlSize(.small)
                Text(progressText)
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Failed View

    private var failedView: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.octagon")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.4))
            Text("第 \(pageNumber) 页加载失败")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            if autoRetryCount >= 5 {
                Text("已重试 \(autoRetryCount) 次，请检查网络后手动重试")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            } else {
                Text("正在自动重试… (\(autoRetryCount)/5)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
            Button("手动重试") {
                withAnimation(.easeOut(duration: 0.2)) {
                    failed = false
                    image = nil
                    appeared = false
                    autoRetryCount = 0
                }
                retryToken += 1
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.6))
            .controlSize(.small)
        }
    }

    private var progressText: String {
        if url == nil { return "准备中" }
        return "加载中"
    }
}
