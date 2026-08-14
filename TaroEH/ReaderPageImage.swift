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
                    // Set image first, then trigger crossfade on next runloop
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
                withAnimation(.easeInOut(duration: 0.3)) { failed = true }
                onAutoRetry()
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 18) {
            // Subtle shimmer background
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.03))
                    .frame(maxWidth: 220, maxHeight: 300)

                // Large faded page number as context
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
            Button("重试") {
                withAnimation(.easeOut(duration: 0.2)) {
                    failed = false
                    image = nil
                    appeared = false
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
        switch status {
        case .waiting: return "等待中"
        case .loading: return url == nil ? "准备中" : "加载中"
        case .loaded: return ""
        case .failed: return ""
        case .empty: return "准备中"
        }
    }
}
