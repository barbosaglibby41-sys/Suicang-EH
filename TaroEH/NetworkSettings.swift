import SwiftUI

struct NetworkSettingsView: View {
    @AppStorage("taro.eh.siteURL") private var siteURL = "https://e-hentai.org/"
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    private var source: Binding<EHSource> {
        Binding(get: { EHSource(rawValue: sourceRaw) ?? .eHentai }, set: { value in sourceRaw = value.rawValue; siteURL = value.baseURL.absoluteString })
    }
    var body: some View {
        Form {
            Section("站点") {
                Picker("当前站点", selection: source) { ForEach(EHSource.allCases) { Text($0.title).tag($0) } }
                TextField("自定义站点主页地址", text: $siteURL).textInputAutocapitalization(.never).keyboardType(.URL)
                Text("ExHentai 需要登录后才能访问；自定义地址仅用于你有权使用的 HTTPS 站点。") .font(.footnote).foregroundStyle(.secondary)
            }
            Section("安全") {
                Label("系统 HTTPS 证书验证", systemImage: "lock.shield")
                Text("不关闭 TLS 校验、不使用域前置或证书绕过。") .font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("网络")
    }
}
