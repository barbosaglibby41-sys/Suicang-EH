import Flutter
import WebKit

public class TaroWebLoginBridgePlugin: NSObject, FlutterPlugin {
  private var result: FlutterResult?
  private var webView: WKWebView?
  private var hostController: UIViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.taro.eh/web_login_bridge",
      binaryMessenger: registrar.messenger()
    )
    let instance = TaroWebLoginBridgePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "authenticate",
          let arguments = call.arguments as? [String: Any],
          let rawURL = arguments["initialUrl"] as? String,
          let url = URL(string: rawURL) else {
      result(FlutterError(code: "invalid_arguments", message: "A valid initialUrl is required.", details: nil))
      return
    }
    guard self.result == nil else {
      result(FlutterError(code: "already_presented", message: "A login session is already active.", details: nil))
      return
    }
    guard let root = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })?.rootViewController else {
      result(FlutterError(code: "unavailable", message: "No active window is available.", details: nil))
      return
    }

    self.result = result
    let configuration = WKWebViewConfiguration()
    let store = WKWebsiteDataStore.nonPersistent()
    configuration.websiteDataStore = store
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile"
    webView.navigationDelegate = self
    self.webView = webView

    let controller = UIViewController()
    controller.view = webView
    controller.title = "登录 E-Hentai"
    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancel)
    )
    let navigation = UINavigationController(rootViewController: controller)
    navigation.modalPresentationStyle = .fullScreen
    self.hostController = navigation
    root.present(navigation, animated: true) {
      webView.load(URLRequest(url: url))
    }
  }

  @objc private func cancel() {
    complete(error: FlutterError(code: "cancelled", message: "Login cancelled.", details: nil))
  }

  private func captureCookies() {
    guard let webView else { return }
    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
      let allowed = cookies.filter {
        $0.domain.contains("e-hentai.org") || $0.domain.contains("exhentai.org")
      }
      let payload: [[String: Any]] = allowed.map { cookie in
        [
          "name": cookie.name,
          "value": cookie.value,
          "domain": cookie.domain,
          "path": cookie.path,
          "updatedAt": ISO8601DateFormatter().string(from: Date()),
          "expiresAt": cookie.expiresDate.map { ISO8601DateFormatter().string(from: $0) } as Any,
          "secure": cookie.isSecure,
          "httpOnly": cookie.isHTTPOnly,
        ]
      }
      guard payload.contains(where: { $0["name"] as? String == "ipb_member_id" }) else { return }
      self?.complete(value: payload)
    }
  }

  private func complete(value: Any? = nil, error: FlutterError? = nil) {
    let callback = result
    result = nil
    let controller = hostController
    hostController = nil
    webView = nil
    controller?.dismiss(animated: true) {
      if let error { callback?(error) } else { callback?(value ?? []) }
    }
  }
}

extension TaroWebLoginBridgePlugin: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    captureCookies()
  }

  public func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
  ) {
    decisionHandler(.allow)
    captureCookies()
  }
}
