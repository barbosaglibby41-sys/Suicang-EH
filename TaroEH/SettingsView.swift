import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        List {
            Section("账户") {
                NavigationLink("网页登录") { WebLoginView() }
                NavigationLink("导入 Cookie") { CookieImportView() }
                if session.isLoggedIn { Button("清除本机登录") { session.clear() }.foregroundStyle(.red) }
            }
            Section("离线") {
                NavigationLink("下载设置") { DownloadSettingsView() }
                NavigationLink("阅读设置") { ReaderSettingsView() }
                NavigationLink("缓存管理") { CacheSettingsView() }
            }
            Section("搜索") {
                NavigationLink("标签翻译库") { TagTranslationSettingsView() }
            }
            Section("应用") {
                NavigationLink("网络") { NetworkSettingsView() }
                Label("直连模式", systemImage: "network")
                Text("不使用第三方中转服务器。Cookie 仅保存在本机 Keychain。网络功能与标签翻译库均支持本地回退。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("关于") { LabeledContent("版本", value: "1.7.22"); Text("JHenTai 架构参考：Apache-2.0，完整许可证随源代码提供。") .font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("设置")
    }
}
