import SwiftUI

struct DownloadSettingsView: View {
    @AppStorage("taro.eh.wifiOnly") private var wifiOnly = true
    @AppStorage("taro.eh.concurrent") private var concurrent = 2
    @AppStorage("taro.eh.original") private var original = false
    var body: some View {
        Form {
            Section("网络") { Toggle("仅 Wi‑Fi 下载", isOn: $wifiOnly); Stepper("并发任务：\(concurrent)", value: $concurrent, in: 1...6) }
            Section("图片") { Toggle("优先原图", isOn: $original) }
            Section { Text("下载内容保存在本机 App 沙盒，不会自动上传到第三方服务。") .font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("下载设置")
    }
}
