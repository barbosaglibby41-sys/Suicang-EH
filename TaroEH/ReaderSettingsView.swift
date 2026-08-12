import SwiftUI

struct ReaderSettingsView: View {
    @AppStorage("taro.eh.reader.fit") private var fit = true
    @AppStorage("taro.eh.reader.direction") private var direction = "horizontal"
    @AppStorage("taro.eh.reader.keepScreenOn") private var keepScreenOn = true
    var body: some View {
        Form {
            Section("阅读方式") { Picker("翻页方向", selection: $direction) { Text("横向分页").tag("horizontal"); Text("纵向滚动").tag("vertical") }; Toggle("适应页面宽高", isOn: $fit) }
            Section("屏幕") { Toggle("阅读时保持亮屏", isOn: $keepScreenOn) }
            Section { Text("设置会同时用于在线阅读和离线阅读。") .font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("阅读设置")
    }
}
