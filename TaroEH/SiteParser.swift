import Foundation

struct NetworkGalleryDetail {
    var gallery: Gallery
    var pageLinks: [URL]
}

enum SiteParser {
    static func galleries(from html: String, source: EHSource = .eHentai, baseURL: URL? = nil) -> [Gallery] {
        let pattern = #"(?s)<a[^>]+href=[\"']([^\"']*/g/(\d+)/[^\"']+)[\"'][^>]*>\s*<div[^>]+class=[\"'][^\"']*glink[^\"']*[\"'][^>]*>(.*?)</div>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = html as NSString; var seen = Set<Int>()
        let thumbs = thumbnailMap(from: html, baseURL: baseURL)
        return regex.matches(in: html, range: NSRange(location: 0, length: ns.length)).compactMap { match in
            guard match.numberOfRanges > 3, let id = Int(ns.substring(with: match.range(at: 2))), seen.insert(id).inserted else { return nil }
            let title = clean(ns.substring(with: match.range(at: 3)))
            guard !title.isEmpty else { return nil }
            let href = decode(ns.substring(with: match.range(at: 1)))
            return Gallery(id: id, source: source, title: title, uploader: "网络结果", category: "", thumbnailURL: thumbs[id], sourceURL: URL(string: href), pageCount: 0, tags: [GalleryTag]())
        }
    }

    static func detail(from html: String, sourceURL: URL, fallback: Gallery) -> NetworkGalleryDetail {
        var gallery = fallback; gallery.sourceURL = sourceURL
        gallery.title = first(#"id=[\"']gn[\"'][^>]*>(.*?)</"#, in: html).map(clean) ?? gallery.title
        gallery.category = first(#"id=[\"']gdc[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: html).map(clean) ?? gallery.category
        gallery.uploader = first(#"id=[\"']gdn[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: html).map(clean) ?? gallery.uploader
        if let pages = first(#"([0-9,]+)\s+pages"#, in: html)?.replacingOccurrences(of: ",", with: ""), let count = Int(pages) { gallery.pageCount = count }
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
    static func imageURL(from html: String) -> URL? { first(#"id=[\"']img[\"'][^>]+src=[\"']([^\"']+)[\"']"#, in: html).flatMap { URL(string: decode($0)) } }

    private static func thumbnailMap(from html: String, baseURL: URL?) -> [Int: URL] {
        let pattern = #"(?s)<a[^>]+href=[\"'][^\"']*/g/(\d+)/[^\"']+[\"'][^>]*>\s*<img[^>]+(?:data-src|src)=[\"']([^\"']+)[\"']"#
        var map: [Int: URL] = [:]
        for values in allGroups(pattern, in: html, groups: 2) {
            guard values.count == 2, let id = Int(values[0]), let url = URL(string: decode(values[1]), relativeTo: baseURL)?.absoluteURL else { continue }
            map[id] = url
        }
        return map
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
        return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { match in (1...min(groups, match.numberOfRanges - 1)).map { ns.substring(with: match.range(at: $0)) } }
    }
    private static func clean(_ text: String) -> String { decode(text).replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines) }
    private static func decode(_ text: String) -> String { text.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&#039;", with: "'").replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&#x27;", with: "'") }
}
