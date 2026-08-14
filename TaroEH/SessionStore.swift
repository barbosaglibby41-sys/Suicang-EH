import Foundation
import Security
import SwiftUI

enum SessionStatus: Equatable {
    case signedOut
    case checking
    case signedIn
    case invalid
}

struct SessionCookieItem: Identifiable, Hashable {
    let name: String
    let value: String
    var id: String { name }
}

struct AccountValidationResult {
    let authenticated: Bool
    let username: String?
    let site: EHSource
    let message: String
}

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var isLoggedIn = false
    @Published private(set) var status: SessionStatus = .signedOut
    @Published private(set) var accountName: String?
    @Published private(set) var exAccess: Bool?
    @Published private(set) var isChecking = false
    @Published private(set) var lastValidationMessage: String?
    private let key = "taro_eh_cookie"

    var hasCredentials: Bool {
        guard let header = cookieHeader() else { return false }
        let names = Set(header.split(separator: ";").compactMap { $0.split(separator: "=", maxSplits: 1).first.map(String.init) })
        return names.contains("ipb_member_id") && names.contains("ipb_pass_hash")
    }

    var cookieItems: [SessionCookieItem] {
        guard let header = cookieHeader() else { return [] }
        return header.split(separator: ";").compactMap { pair in
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2, !parts[0].trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
            return SessionCookieItem(name: parts[0].trimmingCharacters(in: .whitespaces), value: parts[1].trimmingCharacters(in: .whitespaces))
        }
    }

    init() {
        if let cookie = KeychainStore.read(key: key) {
            installCookies(from: cookie)
            isLoggedIn = hasCredentials
            status = hasCredentials ? .checking : .invalid
            accountName = memberID(from: cookie)
        }
    }

    func save(cookie: String) {
        let cleaned = cookie.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        KeychainStore.write(key: key, value: cleaned)
        installCookies(from: cleaned)
        isLoggedIn = hasCredentials
        status = hasCredentials ? .checking : .invalid
        accountName = memberID(from: cleaned)
        lastValidationMessage = nil
    }

    func clear() {
        KeychainStore.delete(key: key)
        HTTPCookieStorage.shared.cookies?.filter { $0.domain.contains("e-hentai.org") || $0.domain.contains("exhentai.org") }.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        isLoggedIn = false
        status = .signedOut
        accountName = nil
        exAccess = nil
        lastValidationMessage = nil
    }

    func cookieHeader() -> String? { KeychainStore.read(key: key) }

    func statusText(for source: EHSource) -> String {
        if !hasCredentials { return "未保存有效的站点 Cookie" }
        if isChecking { return "正在验证 \(source.title) 会话…" }
        if source == .exHentai {
            return exAccess == true ? "ExHentai 里站可访问" : (lastValidationMessage ?? "里站尚未验证")
        }
        return lastValidationMessage ?? (isLoggedIn ? "E-Hentai 会话有效" : "会话需要重新登录")
    }

    func validate(source: EHSource) async {
        guard hasCredentials, !isChecking else { return }
        isChecking = true
        status = .checking
        defer { isChecking = false }
        do {
            let result = try await SiteClient.shared.validateAccount(source: source, cookieHeader: cookieHeader())
            if source == .exHentai { exAccess = result.authenticated }
            if result.authenticated {
                isLoggedIn = true
                status = .signedIn
                accountName = result.username ?? accountName
                lastValidationMessage = result.message
            } else {
                isLoggedIn = false
                status = .invalid
                lastValidationMessage = result.message
            }
        } catch {
            if source == .exHentai { exAccess = false }
            isLoggedIn = false
            status = .invalid
            lastValidationMessage = "验证失败：\(error.localizedDescription)"
        }
    }

    func refreshExHentaiCookie() async {
        guard hasCredentials, let header = cookieHeader() else { return }
        do {
            if let refreshed = try await SiteClient.shared.refreshExHentaiCookie(cookieHeader: header) {
                save(cookie: refreshed)
                await validate(source: .exHentai)
            } else {
                lastValidationMessage = "未获取到新的 igneous，可能需要重新网页登录。"
            }
        } catch {
            lastValidationMessage = "刷新 igneous 失败：\(error.localizedDescription)"
        }
    }

    private func memberID(from header: String) -> String? {
        cookieItems(from: header).first(where: { $0.name == "ipb_member_id" })?.value
    }

    private func cookieItems(from header: String) -> [SessionCookieItem] {
        header.split(separator: ";").compactMap { pair in
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return nil }
            return SessionCookieItem(name: parts[0].trimmingCharacters(in: .whitespaces), value: parts[1].trimmingCharacters(in: .whitespaces))
        }
    }

    private func installCookies(from header: String) {
        for item in cookieItems(from: header) {
            for domain in ["e-hentai.org", "exhentai.org"] {
                if let cookie = HTTPCookie(properties: [.domain: domain, .path: "/", .name: item.name, .value: item.value]) { HTTPCookieStorage.shared.setCookie(cookie) }
            }
        }
    }
}

enum KeychainStore {
    static func write(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
        var item = query; item[kSecValueData as String] = data
        SecItemAdd(item as CFDictionary, nil)
    }
    static func read(key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key, kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    static func delete(key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }
}
