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

            if image == nil && !failed {
                loadingView
            }

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: fit ? .fit : .fill)
                    .scaleEffect(scale)
                    .transition(.opacity)
            }

            if failed {
                failedView
            }
        }
        .frame(maxWidth: .infinity, minHeight: image == nil && !failed ? 320 : 0)
        .clipped()
        .onChange(of: url) { _, newValue in
            if newValue != nil {
                failed = false
                image = nil
                appeared = false
            }
        }
        .task(id: "\(url?.absoluteString ?? "nil")-\(retryToken)") {
            guard let url else { return }
            do {
                let value = try await ImagePipeline.shared.image(
                    for: url,
                    cookieHeader: session.cookieHeader(),
                    referer: nil
                )
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    image = value
                    failed = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                // Retry once after delay
                try? await Task.sleep(for: .milliseconds(500))
                do {
                    let value = try await ImagePipeline.shared.image(
                        for: url,
                        cookieHeader: session.cookieHeader(),
                        referer: nil
                    )
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        image = value
                        failed = false
                    }
                } catch {
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        failed = true
                    }
                    onAutoRetry()
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 18) {
            Text("\(pageNumber)")
                .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                .foregroundStyle(.white.opacity(0.1))

            ProgressView()
                .tint(.white.opacity(0.5))
                .controlSize(.small)
            Text(url == nil ? "准备中" : "加载中")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var failedView: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.octagon")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.4))
            Text("第 \(pageNumber) 页加载失败")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            Button("重试") {
                failed = false
                image = nil
                retryToken += 1
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.6))
            .controlSize(.small)
        }
    }
}
