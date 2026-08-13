import Foundation

struct GalleryTag: Identifiable, Hashable, Codable {
    var namespace: String
    var key: String
    var translatedName: String?
    var id: String { "\(namespace):\(key)" }
    var rawName: String { namespace.isEmpty ? key : "\(namespace):\(key)" }
    var displayName: String { translatedName.map { "\($0) · \(rawName)" } ?? rawName
    }
    init(namespace: String = "other", key: String, translatedName: String? = nil) {
        self.namespace = namespace; self.key = key; self.translatedName = translatedName
    }
}

struct GalleryComment: Identifiable, Hashable, Codable {
    let id: Int
    let author: String
    let postedAt: String
    let score: Int?
    let isUploader: Bool
    let content: String
    let votes: String?
}

/// A thumbnail entry from the gallery detail page. E-Hentai serves page
/// thumbnails as sprite sheets (20 pages per image) cropped via background
/// offsets, so one download yields many preview tiles.
struct PagePreview: Hashable, Codable {
    let page: Int
    let spriteURL: URL
    let xOffset: Int
    let width: Int
    let height: Int
    let pageURL: URL
}

struct Gallery: Identifiable, Hashable, Codable {
    let id: Int
    var source: EHSource
    var title: String
    var uploader: String
    var category: String
    var thumbnailURL: URL?
    var sourceURL: URL?
    var pageCount: Int
    var tags: [GalleryTag]
    var rating: Double?
    var postedAt: String?
    var comments: [GalleryComment] = []
    var previews: [PagePreview] = []

    var legacyTagNames: [String] { tags.map(\.rawName) }

    init(id: Int, source: EHSource = .eHentai, title: String, uploader: String = "", category: String = "", thumbnailURL: URL? = nil, sourceURL: URL? = nil, pageCount: Int = 0, tags: [GalleryTag] = [], rating: Double? = nil, postedAt: String? = nil) {
        self.id = id; self.source = source; self.title = title; self.uploader = uploader; self.category = category; self.thumbnailURL = thumbnailURL; self.sourceURL = sourceURL; self.pageCount = pageCount; self.tags = tags; self.rating = rating; self.postedAt = postedAt
    }
    init(id: Int, source: EHSource = .eHentai, title: String, uploader: String = "", category: String = "", thumbnailURL: URL? = nil, sourceURL: URL? = nil, pageCount: Int = 0, tags: [String], rating: Double? = nil, postedAt: String? = nil) {
        self.init(id: id, source: source, title: title, uploader: uploader, category: category, thumbnailURL: thumbnailURL, sourceURL: sourceURL, pageCount: pageCount, tags: tags.map { GalleryTag.parse($0) }, rating: rating, postedAt: postedAt)
    }

    private enum CodingKeys: String, CodingKey { case id, source, title, uploader, category, thumbnailURL, sourceURL, pageCount, tags, rating, postedAt }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        source = try c.decodeIfPresent(EHSource.self, forKey: .source) ?? .eHentai
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
        uploader = try c.decodeIfPresent(String.self, forKey: .uploader) ?? ""
        category = try c.decodeIfPresent(String.self, forKey: .category) ?? ""
        thumbnailURL = try c.decodeIfPresent(URL.self, forKey: .thumbnailURL)
        sourceURL = try c.decodeIfPresent(URL.self, forKey: .sourceURL)
        pageCount = try c.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        if let structured = try? c.decode([GalleryTag].self, forKey: .tags) { tags = structured }
        else { tags = (try? c.decode([String].self, forKey: .tags))?.map { GalleryTag.parse($0) } ?? [] }
        rating = try c.decodeIfPresent(Double.self, forKey: .rating)
        postedAt = try c.decodeIfPresent(String.self, forKey: .postedAt)
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id); try c.encode(source, forKey: .source); try c.encode(title, forKey: .title); try c.encode(uploader, forKey: .uploader); try c.encode(category, forKey: .category); try c.encodeIfPresent(thumbnailURL, forKey: .thumbnailURL); try c.encodeIfPresent(sourceURL, forKey: .sourceURL); try c.encode(pageCount, forKey: .pageCount); try c.encode(tags, forKey: .tags); try c.encodeIfPresent(rating, forKey: .rating); try c.encodeIfPresent(postedAt, forKey: .postedAt)
    }
}

extension GalleryTag {
    static func parse(_ raw: String) -> GalleryTag {
        let parts = raw.split(separator: ":", maxSplits: 1).map(String.init)
        return parts.count == 2 ? GalleryTag(namespace: parts[0], key: parts[1]) : GalleryTag(key: raw)
    }
}

struct GalleryPage: Identifiable, Hashable {
    let id: Int
    let imageURL: URL
}

enum SiteError: LocalizedError {
    case invalidResponse, loginRequired, accessDenied, parseFailed, unsupportedSource, commentTooShort
    var errorDescription: String? {
        switch self { case .invalidResponse: return "站点返回格式异常"; case .loginRequired: return "请先登录"; case .accessDenied: return "站点拒绝了当前请求"; case .parseFailed: return "无法解析站点页面"; case .unsupportedSource: return "暂不支持该站点"; case .commentTooShort: return "评论内容至少需要 3 个字符" }
    }
}
