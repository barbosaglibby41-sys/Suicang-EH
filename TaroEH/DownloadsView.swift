import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var downloads: DownloadStore
    @State private var usedBytes: Int64 = 0
    var body: some View {
        List {
            Section { LabeledContent("本地占用", value: OfflineLibrary.formatted(usedBytes)); LabeledContent("运行任务", value: "\(downloads.runningCount) / \(downloads.maximumConcurrentTasks)"); Text("已完成作品可在无网络时直接阅读。") .font(.caption).foregroundStyle(.secondary) }
            if downloads.tasks.isEmpty { ContentUnavailableView("暂无离线任务", systemImage: "arrow.down.circle", description: Text("在作品详情页点击下载即可加入队列。")) }
            ForEach(downloads.tasks) { task in
                HStack(spacing: 12) {
                    PipelineImage(url: task.gallery.thumbnailURL, contentMode: .fill).frame(width: 48, height: 64).clipShape(RoundedRectangle(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 6) { Text(task.gallery.title).lineLimit(2); ProgressView(value: task.progress); Text("\(task.completedPages) / \(task.totalPages) 页 · \(task.state.rawValue)").font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    if task.state == .complete { NavigationLink { OfflineReaderView(gallery: task.gallery) } label: { Image(systemName: "book.fill") } }
                    else { Button { task.state == .failed ? downloads.retry(task) : downloads.toggle(task) } label: { Image(systemName: task.state == .downloading ? "pause.fill" : task.state == .failed ? "arrow.clockwise" : "play.fill") } }
                }
                .swipeActions { Button(role: .destructive) { downloads.remove(task); OfflineLibrary.delete(task.gallery); refreshSize() } label: { Label("删除", systemImage: "trash") } }
            }
        }.navigationTitle("离线下载").toolbar { Button { refreshSize() } label: { Image(systemName: "arrow.clockwise") } }.onAppear { refreshSize() }.onChange(of: downloads.tasks) { _, _ in refreshSize() }
    }
    private func refreshSize() { usedBytes = OfflineLibrary.totalSize() }
}

struct OfflineReaderView: View {
    let gallery: Gallery
    private var pages: [URL] { OfflineLibrary.pageURLs(for: gallery) }
    var body: some View { if pages.isEmpty { ContentUnavailableView("没有可读页面", systemImage: "photo") } else { SharedReaderView(title: gallery.title, pageCount: pages.count) { i, fit, scale in PipelineImage(url: pages[i], contentMode: fit ? .fit : .fill).scaleEffect(scale).frame(maxWidth: .infinity, maxHeight: .infinity) } } }
}
