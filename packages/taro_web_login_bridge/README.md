# Taro Web Login Bridge

Native login bridge for TaroEH.

- iOS uses a non-persistent `WKWebsiteDataStore` and captures cookies through `WKHTTPCookieStore`, including HttpOnly values exposed by WebKit's native cookie API.
- Android uses `WebView` and `CookieManager`. Android's cookie API does not expose HttpOnly metadata, so the bridge returns `httpOnly=false` for its structured records; the cookie value itself is still captured only through the platform API and immediately persisted by Dart to secure storage.
- The Dart layer must never log, render, or store cookie values outside `flutter_secure_storage`.
- The plugin only returns after a login cookie is present; cancel returns a typed platform error.
