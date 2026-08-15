import SwiftUI
import UIKit

struct AccountCenterView: View {
    @EnvironmentObject private var session: SessionStore
    @AppStorage("taro.eh.source") private var sourceRaw = EHSource.eHentai.rawValue
    @State private var isRefreshing = false
    @State private var showCookies = false

    private var source: EHSource { EHSource(rawValue: sourceRaw) ?? .eHentai }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    TaroAvatar(icon: session.statusIcon)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(session.accountName ?? (session.isLoggedIn ? "已登录账户" : "未登录账户")).font(.title3.weight(.bold))
                        TaroStatusPill(title: session.statusText(for: source), icon: session.isLoggedIn ? "checkmark" : "exclamationmark", tint: session.isLoggedIn ? .green : .orange)
                    }
                    Spacer()
                    if session.isChecking { ProgressView().controlSize(.small) }
                }
                .padding(.vertical, 5)
                Picker("验证站点", selection: Binding(get: { source }, set: { value in sourceRaw = value.rawValue })) {
                    ForEach(EHSource.allCases) { Text($0.title).tag($0) }
                }
                Button { Task { await session.validate(source: source) } } label: {
                    Label("验证账户状态", systemImage: "checkmark.shield.fill")
                }
                .buttonStyle(TaroPrimaryButtonStyle())
                .disabled(session.isChecking || !session.hasCredentials)
            } header: {
                Text("账户状态").font(.headline).foregroundStyle(.primary)
            }
            Section("站点能力") {
                CapabilityRow(title: "E-Hentai", detail: session.hasCredentials ? "账号 Cookie 已保存" : "需要登录", active: session.hasCredentials)
                CapabilityRow(title: "ExHentai 里站", detail: session.exAccess == true ? "可访问" : (session.hasCredentials ? "尚未验证或不可访问" : "需要登录"), active: session.exAccess == true)
                if source == .exHentai && session.exAccess != true {
                    Text("里站访问依赖有效的 ipb_member_id、ipb_pass_hash 和 igneous。若显示 Sad Panda，可尝试刷新 igneous 后重新验证。")
                        .font(.footnote).foregroundStyle(.orange)
                }
            }

            Section("登录方式") {
                NavigationLink { WebLoginView() } label: {
                    Label("网页登录", systemImage: "globe")
                }
                NavigationLink { CookieImportView() } label: {
                    Label("导入 Cookie", systemImage: "key.fill")
                }
                if session.hasCredentials {
                    Button { showCookies = true } label: {
                        Label("查看 Cookie 状态", systemImage: "list.bullet.rectangle")
                    }
                }
            }

            if source == .exHentai && session.hasCredentials {
                Section("里站维护") {
                    Button {
                        isRefreshing = true
                        Task {
                            await session.refreshExHentaiCookie()
                            isRefreshing = false
                        }
                    } label: {
                        HStack {
                            Label("刷新 igneous", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if isRefreshing { ProgressView().controlSize(.small) }
                        }
                    }
                    .disabled(isRefreshing || session.isChecking)
                    Text("刷新时只使用当前保存的站点 Cookie，成功后会更新本机 Keychain。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }

            if session.hasCredentials {
                Section {
                    Button("退出并清除本机 Cookie", role: .destructive) { session.clear() }
                } footer: {
                    Text("退出只会清除本机凭据，不会删除站点账户或云端收藏。")
                }
            }
        }
        .navigationTitle("账户中心")
        .scrollContentBackground(.hidden)
        .background(TaroPageBackground())
        .tint(TaroTheme.accent)
        .sheet(isPresented: $showCookies) { CookieStatusView() }
        .task {
            if session.hasCredentials { await session.validate(source: source) }
        }
        .onChange(of: sourceRaw) { _, _ in
            if session.hasCredentials { Task { await session.validate(source: source) } }
        }
    }
}

private struct CapabilityRow: View {
    let title: String
    let detail: String
    let active: Bool
    var body: some View {
        HStack {
            Image(systemName: active ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(active ? .green : .secondary)
            VStack(alignment: .leading) {
                Text(title)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct CookieStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @State private var copied = false

    var body: some View {
        NavigationStack {
            List {
                Section("已保存的登录凭据") {
                    ForEach(session.cookieItems, id: \.name) { item in
                        HStack {
                            Text(item.name).font(.subheadline.monospaced())
                            Spacer()
                            Text(item.maskedValue).font(.caption.monospaced()).foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIPasteboard.general.string = "\(item.name)=\(item.value)"
                            copied = true
                        }
                    }
                }
                Section {
                    Button {
                        UIPasteboard.general.string = session.cookieHeader() ?? ""
                        copied = true
                    } label: {
                        Label("复制全部 Cookie", systemImage: "doc.on.doc")
                    }
                } footer: {
                    Text("点击单项或按钮会把 Cookie 写入系统剪贴板。使用后请及时清除剪贴板，切勿分享给他人。")
                }
            }
            .navigationTitle("Cookie 状态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
            .alert("已复制", isPresented: $copied) { Button("好", role: .cancel) {} }
        }
        .presentationDetents([.medium, .large])
    }
}

private extension SessionStore {
    var statusIcon: String {
        switch status {
        case .signedIn: return "person.crop.circle.badge.checkmark"
        case .checking: return "person.crop.circle"
        case .invalid: return "person.crop.circle.badge.exclamationmark"
        case .signedOut: return "person.crop.circle.badge.xmark"
        }
    }
    var statusColor: Color {
        switch status {
        case .signedIn: return .green
        case .checking: return .orange
        case .invalid: return .red
        case .signedOut: return .secondary
        }
    }
}

private extension SessionCookieItem {
    var maskedValue: String {
        guard value.count > 6 else { return "••••••" }
        return String(value.prefix(3)) + "••••" + String(value.suffix(3))
    }
}
