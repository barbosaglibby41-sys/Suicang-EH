import SwiftUI

struct TagTranslationSettingsView: View {
    @EnvironmentObject private var tags: TagTranslationStore
    @State private var showRestoreConfirmation = false
    var body: some View {
        Form {
            Section {
                Toggle("标签搜索补全", isOn: Binding(get: { tags.enabled }, set: tags.setEnabled))
                Picker("选择标签后", selection: Binding(get: { tags.fillMode }, set: tags.setFillMode)) {
                    Text("填入搜索框").tag(true)
                    Text("仅查看，不填入").tag(false)
                }.disabled(!tags.enabled)
            } footer: {
                Text("开启后，E-Hentai 和 ExHentai 搜索会根据本地标签数据提供标签建议；填入模式会在关键词末尾自动加入空格。")
            }
            Section {
                Toggle("中文标签自动转换", isOn: Binding(get: { tags.translateChineseSearch }, set: tags.setTranslateChineseSearch))
            } footer: {
                Text("开启后，搜索时会把能匹配本地标签库的中文词转换为 E-Hentai 可识别的英文标签；搜索框和搜索历史仍保留原文。")
            }
            Section("E-Hentai 标签翻译库") {
                HStack {
                    Label(tags.enabled ? "标签翻译已启用" : "标签翻译已关闭", systemImage: tags.enabled ? "checkmark.circle.fill" : "pause.circle")
                    Spacer()
                    Text(tags.dataSource).foregroundStyle(.secondary)
                }
                HStack { Text("数据库版本"); Spacer(); Text(tags.databaseVersion == 0 ? "—" : "\(tags.databaseVersion)").foregroundStyle(.secondary) }
                HStack { Text("标签数"); Spacer(); Text(tags.tagCount.formatted()).foregroundStyle(.secondary) }
                HStack { Text("更新时间"); Spacer(); Text(tags.formattedUpdatedAt).foregroundStyle(.secondary) }
                if tags.isUpdating {
                    ProgressView { Text("正在检查更新…") }
                }
                Button { Task { await tags.update() } } label: {
                    Label("检查并下载更新", systemImage: "arrow.down.circle")
                }.disabled(tags.isUpdating)
                Button(role: .destructive) { showRestoreConfirmation = true } label: {
                    Label("恢复内置数据库", systemImage: "arrow.counterclockwise.circle")
                }.disabled(tags.isUpdating)
                if let status = tags.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(.secondary)
                }
                if let error = tags.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(.orange)
                }
            } footer: {
                Text("数据来自 EhTagTranslation/DatabaseReleases，下载后保存到本机。网络不可用或校验失败时继续使用当前数据；内置版本始终可以恢复。")
            }
            Section("许可与来源") {
                Link("EhTagTranslation Database", destination: URL(string: "https://github.com/EhTagTranslation/Database")!)
                Text("标签翻译数据库按 CC BY-NC-SA 3.0 CN 提供。TaroEH 只独立实现下载、解析、查询和界面，不复制其他客户端源码。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("标签翻译库")
        .confirmationDialog("恢复内置数据库？", isPresented: $showRestoreConfirmation, titleVisibility: .visible) {
            Button("恢复内置版本", role: .destructive) { tags.restoreBundled() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这会覆盖当前本地更新的数据，并恢复内置数据库 v\(tags.bundledDatabaseVersion)。")
        }
    }
}
