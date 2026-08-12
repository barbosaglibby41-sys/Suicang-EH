import Foundation

enum EHSource: String, Codable, CaseIterable, Identifiable, Hashable {
    case eHentai = "e-hentai"
    case exHentai = "exhentai"

    var id: String { rawValue }
    var title: String { self == .eHentai ? "E-Hentai" : "ExHentai" }
    var baseURL: URL { URL(string: self == .eHentai ? "https://e-hentai.org/" : "https://exhentai.org/")! }
    var cookieDomains: [String] { self == .eHentai ? ["e-hentai.org", ".e-hentai.org"] : ["exhentai.org", ".exhentai.org"] }
}

struct SiteConfiguration: Codable, Equatable {
    var source: EHSource = .eHentai
    var customBaseURL: URL? = nil
    var effectiveBaseURL: URL { customBaseURL ?? source.baseURL }
}
