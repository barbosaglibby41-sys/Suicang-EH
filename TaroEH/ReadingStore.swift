import Foundation

/// Architecture inspired by JHenTai (Apache-2.0): per-gallery progress keyed by stable ID.
struct ReadingProgress: Codable, Hashable { var galleryID: Int; var source: EHSource; var pageIndex: Int; var pageCount: Int; var updatedAt: Date }
@MainActor final class ReadingStore: ObservableObject {
    @Published private(set) var records: [String: ReadingProgress] = [:]; private let key = "taro.eh.reading.progress.v2"
    init() { load() }
    func page(for gallery: Gallery) -> Int { records[gallery.stableKey]?.pageIndex ?? 0 }
    func hasProgress(for gallery: Gallery) -> Bool {
        guard let value = records[gallery.stableKey] else { return false }
        return value.pageCount > 0
    }
    private var pendingSave: Task<Void, Never>?
    func save(gallery: Gallery, pageIndex: Int) {
        let maximum: Int
        if gallery.pageCount > 0 {
            maximum = max(0, gallery.pageCount - 1)
        } else {
            // A list/detail model may not have its total page count hydrated
            // yet. Never collapse a valid saved position back to page zero.
            maximum = Int.max
        }
        let safeIndex = min(max(0, pageIndex), maximum)
        records[gallery.stableKey] = ReadingProgress(galleryID: gallery.id, source: gallery.source, pageIndex: safeIndex, pageCount: gallery.pageCount, updatedAt: .now)
        // Persist immediately so a navigation pop or app suspension cannot lose
        // the last page. The delayed write remains as a coalesced backup.
        persist()
        pendingSave?.cancel()
        pendingSave = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.persist() }
        }
    }
    func clear(gallery: Gallery) { records.removeValue(forKey: gallery.stableKey); persist() }
    private func persist() { if let data = try? JSONEncoder().encode(records) { UserDefaults.standard.set(data, forKey: key) } }
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key), let v = try? JSONDecoder().decode([String: ReadingProgress].self, from: data) { records = v; return }
        if let data = UserDefaults.standard.data(forKey: "taro.eh.reading.progress.v1"), let old = try? JSONDecoder().decode([Int: LegacyReadingProgress].self, from: data) {
            records = old.reduce(into: [:]) { $0["e-hentai:\($1.key)"] = ReadingProgress(galleryID: $1.value.galleryID, source: .eHentai, pageIndex: $1.value.pageIndex, pageCount: $1.value.pageCount, updatedAt: $1.value.updatedAt) }
            persist()
        }
    }
}
private struct LegacyReadingProgress: Codable { var galleryID: Int; var pageIndex: Int; var pageCount: Int; var updatedAt: Date }

enum DownloadState: String, Codable { case queued, downloading, paused, complete, failed }
struct OfflineTask: Identifiable, Codable, Hashable {
    let id: UUID; let gallery: Gallery; let imageURLs: [URL]; var completedPages: Int; var state: DownloadState; var createdAt: Date
    var totalPages: Int { imageURLs.isEmpty ? gallery.pageCount : imageURLs.count }
    var progress: Double { totalPages == 0 ? 0 : Double(completedPages) / Double(totalPages) }
}

/// Global gallery-level scheduler. Page requests remain sequential inside a task.
@MainActor final class DownloadStore: ObservableObject {
    @Published private(set) var tasks: [OfflineTask] = []
    private let key = "taro.eh.download.tasks.v2"; private var workers: [UUID: Task<Void, Never>] = [:]
    init() { load(); tasks = tasks.map { var t = $0; if t.state == .downloading { t.state = .queued }; return t }; schedule() }
    var runningCount: Int { workers.count }
    var maximumConcurrentTasks: Int { let value = UserDefaults.standard.integer(forKey: "taro.eh.concurrent"); return max(1, min(6, value == 0 ? 2 : value)) }
    /// Returns false when no real image URLs are provided (e.g. missing source
    /// URL) so callers can surface an error instead of downloading demo pages.
    @discardableResult
    func enqueue(_ gallery: Gallery, imageURLs: [URL]? = nil) -> Bool {
        guard !tasks.contains(where: { $0.gallery.stableKey == gallery.stableKey }) else { return true }
        guard let urls = imageURLs, !urls.isEmpty else { return false }
        tasks.insert(OfflineTask(id: UUID(), gallery: gallery, imageURLs: urls, completedPages: 0, state: .queued, createdAt: .now), at: 0)
        persist(); schedule(); return true
    }
    func toggle(_ task: OfflineTask) { task.state == .downloading ? pause(task) : resume(task) }
    func resume(_ task: OfflineTask) { guard let i = tasks.firstIndex(where: { $0.id == task.id }), tasks[i].state != .complete else { return }; tasks[i].state = .queued; persist(); schedule() }
    func pause(_ task: OfflineTask) { workers[task.id]?.cancel(); workers[task.id] = nil; guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { return }; tasks[i].state = .paused; persist(); schedule() }
    func retry(_ task: OfflineTask) { guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { return }; tasks[i].state = .queued; persist(); schedule() }
    func remove(_ task: OfflineTask) { workers[task.id]?.cancel(); workers[task.id] = nil; tasks.removeAll { $0.id == task.id }; persist(); schedule() }
    func schedule() { while workers.count < maximumConcurrentTasks, let next = tasks.first(where: { $0.state == .queued }) { launch(next.id) } }
    private func launch(_ id: UUID) { guard workers[id] == nil, let i = tasks.firstIndex(where: { $0.id == id }) else { return }; tasks[i].state = .downloading; let snapshot = tasks[i]; persist(); workers[id] = Task { [weak self] in await DownloadService.shared.start(task: snapshot, onPage: { page in guard !Task.isCancelled else { return }; await self?.update(id: id, pages: page) }, onFinish: { result in guard !Task.isCancelled else { return }; await self?.finish(id: id, result: result) }) } }
    private func update(id: UUID, pages: Int) { guard let i = tasks.firstIndex(where: { $0.id == id }) else { return }; tasks[i].completedPages = pages; persist() }
    private func finish(id: UUID, result: Result<Void, Error>) { guard let i = tasks.firstIndex(where: { $0.id == id }) else { return }; tasks[i].state = result.isSuccess ? .complete : .failed; if result.isSuccess { OfflineLibrary.invalidateCache(for: tasks[i].gallery) }; workers[id] = nil; persist(); schedule() }
    private func persist() { if let data = try? JSONEncoder().encode(tasks) { UserDefaults.standard.set(data, forKey: key) } }
    private func load() { if let data = UserDefaults.standard.data(forKey: key), let v = try? JSONDecoder().decode([OfflineTask].self, from: data) { tasks = v } }
}
private extension Result where Success == Void, Failure == Error { var isSuccess: Bool { if case .success = self { return true }; return false } }
