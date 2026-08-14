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
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.octagon")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.85))
                    Text("第 \(pageNumber) 页加载失败")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Button("重试") {
                        failed = false
                        image = nil
                        retryToken += 1
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .controlSize(.small)
                }
            } else {
                VStack(spacing: 10) {
                    ProgressView().tint(.white)
                    Text(progressText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: status == .loaded ? 0 : 260)
        .clipped()
        .onChange(of: status) { _, newValue in
            if newValue == .failed && !failed { failed = true }
            if newValue == .loading && url != nil { failed = false }
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
                    withAnimation(.easeOut(duration: 0.22)) {
                        image = value
                        failed = false
                    }
                    lastError = nil
                    break
                } catch {
                    lastError = error
                }
            }
            if image == nil, lastError != nil, !Task.isCancelled {
                failed = true
                onAutoRetry()
            }
        }
    }

    private var progressText: String {
        switch status {
        case .waiting: return "等待第 \(pageNumber) 页"
        case .loading: return url == nil ? "正在准备第 \(pageNumber) 页" : "正在加载第 \(pageNumber) 页"
        case .loaded: return ""
        case .failed: return "第 \(pageNumber) 页加载失败"
        case .empty: return "正在准备第 \(pageNumber) 页"
        }
    }
}
