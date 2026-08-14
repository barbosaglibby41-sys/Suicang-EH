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

    var body: some View {
        ZStack {
            Color.black

            // Loading layer — stays visible until image is ready, then crossfades
            if image == nil && !failed {
                loadingView
                    .transition(.opacity)
            }

            // Image layer — fades in on top of loading view
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: fit ? .fit : .fill)
                    .scaleEffect(scale)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: appeared)
            }

            // Failed layer
            if failed {
                failedView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .frame(maxWidth: .infinity, minHeight: image == nil && !failed ? 320 : 0)
        .clipped()
        .animation(.easeInOut(duration: 0.25), value: image != nil)
        .animation(.easeInOut(duration: 0.25), value: failed)
        .onChange(of: status) { _, newValue in
            if newValue == .loaded { failed = false }
        }
        .onChange(of: url) { _, newValue in
            if newValue != nil { failed = false }
        }
        .task(id: "\(url?.absoluteString ?? "nil")-\(referer?.absoluteString ?? "")-\(retryToken)") {
            guard let url else { return }
            var lastError: Error?
            for attempt in 0..<2 {
                do {
                    if attempt > 0 { try await Task.sleep(for: .milliseconds(400)) }
                    let value = try await ImagePipeline.shared.image(for: url, cookieHeader: session.cookieHeader(), referer: referer)
                    guard !Task.isCancelled else { return }
                    appeared = false
                    image = value
                    failed = false
                    // Trigger fade-in on next runloop for smooth crossfade
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        withAnimation(.easeOut(duration: 0.3)) { appeared = true }
                    }
                    lastError = nil
                    break
                } catch {
                    lastError = error
                }
            }
            if image == nil, lastError != nil, !Task.isCancelled, status != .loaded {
                withAnimation(.easeInOut(duration: 0.25)) { failed = true }
                onAutoRetry()
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            // Large page number as subtle context
            Text("\(pageNumber)")
                .font(.system(size: 52, weight: .light, design: .rounded))
                .foregroundStyle(.white.opacity(0.12))

            VStack(spacing: 8) {
                ProgressView()
                    .tint(.white.opacity(0.6))
                    .controlSize(.regular)
                Text(progressText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Failed View

    private var failedView: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.octagon")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.5))
            Text("第 \(pageNumber) 页加载失败")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            Button("重试") {
                withAnimation(.easeOut(duration: 0.2)) {
                    failed = false
                    image = nil
                }
                retryToken += 1
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.7))
            .controlSize(.small)
        }
    }

    private var progressText: String {
        switch status {
        case .waiting: return "等待中…"
        case .loading: return url == nil ? "准备中…" : "加载中…"
        case .loaded: return ""
        case .failed: return ""
        case .empty: return "准备中…"
        }
    }
}
