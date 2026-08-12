import SwiftUI

struct CacheSettingsView: View {
    @State private var count = ImageURLCache.shared.count
    var body: some View {
        List {
            Section("地址缓存") { LabeledContent("缓存画廊", value: "\(count) 个"); Text("图片地址在 24 小时后自动过期。缓存不包含 Cookie 或图片文件。").font(.footnote).foregroundStyle(.secondary); Button("清除全部地址缓存", role: .destructive) { ImageURLCache.shared.clearAll(); count = 0 } }
        }.navigationTitle("缓存管理")
    }
}
