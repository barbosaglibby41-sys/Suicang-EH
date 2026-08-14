import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        List {
            Section("账户") {
                NavigationLink { CloudFavoritesView() } label: { Label("账户收藏", systemImage: session.isLoggedIn ? "cloud.fill" : "cloud") }
                NavigationLink { WebLoginView() } label: { Label("网页登录", systemImage: "globe") }
                NavigationLink { CookieImportView() } label: { Label("导入 Cookie", systemImage: "key.fill") }
                if session.isLoggedIn {
                    Button("清除本机登录", role: .destructive) { session.clear() }
                }
            }
            Section("阅读") {
                NavigationLink { ReaderSettingsView() } label: { Label("阅读设置", systemImage: "book.fill") }
                NavigationLink { GalleryListSettingsView() } label: { Label("画廊列表样式", systemImage: "rectangle.grid.2x2") }
            }
            Section("离线") {
                NavigationLink { DownloadSettingsView() } label: { Label("下载设置", systemImage: "arrow.down.circle") }
                NavigationLink { CacheSettingsView() } label: { Label("缓存管理", systemImage: "internaldrive") }
            }
            Section("搜索") {
                NavigationLink { TagTranslationSettingsView() } label: { Label("标签翻译库", systemImage: "tag.fill") }
            }
            Section("网络") {
                NavigationLink { NetworkSettingsView() } label: { Label("网络设置", systemImage: "network") }
            }
            Section("关于") {
                LabeledContent("版本", value: "1.7.66")
                Text("JHenTai 架构参考：Apache-2.0，完整许可证随源代码提供。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("设置")
    }
}
