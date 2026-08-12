import Foundation
import Security

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var isLoggedIn = false
    private let key = "taro_eh_cookie"

    init() {
        if let cookie = KeychainStore.read(key: key) { installCookies(from: cookie); isLoggedIn = true }
        else { isLoggedIn = false }
    }

    func save(cookie: String) {
        let cleaned = cookie.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        KeychainStore.write(key: key, value: cleaned)
        installCookies(from: cleaned)
        isLoggedIn = true
    }

    func clear() {
        KeychainStore.delete(key: key)
        HTTPCookieStorage.shared.cookies?.filter { $0.domain.contains("e-hentai.org") || $0.domain.contains("exhentai.org") }.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        isLoggedIn = false
    }

    func cookieHeader() -> String? { KeychainStore.read(key: key) }

    private func installCookies(from header: String) {
        for pair in header.split(separator: ";") {
            let pieces = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard pieces.count == 2 else { continue }
            for domain in ["e-hentai.org", "exhentai.org"] {
                if let cookie = HTTPCookie(properties: [.domain: domain, .path: "/", .name: pieces[0].trimmingCharacters(in: .whitespaces), .value: pieces[1].trimmingCharacters(in: .whitespaces)]) { HTTPCookieStorage.shared.setCookie(cookie) }
            }
        }
    }
}

enum KeychainStore {
    static func write(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
        var item = query
        item[kSecValueData as String] = data
        SecItemAdd(item as CFDictionary, nil)
    }
    static func read(key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key,
                                     kSecReturnData as String: true,
                                     kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    static func delete(key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }
}
