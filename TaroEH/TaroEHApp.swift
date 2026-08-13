import SwiftUI
import SwiftData

@main
struct TaroEHApp: App {
    @StateObject private var session = SessionStore()
    @StateObject private var reading = ReadingStore()
    @StateObject private var downloads = DownloadStore()
    @StateObject private var discovery = DiscoveryStore()
    @StateObject private var tagTranslations = TagTranslationStore()
    @StateObject private var rankings = RankingStore()
    private let modelContainer: ModelContainer

    init() {
        do { modelContainer = try ModelContainer(for: GalleryRecord.self) }
        catch { fatalError("无法创建本地数据存储：\(error)") }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(reading)
                .environmentObject(downloads)
                .environmentObject(discovery)
                .environmentObject(tagTranslations)
                .environmentObject(rankings)
        }
        .modelContainer(modelContainer)
    }
}
