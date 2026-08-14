import SwiftUI

struct NetworkSettingsView: View {
    @AppStorage("taro.eh.siteURL") private var siteURL = "https://e-hentai.org/"
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    @AppStorage("taro.eh.network.imageCacheTime") private var imageCacheTimeRaw = "7d"
    @AppStorage("taro.eh.network.pageCacheTime") private var pageCacheTimeRaw = "1h"
    @AppStorage("taro.eh.network.connectTimeout") private var connectTimeout = 6000
    @AppStorage("taro.eh.network.receiveTimeout") private var receiveTimeout = 6000
    @AppStorage("taro.eh.network.maxConnections") private var maxConnections = 10
    @AppStorage("taro.eh.network.proxyEnabled") private var proxyEnabled = false
    @AppStorage("taro.eh.network.proxyType") private var proxyTypeRaw = "system"
    @AppStorage("taro.eh.network.proxyHost") private var proxyHost = ""
    @AppStorage("taro.eh.network.proxyPort") private var proxyPort = ""
    @AppStorage("taro.eh.network.proxyUsername") private var proxyUsername = ""
    @AppStorage("taro.eh.network.proxyPassword") private var proxyPassword = ""
    @AppStorage("taro.eh.network.doHEnabled") private var dohEnabled = false
    @AppStorage("taro.eh.network.dohServer") private var dohServer = "https://dns.google/dns-query"
    @AppStorage("taro.eh.network.corsPreflight") private var corsPreflight = false
    @State private var showDiagnostics = false
    @State private var diagnostics: [DiagnosticResult] = []
    @State private var isRunningDiagnostics = false

    private var source: Binding<EHSource> {
        Binding(get: { EHSource(rawValue: sourceRaw) ?? .eHentai }, set: { value in sourceRaw = value.rawValue; siteURL = value.baseURL.absoluteString })
    }

    var body: some View {
        Form {
            siteSection
            proxySection
            timeoutSection
            cacheSection
            advancedSection
            diagnosticsSection
        }
        .navigationTitle("网络")
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsDetailView(results: diagnostics)
        }
    }

    // MARK: - Site

    private var siteSection: some View {
        Section {
            Picker("当前站点", selection: source) {
                ForEach(EHSource.allCases) { Text($0.title).tag($0) }
            }
            TextField("自定义站点主页地址", text: $siteURL)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
            Text("ExHentai 需要登录后才能访问；自定义地址仅用于你有权使用的 HTTPS 站点。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("站点")
        }
    }

    // MARK: - Proxy

    private var proxySection: some View {
        Section {
            Toggle("启用代理", isOn: $proxyEnabled)
            if proxyEnabled {
                Picker("代理类型", selection: $proxyTypeRaw) {
                    Text("系统代理").tag("system")
                    Text("HTTP").tag("http")
                    Text("SOCKS5").tag("socks5")
                }
                if proxyTypeRaw != "system" {
                    TextField("地址", text: $proxyHost)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextField("端口", text: $proxyPort)
                        .keyboardType(.numberPad)
                    DisclosureGroup("认证") {
                        TextField("用户名", text: $proxyUsername)
                            .textInputAutocapitalization(.never)
                        SecureField("密码", text: $proxyPassword)
                    }
                }
            }
            if proxyEnabled {
                Button("应用并重置网络") {
                    NetworkConfig.shared.applyProxy()
                }
                .foregroundStyle(.blue)
            }
        } header: {
            Text("代理")
        } footer: {
            Text("系统代理将使用 iOS 设置中的 VPN/代理配置。HTTP/SOCKS5 代理需要手动填写地址和端口。")
        }
    }

    // MARK: - Timeout

    private var timeoutSection: some View {
        Section {
            Picker("连接超时", selection: $connectTimeout) {
                Text("3000ms").tag(3000)
                Text("6000ms").tag(6000)
                Text("10000ms").tag(10000)
                Text("15000ms").tag(15000)
                Text("30000ms").tag(30000)
            }
            Picker("接收超时", selection: $receiveTimeout) {
                Text("3000ms").tag(3000)
                Text("6000ms").tag(6000)
                Text("10000ms").tag(10000)
                Text("15000ms").tag(15000)
                Text("30000ms").tag(30000)
            }
            Picker("最大并发连接数", selection: $maxConnections) {
                Text("4").tag(4)
                Text("6").tag(6)
                Text("10").tag(10)
                Text("15").tag(15)
                Text("20").tag(20)
            }
            Button("应用网络参数") {
                NetworkConfig.shared.applySettings()
            }
            .foregroundStyle(.blue)
        } header: {
            Text("超时与连接")
        } footer: {
            Text("连接超时控制 TCP 握手等待时间；接收超时控制数据传输等待时间。并发连接数影响图片同时下载数量。")
        }
    }

    // MARK: - Cache

    private var cacheSection: some View {
        Section {
            Picker("页面缓存时间", selection: $pageCacheTimeRaw) {
                Text("关闭").tag("0")
                Text("10分钟").tag("10m")
                Text("30分钟").tag("30m")
                Text("1小时").tag("1h")
                Text("6小时").tag("6h")
                Text("24小时").tag("24h")
            }
            Picker("图片缓存时间", selection: $imageCacheTimeRaw) {
                Text("关闭").tag("0")
                Text("1小时").tag("1h")
                Text("6小时").tag("6h")
                Text("1天").tag("1d")
                Text("3天").tag("3d")
                Text("7天").tag("7d")
                Text("30天").tag("30d")
            }
            Text("页面缓存：你可以通过刷新页面来更新缓存。图片缓存：App 启动时会自动清除过期的图片缓存。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("缓存")
        }
    }

    // MARK: - Advanced

    private var advancedSection: some View {
        Section {
            Toggle("DNS over HTTPS", isOn: $dohEnabled)
            if dohEnabled {
                Picker("DoH 服务器", selection: $dohServer) {
                    Text("Google").tag("https://dns.google/dns-query")
                    Text("Cloudflare").tag("https://cloudflare-dns.com/dns-query")
                    Text("Quad9").tag("https://dns.quad9.net/dns-query")
                    Text("阿里").tag("https://dns.alidns.com/dns-query")
                }
            }
            Toggle("跳过证书验证（不推荐）", isOn: .constant(false))
                .disabled(true)
            Text("关闭 TLS 校验会降低安全性。当前版本始终启用 HTTPS 证书验证。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("高级")
        }
    }

    // MARK: - Diagnostics

    private var diagnosticsSection: some View {
        Section {
            Button {
                Task { await runDiagnostics() }
            } label: {
                HStack {
                    Image(systemName: "stethoscope")
                    Text("网络诊断")
                    Spacer()
                    if isRunningDiagnostics { ProgressView().controlSize(.small) }
                }
            }
            .disabled(isRunningDiagnostics)
            if !diagnostics.isEmpty {
                ForEach(diagnostics) { result in
                    HStack {
                        Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(result.success ? .green : .red)
                        Text(result.title)
                        Spacer()
                        Text(result.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("诊断")
        }
    }

    private func runDiagnostics() async {
        isRunningDiagnostics = true
        diagnostics = []
        let sites: [(String, URL)] = [
            ("e-hentai.org", URL(string: "https://e-hentai.org/")!),
            ("exhentai.org", URL(string: "https://exhentai.org/")!)
        ]
        for (name, url) in sites {
            let start = Date()
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 10
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
                let (_, response) = try await URLSession.shared.data(for: request)
                let elapsed = Int(Date().timeIntervalSince(start) * 1000)
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                let success = 200..<400 ~= code
                await MainActor.run {
                    diagnostics.append(DiagnosticResult(
                        title: "\(name) HTTPS",
                        detail: success ? "连接正常 · \(elapsed)ms · \(code)" : "状态码 \(code)",
                        success: success
                    ))
                }
            } catch {
                await MainActor.run {
                    diagnostics.append(DiagnosticResult(
                        title: "\(name) HTTPS",
                        detail: error.localizedDescription,
                        success: false
                    ))
                }
            }
        }
        isRunningDiagnostics = false
    }
}

// MARK: - Diagnostic Result

struct DiagnosticResult: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let success: Bool
}

struct DiagnosticsDetailView: View {
    let results: [DiagnosticResult]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(results) { result in
                HStack {
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(result.success ? .green : .red)
                    VStack(alignment: .leading) {
                        Text(result.title).font(.subheadline.weight(.medium))
                        Text(result.detail).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("网络诊断")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
        }
    }
}

// MARK: - Network Config

@MainActor
final class NetworkConfig: ObservableObject {
    static let shared = NetworkConfig()

    func applySettings() {
        let defaults = UserDefaults.standard
        let connectTimeout = defaults.integer(forKey: "taro.eh.network.connectTimeout")
        let receiveTimeout = defaults.integer(forKey: "taro.eh.network.receiveTimeout")
        let maxConn = defaults.integer(forKey: "taro.eh.network.maxConnections")
        Task {
            await ImagePipeline.shared.updateConfiguration(
                connectTimeout: TimeInterval(connectTimeout) / 1000,
                receiveTimeout: TimeInterval(receiveTimeout) / 1000,
                maxConnections: maxConn
            )
        }
    }

    func applyProxy() {
        URLCache.shared.removeAllCachedResponses()
        Task { await ImagePipeline.shared.removeAllMemory() }
    }
}
