import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        ZStack {
            TaroPageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 13) {
                        TaroAvatar(icon: "gearshape.fill")
                        VStack(alignment: .leading, spacing: 3) {
                            Text("设置").font(.largeTitle.weight(.bold))
                            Text("把芋头调整成你的阅读空间").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    settingsCard(title: "账户", icon: "person.crop.circle.fill", tint: TaroTheme.accent) {
                        NavigationLink { AccountCenterView() } label: { settingRow("账户中心", "登录状态与站点访问", session.isLoggedIn ? "person.crop.circle.badge.checkmark" : "person.crop.circle") }
                        NavigationLink { CloudFavoritesView() } label: { settingRow("账户收藏", "同步你的云端收藏夹", "cloud.fill") }
                    }
                    settingsCard(title: "阅读体验", icon: "book.fill", tint: .blue) {
                        NavigationLink { ReaderSettingsView() } label: { settingRow("阅读设置", "翻页、方向与显示方式", "book.fill") }
                        NavigationLink { GalleryListSettingsView() } label: { settingRow("画廊列表样式", "卡片、列表与瀑布流", "rectangle.grid.2x2") }
                    }
                    settingsCard(title: "本地空间", icon: "internaldrive.fill", tint: .orange) {
                        NavigationLink { DownloadSettingsView() } label: { settingRow("下载设置", "管理离线阅读任务", "arrow.down.circle.fill") }
                        NavigationLink { CacheSettingsView() } label: { settingRow("缓存管理", "释放图片与临时空间", "internaldrive") }
                    }
                    settingsCard(title: "搜索与网络", icon: "sparkle.magnifyingglass", tint: .teal) {
                        NavigationLink { TagTranslationSettingsView() } label: { settingRow("标签翻译库", "让标签更容易读懂", "tag.fill") }
                        NavigationLink { NetworkSettingsView() } label: { settingRow("网络设置", "直连站点与连接参数", "network") }
                    }
                    TaroCard(padding: 15) {
                        HStack {
                            Image(systemName: "info.circle.fill").foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("芋头 E 站").font(.subheadline.weight(.semibold))
                                Text("版本 1.7.75 · JHenTai 架构参考").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarHidden(true)
    }

    @ViewBuilder private func settingsCard<Content: View>(title: String, icon: String, tint: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(tint)
                Text(title).font(.headline)
            }.padding(.horizontal, 16).padding(.vertical, 14)
            Divider().opacity(0.35)
            content()
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.primary.opacity(0.06), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.05), radius: 14, y: 6)
    }

    private func settingRow(_ title: String, _ subtitle: String, _ icon: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.subheadline.weight(.semibold)).foregroundStyle(TaroTheme.accent).frame(width: 28, height: 28).background(TaroTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) { Text(title).font(.subheadline.weight(.medium)); Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
