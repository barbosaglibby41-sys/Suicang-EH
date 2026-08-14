import Foundation

/// Parsers for the HTML returned by the account favorites pages.
/// The site uses the same gallery anchors as discovery pages, but older
/// layouts omit the glink class, so this parser intentionally has a fallback.
enum CloudFavoritesParser {
    static func page(from html: String, source: EHSource, baseURL: URL) -> CloudFavoritePage {
        let categories = parseCategories(html)
        let galleries = parseGalleries(html, source: source, baseURL: baseURL)
        let nextURL = firstURL(#"<a[^>]+class=[\"'][^\"']*dnext[^\"']*[\"'][^>]+href=[\"']([^\"']+)[\"']"#, in: html, baseURL: baseURL)
            ?? firstURL(#"<a[^>]+href=[\"']([^\"']+)[\"'][^>]*>\s*(?:Next|下一页)\s*</a>"#, in: html, baseURL: baseURL)
        return CloudFavoritePage(categories: categories, galleries: galleries, nextURL: nextURL)
    }

    private static func parseCategories(_ html: String) -> [CloudFavoriteCategory] {
        var output: [CloudFavoriteCategory] = []
        let optionPattern = #"<option[^>]+value=[\"'](\d+)[\"'][^>]*>(.*?)</option>"#
        for values in allGroups(optionPattern, in: html, groups: 2) where values.count == 2 {
            if let id = Int(values[0]), id >= 0 && id <= 9 {
                let name = clean(values[1])
                if !name.isEmpty { output.append(CloudFavoriteCategory(id: id, name: name)) }
            }
        }
        // E-Hentai's current favorites page renders the ten folders as .fp
        // links rather than <option> elements.
        let folderPattern = #"(?s)<a[^>]+href=[\"'][^\"']*[?&]favcat=(\d+)[^\"']*[\"'][^>]*>(.*?)</a>"#
        for values in allGroups(folderPattern, in: html, groups: 2) where values.count == 2 {
            if let id = Int(values[0]), id >= 0 && id <= 9 {
                let raw = clean(values[1])
                let name = raw.replacingOccurrences(of: "^\\d+\\s*", with: "", options: .regularExpression)
                if !name.isEmpty && !output.contains(where: { $0.id == id }) { output.append(CloudFavoriteCategory(id: id, name: name) ) }
            }
        }
        return output.sorted { $0.id < $1.id }
    }

    private static func parseGalleries(_ html: String, source: EHSource, baseURL: URL) -> [Gallery] {
        let pattern = #"(?s)<a[^>]+href=[\"']([^\"']*/g/(\d+)/[^\"']+)[\"'][^>]*>(.*?)</a>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = html as NSString
        var seen = Set<Int>()
        return regex.matches(in: html, range: NSRange(location: 0, length: ns.length)).compactMap { match in
            guard match.numberOfRanges > 3,
                  let id = Int(ns.substring(with: match.range(at: 2))),
                  seen.insert(id).inserted else { return nil }
            let body = ns.substring(with: match.range(at: 3))
            let title = clean(first(#"class=[\"'][^\"']*(?:glink|glname)[^\"']*[\"'][^>]*>(.*?)</(?:div|a)>"#, in: body) ?? body)
            guard !title.isEmpty else { return nil }
            let href = decode(ns.substring(with: match.range(at: 1)))
            let thumbnail = first(#"(?:data-src|src)=[\"']([^\"']+)[\"']"#, in: body).flatMap { URL(string: decode($0), relativeTo: baseURL)?.absoluteURL }
            return Gallery(id: id, source: source, title: title, uploader: "账户收藏", thumbnailURL: thumbnail, sourceURL: URL(string: href, relativeTo: baseURL)?.absoluteURL)
        }
    }

    private static func allGroups(_ pattern: String, in text: String, groups: Int) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let ns = text as NSString
        return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { match in
            (1...min(groups, match.numberOfRanges - 1)).map { ns.substring(with: match.range(at: $0)) }
        }
    }

    private static func firstURL(_ pattern: String, in text: String, baseURL: URL) -> URL? {
        first(pattern, in: text).flatMap { URL(string: decode($0), relativeTo: baseURL)?.absoluteURL }
    }
    private static func first(_ pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let ns = text as NSString
        return regex.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)).flatMap {
            $0.numberOfRanges > 1 ? ns.substring(with: $0.range(at: 1)) : nil
        }
    }
    private static func clean(_ text: String) -> String {
        decode(text).replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private static func decode(_ text: String) -> String {
        text.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'").replacingOccurrences(of: "&#x27;", with: "'")
    }
}
