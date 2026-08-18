package com.taro.eh.web_login_bridge

import android.annotation.SuppressLint
import android.app.Activity
import android.graphics.Color
import android.os.Build
import android.webkit.CookieManager
import android.webkit.WebView
import android.webkit.WebViewClient
import android.app.AlertDialog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TaroWebLoginBridgePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var activeResult: MethodChannel.Result? = null
  private var dialog: AlertDialog? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "com.taro.eh/web_login_bridge")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method != "authenticate") {
      result.notImplemented()
      return
    }
    val rawUrl = call.argument<String>("initialUrl")
    if (rawUrl.isNullOrBlank()) {
      result.error("invalid_arguments", "A valid initialUrl is required.", null)
      return
    }
    if (activeResult != null || activity == null) {
      result.error("unavailable", "No active activity is available.", null)
      return
    }
    showLogin(rawUrl, result)
  }

  @SuppressLint("SetJavaScriptEnabled")
  private fun showLogin(url: String, result: MethodChannel.Result) {
    val host = activity ?: return
    activeResult = result
    val webView = WebView(host)
    webView.setBackgroundColor(Color.WHITE)
    webView.settings.javaScriptEnabled = true
    webView.settings.domStorageEnabled = true
    webView.settings.userAgentString = "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Mobile"
    CookieManager.getInstance().setAcceptCookie(true)
    webView.webViewClient = object : WebViewClient() {
      override fun onPageFinished(view: WebView, url: String) {
        captureCookies()
      }
    }
    dialog = AlertDialog.Builder(host)
      .setTitle("登录 E-Hentai")
      .setView(webView)
      .setNegativeButton("取消") { _, _ -> completeError("cancelled", "Login cancelled.") }
      .create()
    dialog?.setOnDismissListener {
      if (activeResult != null) completeError("cancelled", "Login cancelled.")
    }
    dialog?.show()
    webView.loadUrl(url)
  }

  private fun captureCookies() {
    val manager = CookieManager.getInstance()
    val headers = listOfNotNull(
      manager.getCookie("https://e-hentai.org/"),
      manager.getCookie("https://exhentai.org/")
    )
    val values = mutableListOf<Map<String, Any>>()
    val seen = mutableSetOf<String>()
    for ((index, header) in headers.withIndex()) {
      val domain = if (index == 0) "e-hentai.org" else "exhentai.org"
      for (part in header.split(";")) {
        val separator = part.indexOf('=')
        if (separator <= 0) continue
        val name = part.substring(0, separator).trim()
        val value = part.substring(separator + 1).trim()
        if (!seen.add("$domain|$name")) continue
        values.add(mapOf(
          "name" to name,
          "value" to value,
          "domain" to domain,
          "path" to "/",
          "updatedAt" to java.text.SimpleDateFormat(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            java.util.Locale.US
          ).apply { timeZone = java.util.TimeZone.getTimeZone("UTC") }.format(java.util.Date()),
          "secure" to true,
          "httpOnly" to false
        ))
      }
    }
    if (values.any { it["name"] == "ipb_member_id" }) complete(values)
  }

  private fun complete(value: List<Map<String, Any>>) {
    val result = activeResult ?: return
    activeResult = null
    val activeDialog = dialog
    dialog = null
    activeDialog?.dismiss()
    result.success(value)
  }

  private fun completeError(code: String, message: String) {
    val result = activeResult ?: return
    activeResult = null
    val activeDialog = dialog
    dialog = null
    activeDialog?.dismiss()
    result.error(code, message, null)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
  override fun onDetachedFromActivityForConfigChanges() { activity = null }
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
  override fun onDetachedFromActivity() { activity = null }
}
