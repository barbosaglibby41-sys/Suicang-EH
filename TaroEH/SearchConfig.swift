import Foundation

/// Original SwiftUI search model inspired by JHenTai's Apache-2.0 SearchConfig architecture.
enum GalleryCategory: String, CaseIterable, Codable, Identifiable {
    case doujinshi = "同人志", manga = "漫画", artistCG = "画师 CG", gameCG = "游戏 CG", western = "西方", nonH = "非 H", imageSet = "图集", cosplay = "Cosplay", asianPorn = "亚洲", misc = "其他"
    var id: String { rawValue }
}

struct AdvancedSearchConfig: Codable, Hashable {
    var keyword = ""
    var categories = Set(GalleryCategory.allCases)
    var language: String? = nil
    var pageAtLeast: Int? = nil
    var pageAtMost: Int? = nil
    var minimumRating = 1
    var onlyWithTorrents = false
    var tags: [String] = []
    func matches(_ gallery: Gallery) -> Bool {
        let words = ([keyword] + tags).joined(separator: " ").lowercased().split(separator: " ")
        let source = (gallery.title + " " + gallery.uploader + " " + gallery.category + " " + gallery.legacyTagNames.joined(separator: " ")).lowercased()
        guard words.allSatisfy({ source.contains($0) }) else { return false }
        if let min = pageAtLeast, gallery.pageCount < min { return false }
        if let max = pageAtMost, gallery.pageCount > max { return false }
        return true
    }
}
