import Foundation
import SwiftData

@Model
final class GalleryRecord {
    @Attribute(.unique) var recordKey: String
    var gid: Int
    var sourceValue: String
    var title: String
    var uploader: String
    var category: String
    var thumbnailURLString: String?
    var sourceURLString: String?
    var pageCount: Int
    var tagsData: Data
    var rating: Double?
    var postedAt: String?
    var isFavorite: Bool
    var lastOpenedAt: Date?

    init(gallery: Gallery, isFavorite: Bool = false, lastOpenedAt: Date? = nil) {
        recordKey = gallery.stableKey; gid = gallery.id; sourceValue = gallery.source.rawValue; title = gallery.title; uploader = gallery.uploader; category = gallery.category
        thumbnailURLString = gallery.thumbnailURL?.absoluteString; sourceURLString = gallery.sourceURL?.absoluteString; pageCount = gallery.pageCount
        tagsData = (try? JSONEncoder().encode(gallery.tags)) ?? Data(); rating = gallery.rating; postedAt = gallery.postedAt; self.isFavorite = isFavorite; self.lastOpenedAt = lastOpenedAt
    }

    func gallery() -> Gallery? {
        guard let source = EHSource(rawValue: sourceValue), let tags = try? JSONDecoder().decode([GalleryTag].self, from: tagsData) else { return nil }
        return Gallery(id: gid, source: source, title: title, uploader: uploader, category: category, thumbnailURL: thumbnailURLString.flatMap(URL.init(string:)), sourceURL: sourceURLString.flatMap(URL.init(string:)), pageCount: pageCount, tags: tags, rating: rating, postedAt: postedAt)
    }
    func update(from gallery: Gallery) {
        title = gallery.title; uploader = gallery.uploader; category = gallery.category; thumbnailURLString = gallery.thumbnailURL?.absoluteString; sourceURLString = gallery.sourceURL?.absoluteString; pageCount = gallery.pageCount; tagsData = (try? JSONEncoder().encode(gallery.tags)) ?? Data(); rating = gallery.rating; postedAt = gallery.postedAt
    }
}

extension Gallery {
    var stableKey: String { "\(source.rawValue):\(id)" }
}
