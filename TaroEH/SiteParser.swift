import Foundation

struct NetworkGalleryDetail {
    var gallery: Gallery
    var pageLinks: [URL]
}

private struct GalleryListMetadata {
    var thumbnailURL: URL?
    var pageCount = 0
    var rating: Double?
    var category = ""
    var postedAt: String?
}

enum SiteParser {
    static func galleries(from html: String, source: EHSource = .eHentai, baseURL: URL? = nil) -> [Gallery] {
        let pattern = #"(?s)<a[^>]+href=[\"']([^\"']*/g/(\d+)/[^\"']+)[\"'][^>]*>\s*<div[^>]+class=[\"'][^\"']*glink[^\"']*[\"'][^>]*>(.*?)</div>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = html as NSString
        let metadata = listMetadata(from: html, baseURL: baseURL)
        var seen = Set<Int>()

        return regex.matches(in: html, range: NSRange(location: 0, length: ns.length)).compactMap { match in
            guard match.numberOfRanges > 3,
                  let id = Int(ns.substring(with: match.range(at: 2))),
                  seen.insert(id).inserted else { return nil }
            let title = clean(ns.substring(with: match.range(at: 3)))
            guard !title.isEmpty else { return nil }
            let href = decode(ns.substring(with: match.range(at: 1)))
            let item = metadata[id] ?? GalleryListMetadata()
            return Gallery(
                id: id,
                source: source,
                title: title,
                uploader: "网络结果",
                category: item.category,
                thumbnailURL: item.thumbnailURL,
                sourceURL: URL(string: href),
                pageCount: item.pageCount,
                tags: [GalleryTag](),
                rating: item.rating,
                postedAt: item.postedAt
            )
        }
    }

    static func detail(from html: String, sourceURL: URL, fallback: Gallery) -> NetworkGalleryDetail {
        var gallery = fallback
        gallery.sourceURL = sourceURL
        gallery.title = first(#"id=[\"']gn[\"'][^>]*>(.*?)</"#, in: html).map(clean) ?? gallery.title
        gallery.category = first(#"id=[\"']gdc[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: html).map(clean) ?? gallery.category
        gallery.uploader = first(#"id=[\"']gdn[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: html).map(clean) ?? gallery.uploader
        if let pages = first(#"([0-9,]+)\s+pages"#, in: html)?.replacingOccurrences(of: ",", with: ""), let count = Int(pages) { gallery.pageCount = count }
        if let rating = first(#"Average:\s*([0-9]+(?:\.[0-9]+)?)"#, in: html), let value = Double(rating) { gallery.rating = value }
        if let cover = first(#"url\((https?[^)]+)\)"#, in: html) { gallery.thumbnailURL = URL(string: decode(cover)) }
        let rawTags = all(#"id=[\"']ta_([^\"']+)[\"']"#, in: html)
        gallery.tags = Array(Set(rawTags.map { GalleryTag.parse(decode($0)) })).sorted { $0.rawName < $1.rawName }
        return NetworkGalleryDetail(gallery: gallery, pageLinks: imagePageLinks(from: html, base: sourceURL))
    }

    static func imagePageLinks(from html: String, base: URL) -> [URL] {
        let pattern = #"href=[\"']([^\"']*s/[0-9a-zA-Z]+/[0-9]+-[0-9]+)[\"']"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = html as NSString
        return Array(Set(regex.matches(in: html, range: NSRange(location: 0, length: ns.length)).compactMap { URL(string: ns.substring(with: $0.range(at: 1)), relativeTo: base)?.absoluteURL })).sorted { $0.absoluteString < $1.absoluteString }
    }

    static func imageURL(from html: String) -> URL? {
        first(#"id=[\"']img[\"'][^>]+src=[\"']([^\"']+)[\"']"#, in: html).flatMap { URL(string: decode($0)) }
    }

    private static func listMetadata(from html: String, baseURL: URL?) -> [Int: GalleryListMetadata] {
        let idPattern = #"id=[\"']it(\d+)[\"']"#
        guard let regex = try? NSRegularExpression(pattern: idPattern, options: [.caseInsensitive]) else { return [:] }
        let ns = html as NSString
        var values: [Int: GalleryListMetadata] = [:]

        for match in regex.matches(in: html, range: NSRange(location: 0, length: ns.length)) {
            guard match.numberOfRanges > 1, let id = Int(ns.substring(with: match.range(at: 1))) else { continue }
            let start = match.range.location
            let remaining = ns.substring(from: start)
            let end = remaining.range(of: "</td>", options: [.caseInsensitive]).location
            let block = end == NSNotFound ? remaining : String(remaining.prefix(end))

            let rawImage = first(#"data-src=[\"']([^\"']+)[\"']"#, in: block) ?? first(#"<img[^>]+src=[\"']([^\"']+)[\"']"#, in: block)
            let thumbnailURL = rawImage.flatMap { URL(string: decode($0), relativeTo: baseURL)?.absoluteURL }
            let pageCount = first(#"([0-9,]+)\s+pages"#, in: block)
                .map { $0.replacingOccurrences(of: ",", with: "") }
                .flatMap(Int.init) ?? 0
            let category = first(#"class=[\"'][^\"']*cn[^\"']*[\"'][^>]*>(.*?)</div>"#, in: block).map(clean) ?? ""
            let postedAt = first(#"id=[\"']postedpop_\d+[\"'][^>]*>(.*?)</div>"#, in: block).map(clean)
            values[id] = GalleryListMetadata(
                thumbnailURL: thumbnailURL,
                pageCount: pageCount,
                rating: spriteRating(from: block),
                category: category,
                postedAt: postedAt
            )
        }
        return values
    }

    /// E-Hentai's 80px star sprite stores a full star in x and a half star in y.
    private static func spriteRating(from html: String) -> Double? {
        let pattern = #"class=[\"'][^\"']*\bir\b[^\"']*[\"'][^>]*style=[\"'][^\"']*background-position:\s*(-?\d+)px\s+(-?\d+)px"#
        guard let values = allGroups(pattern, in: html, groups: 2).first,
              values.count == 2,
              let x = Int(values[0]),
              let y = Int(values[1]) else { return nil }
        let rating = 5.0 - Double(-x) / 16.0 - (y == -21 ? 0.5 : 0.0)
        return max(0, min(5, rating))
    }

    private static func first(_ pattern: String, in text: String) -> String? { all(pattern, in: text).first }
    private static func all(_ pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = text as NSString
        return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).compactMap { $0.numberOfRanges > 1 ? ns.substring(with: $0.range(at: 1)) : nil }
    }
    private static func allGroups(_ pattern: String, in text: String, groups: Int) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = text as NSString
        return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { match in
            (1...min(groups, match.numberOfRanges - 1)).map { ns.substring(with: match.range(at: $0)) }
        }
    }
    private static func clean(_ text: String) -> String {
        decode(text).replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private static func decode(_ text: String) -> String {
        text.replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#x27;", with: "'")
    }
}
