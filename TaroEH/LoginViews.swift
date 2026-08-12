import SwiftUI
import WebKit

struct WebLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    var body: some View {
        WebLoginRepresentable(source: EHSource(rawValue: sourceRaw) ?? .eHentai) { cookie in
            session.save(cookie: cookie)
            dismiss()
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
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.load(URLRequest(url: source.baseURL))
        return web
    }
    func updateUIView(_ web: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate {
        let onLogin: (String) -> Void
        init(onLogin: @escaping (String) -> Void) { self.onLogin = onLogin }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                let valid = cookies.filter { $0.domain.contains("e-hentai.org") || $0.domain.contains("exhentai.org") }
                guard !valid.isEmpty else { return }
                let text = valid.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
                DispatchQueue.main.async { self.onLogin(text) }
            }
        }
    }
}

struct CookieImportView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var text = ""
    @State private var showingAlert = false
    var body: some View {
        Form {
            Section("Cookie 文本") {
                TextEditor(text: $text).frame(minHeight: 140)
                Text("粘贴 name=value; name2=value2 格式。不要把 Cookie 发给他人。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Button("保存到本机 Keychain") {
                guard text.contains("=") else { showingAlert = true; return }
                session.save(cookie: text); text = ""
            }
        }
        .navigationTitle("导入 Cookie")
        .alert("Cookie 格式似乎不正确", isPresented: $showingAlert) { Button("好", role: .cancel) {} }
    }
}
