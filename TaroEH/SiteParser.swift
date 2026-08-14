import Foundation

struct NetworkGalleryDetail {
    var gallery: Gallery
    var pageLinks: [URL]
    var comments: [GalleryComment] = []
}

private struct GalleryListMetadata {
    var thumbnailURL: URL?
    var pageCount = 0
    var rating: Double?
    var category = ""
    var postedAt: String?
    var uploader = ""
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
                uploader: item.uploader.isEmpty ? "未知作者" : item.uploader,
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

    static func detail(from html: String, sourceURL: URL, fallback: Gallery, includePageLinks: Bool = true) -> NetworkGalleryDetail {
        var gallery = fallback
        gallery.sourceURL = sourceURL
        gallery.title = first(#"id=[\"']gn[\"'][^>]*>(.*?)</"#, in: html).map(clean) ?? gallery.title
        gallery.category = first(#"id=[\"']gdc[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: html).map(clean) ?? gallery.category
        gallery.uploader = first(#"id=[\"']gdn[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: html).map(clean) ?? gallery.uploader
        if let pages = first(#"([0-9,]+)\s+pages"#, in: html)?.replacingOccurrences(of: ",", with: ""), let count = Int(pages) { gallery.pageCount = count }
        if let rating = first(#"Average:\s*([0-9]+(?:\.[0-9]+)?)"#, in: html), let value = Double(rating) { gallery.rating = value }
        if let posted = first(#"(?s)<td[^>]*class=[\"']gdt1[\"'][^>]*>\s*Posted:\s*</td>\s*<td[^>]*class=[\"']gdt2[\"'][^>]*>(.*?)</td>"#, in: html)?.trimmingCharacters(in: .whitespacesAndNewlines), !posted.isEmpty { gallery.postedAt = posted }
        if let language = first(#"(?s)<td[^>]*class=[\"']gdt1[\"'][^>]*>\s*Language:\s*</td>\s*<td[^>]*class=[\"']gdt2[\"'][^>]*>(.*?)</td>"#, in: html).map(clean), !language.isEmpty { gallery.language = language }
        if let fileSize = first(#"(?s)<td[^>]*class=[\"']gdt1[\"'][^>]*>\s*File Size:\s*</td>\s*<td[^>]*class=[\"']gdt2[\"'][^>]*>(.*?)</td>"#, in: html).map(clean), !fileSize.isEmpty { gallery.fileSize = fileSize }
        if let favorites = first(#"id=[\"']favcount[\"'][^>]*>\s*([0-9,]+)\s+times"#, in: html).flatMap({ Int($0.replacingOccurrences(of: ",", with: "")) }) { gallery.favoriteCount = favorites }
        if let ratings = first(#"id=[\"']rating_count[\"'][^>]*>\s*([0-9,]+)\s*</"#, in: html).flatMap({ Int($0.replacingOccurrences(of: ",", with: "")) }) { gallery.ratingCount = ratings }
        if let cover = first(#"url\((https?[^)]+)\)"#, in: html) { gallery.thumbnailURL = URL(string: decode(cover)) }
        let rawTags = all(#"id=[\"']ta_([^\"']+)[\"']"#, in: html)
        gallery.tags = Array(Set(rawTags.map { GalleryTag.parse(decode($0)) })).sorted { $0.rawName < $1.rawName }
        gallery.comments = comments(from: html)
        gallery.previews = previews(from: html)
        if let torrent = first(#"href=[\"'](https?://[^\"']+\.torrent)[\"']"#, in: html), let url = URL(string: decode(torrent)) { gallery.torrentURL = url }
        let links = includePageLinks ? imagePageLinks(from: html, base: sourceURL) : []
        return NetworkGalleryDetail(gallery: gallery, pageLinks: links)
    }

    /// Parses the thumbnail sprite sheet in `#gdt`: each entry is a 200px-wide
    /// tile of one sprite image. Tile heights vary (landscape pages are
    /// shorter, long strips taller), so width/height/offsets are all captured.
    static func previews(from html: String, limit: Int = 20) -> [PagePreview] {
        guard let region = html.range(of: #"id="gdt""#, options: [.caseInsensitive]) else { return [] }
        let start = region.lowerBound
        let end = html.range(of: #"id="gdo""#, options: [.caseInsensitive], range: start..<html.endIndex)?.lowerBound ?? html.endIndex
        let segment = String(html[start..<end])
        let pattern = #"<a href="([^"]*/s/[^"]+)"[^>]*><div title="Page (\d+):[^"]*" style="[^"]*width:(\d+)px;height:(\d+)px;background:transparent url\(([^)]+)\)\s*(-?\d+)px\s+(-?\d+) no-repeat""#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = segment as NSString
        var seen = Set<Int>()
        return regex.matches(in: segment, range: NSRange(location: 0, length: ns.length)).compactMap { match in
            guard match.numberOfRanges > 6,
                  let page = Int(ns.substring(with: match.range(at: 2))),
                  seen.insert(page).inserted,
                  let width = Int(ns.substring(with: match.range(at: 3))),
                  let height = Int(ns.substring(with: match.range(at: 4))),
                  let sprite = URL(string: decode(ns.substring(with: match.range(at: 5)))),
                  let pageURL = URL(string: decode(ns.substring(with: match.range(at: 1)))),
                  let x = Int(ns.substring(with: match.range(at: 6))),
                  let y = Int(ns.substring(with: match.range(at: 7))) else { return nil }
            return PagePreview(page: page, spriteURL: sprite, xOffset: abs(x), yOffset: abs(y), width: width, height: height, pageURL: pageURL)
        }.sorted { $0.page < $1.page }.prefix(limit).map { $0 }
    }

    /// Parses the comment section (`#cdiv`). Returns comments in page order.
    /// Only the cdiv→chd region is scanned so long gallery pages stay fast.
    static func comments(from html: String) -> [GalleryComment] {
        guard let region = html.range(of: #"id="cdiv""#, options: [.caseInsensitive]) else { return [] }
        let start = region.lowerBound
        let end = html.range(of: #"id="chd""#, options: [.caseInsensitive], range: start..<html.endIndex)?.lowerBound ?? html.endIndex
        let segment = String(html[start..<end])
        let blockPattern = #"<div class="c1">(?:(?!<div class="c1">|<div id="chd").)*"#
        guard let regex = try? NSRegularExpression(pattern: blockPattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else { return [] }
        let ns = segment as NSString
        return regex.matches(in: segment, range: NSRange(location: 0, length: ns.length)).compactMap { match in
            let block = ns.substring(with: match.range)
            guard let content = first(#"<div class="c6" id="comment_\d+">(.*?)</div>"#, in: block) else { return nil }
            let author = first(#"by:?\s*&nbsp;\s*<a[^>]*>(.*?)</a>"#, in: block).map(clean) ?? "匿名"
            let postedAt = first(#"Posted on (.*?) by"#, in: block).map(clean) ?? ""
            let score = first(#"<span id="comment_score_\d+"[^>]*>([+-]?\d+)</span>"#, in: block).flatMap { Int($0) }
            let commentID = first(#"id="comment_(\d+)""#, in: block).flatMap { Int($0) } ?? 0
            let votes = first(#"<div class="c7" id="cvotes_\d+"[^>]*>(.*?)</div>"#, in: block).map(clean)
            let isUploader = block.contains("Uploader Comment")
            return GalleryComment(id: commentID, author: author, postedAt: postedAt, score: score, isUploader: isUploader, content: htmlToText(content), votes: votes)
        }
    }

    /// Converts comment HTML into readable text: <br> becomes newlines, links
    /// keep their label, and HTML entities are decoded.
    static func htmlToText(_ html: String) -> String {
        let withBreaks = html.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: .regularExpression, range: nil)
        let noTags = withBreaks.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let trimmed = noTags.replacingOccurrences(of: "[ \t]+\n", with: "\n", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return decode(trimmed)
    }

    static func toplistNextPage(from html: String, currentPage: Int) -> Int? {
        let pages = all(#"href=[\"'][^\"']*toplist\.php[^\"']*[?&]p=(\d+)[^\"']*[\"']"#, in: html)
            .compactMap(Int.init)
            .filter { $0 > currentPage }
        return pages.min()
    }
    static func nextGalleryCursor(from html: String) -> Int? {
        guard let href = first(#"id=[\"']dnext[\"'][^>]+href=[\"']([^\"']+)[\"']"#, in: html),
              let url = URL(string: decode(href)),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let value = components.queryItems?.first(where: { $0.name == "next" })?.value else { return nil }
        return Int(value)
    }

    static func galleriesPage(from html: String, source: EHSource, baseURL: URL?) -> (galleries: [Gallery], nextCursor: Int?) {
        (galleries(from: html, source: source, baseURL: baseURL), nextGalleryCursor(from: html))
    }
    static func torrentURL(from html: String) -> URL? {
        first(#"href=[\"'](https?://[^\"']+\.torrent)[\"']"#, in: html).flatMap { URL(string: decode($0)) }
    }

    static func imagePageLinks(from html: String, base: URL) -> [URL] {
        let pattern = #"href=[\"']([^\"']*s/[0-9a-zA-Z]+/[0-9]+-[0-9]+)[\"']"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = html as NSString
        let urls = Array(Set(regex.matches(in: html, range: NSRange(location: 0, length: ns.length)).compactMap { URL(string: ns.substring(with: $0.range(at: 1)), relativeTo: base)?.absoluteURL }))
        return urls.sorted {
            let leftPage = pageNumber(in: $0)
            let rightPage = pageNumber(in: $1)
            if leftPage != rightPage { return leftPage < rightPage }
            return $0.absoluteString < $1.absoluteString
        }
    }

    static func imageReloadKey(from html: String) -> String? {
        first(#"id=[\"']loadfail[\"'][^>]+onclick=[\"'][^\"']*nl\\(\\'([^\\']+)\\'\\)[^\"']*[\"']"#, in: html)
    }


    private static func pageNumber(in url: URL) -> Int {
        let component = url.path.split(separator: "/").last.map(String.init) ?? ""
        // E-Hentai page links end with <galleryID>-<page>, e.g. 4111359-10.
        // The suffix after the final hyphen is the actual page number.
        guard let separator = component.lastIndex(of: "-") else { return Int.max }
        let suffix = component[component.index(after: separator)...]
        return Int(suffix) ?? Int.max
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
            let end = (remaining as NSString).range(of: "</td>", options: [.caseInsensitive]).location
            let block = end == NSNotFound ? remaining : String(remaining.prefix(end))
            let row = String(remaining.prefix((remaining as NSString).range(of: "</tr>", options: [.caseInsensitive]).location == NSNotFound ? remaining.count : (remaining as NSString).range(of: "</tr>", options: [.caseInsensitive]).location))

            let rawImage = first(#"data-src=[\"']([^\"']+)[\"']"#, in: block) ?? first(#"<img[^>]+src=[\"']([^\"']+)[\"']"#, in: block)
            let thumbnailURL = rawImage.flatMap { URL(string: decode($0), relativeTo: baseURL)?.absoluteURL }
            let pageCount = first(#"([0-9,]+)\s+pages"#, in: block)
                .map { $0.replacingOccurrences(of: ",", with: "") }
                .flatMap(Int.init) ?? 0
            let category = first(#"class=[\"'][^\"']*cn[^\"']*[\"'][^>]*>(.*?)</div>"#, in: block).map(clean) ?? ""
            let postedAt = first(#"id=[\"']postedpop_\d+[\"'][^>]*>(.*?)</div>"#, in: block).map(clean)
            let uploader = first(#"class=[\"']gl4c[^\"']*[\"'][^>]*>.*?<a[^>]*>(.*?)</a>"#, in: row).map(clean) ?? ""
            values[id] = GalleryListMetadata(
                thumbnailURL: thumbnailURL,
                pageCount: pageCount,
                rating: spriteRating(from: block),
                category: category,
                postedAt: postedAt,
                uploader: uploader
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
