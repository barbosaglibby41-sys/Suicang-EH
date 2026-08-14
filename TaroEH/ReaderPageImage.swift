import SwiftUI
import UIKit

/// A page-level reader image state. Unlike a plain ProgressView, it reserves
/// the page viewport while loading, fades the bitmap in, and retries in place.
struct ReaderPageImage: View {
    let url: URL?
    let pageNumber: Int
    let fit: Bool
    let scale: CGFloat
    let onRetry: () -> Void
    @EnvironmentObject private var session: SessionStore
    @State private var image: UIImage?
    @State private var failed = false
    @State private var retryToken = 0

    var body: some View {
        ZStack {
            Color.black
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: fit ? .fit : .fill)
                    .scaleEffect(scale)
                    .transition(.opacity.animation(.easeOut(duration: 0.22)))
            } else if failed {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.75))
                    Text("第 \(pageNumber) 页加载失败")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Button("重试") {
                        failed = false
                        image = nil
                        retryToken += 1
                        onRetry()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    .controlSize(.small)
                }
            } else {
                VStack(spacing: 10) {
                    ProgressView().tint(.white)
                    Text(url == nil ? "正在准备第 \(pageNumber) 页" : "正在加载第 \(pageNumber) 页")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: image == nil ? 260 : 0)
        .clipped()
        .task(id: "\(url?.absoluteString ?? "nil")-\(retryToken)") {
            guard let url else { return }
            do {
                let value = try await ImagePipeline.shared.image(for: url, cookieHeader: session.cookieHeader())
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.22)) {
                    image = value
                    failed = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                withAnimation { failed = true }
            }
        }
    }
}
