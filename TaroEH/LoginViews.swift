import SwiftUI
import WebKit

struct WebLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    var body: some View {
        WebLoginRepresentable(source: EHSource(rawValue: sourceRaw) ?? .eHentai) { cookie in
            Task { @MainActor in
                session.save(cookie: cookie)
                await session.validate(source: EHSource(rawValue: sourceRaw) ?? .eHentai)
                if session.isLoggedIn { dismiss() }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("网页登录")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebLoginRepresentable: UIViewRepresentable {
    let source: EHSource
    let onLogin: (String) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onLogin: onLogin) }
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let store = WKWebsiteDataStore.nonPersistent()
        config.websiteDataStore = store
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        let request = URLRequest(url: URL(string: "https://forums.e-hentai.org/index.php?act=Login&CODE=00")!)
        web.load(request)
        return web
    }
    func updateUIView(_ web: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate {
        let onLogin: (String) -> Void
        init(onLogin: @escaping (String) -> Void) { self.onLogin = onLogin }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                let valid = cookies.filter { $0.domain.contains("e-hentai.org") || $0.domain.contains("exhentai.org") }
                if valid.contains(where: { $0.name == "ipb_member_id" }) && valid.contains(where: { $0.name == "ipb_pass_hash" }) {
                    let text = valid.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
                    DispatchQueue.main.async { self.onLogin(text) }
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                let valid = cookies.filter { $0.domain.contains("e-hentai.org") || $0.domain.contains("exhentai.org") }
                if valid.contains(where: { $0.name == "ipb_member_id" }) && valid.contains(where: { $0.name == "ipb_pass_hash" }) {
                    let text = valid.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
                    DispatchQueue.main.async { self.onLogin(text) }
                }
            }
        }
    }
}

struct CookieImportView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var showingAlert = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    var body: some View {
        Form {
            Section("Cookie 文本") {
                TextEditor(text: $text).frame(minHeight: 140)
                Text("支持 name=value; name2=value2，也支持从浏览器导出的 Cookie 文本。至少需要 ipb_member_id 和 ipb_pass_hash。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            if let errorMessage { Text(errorMessage).font(.footnote).foregroundStyle(.orange) }
            Button {
                let normalized = CookieTextParser.normalize(text)
                guard CookieTextParser.isUsable(normalized) else { showingAlert = true; return }
                isSaving = true
                session.save(cookie: normalized)
                Task {
                    await session.validate(source: EHSource(rawValue: sourceRaw) ?? .eHentai)
                    isSaving = false
                    if session.isLoggedIn { dismiss() } else { errorMessage = session.lastValidationMessage ?? "Cookie 验证失败" }
                }
            } label: {
                HStack { Text("保存并验证"); Spacer(); if isSaving { ProgressView().controlSize(.small) } }
            }.disabled(isSaving)
        }
        .navigationTitle("导入 Cookie")
        .alert("Cookie 格式似乎不正确", isPresented: $showingAlert) { Button("好", role: .cancel) {} }
    }
}

private enum CookieTextParser {
    static func normalize(_ text: String) -> String {
        let names = ["ipb_member_id", "ipb_pass_hash", "igneous", "sk", "nw", "datatags"]
        var result: [String] = []
        for name in names {
            let pattern = "(?:^|[;\\n\\t ])" + name + "\\s*[=:]\\s*([^;\\n\\t ]+)"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive), let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)), let range = Range(match.range(at: 1), in: text) {
                result.append("\(name)=\(String(text[range]))")
            }
        }
        return result.joined(separator: "; ")
    }
    static func isUsable(_ text: String) -> Bool { text.contains("ipb_member_id=") && text.contains("ipb_pass_hash=") }
}
