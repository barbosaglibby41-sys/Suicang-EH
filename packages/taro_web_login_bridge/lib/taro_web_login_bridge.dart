import 'package:flutter/services.dart';

class NativeLoginCookie {
  const NativeLoginCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.path,
    required this.updatedAt,
    this.expiresAt,
    this.secure = true,
    this.httpOnly = false,
  });

  final String name;
  final String value;
  final String domain;
  final String path;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final bool secure;
  final bool httpOnly;

  factory NativeLoginCookie.fromMap(Map<Object?, Object?> value) {
    return NativeLoginCookie(
      name: value['name']! as String,
      value: value['value']! as String,
      domain: value['domain']! as String,
      path: value['path'] as String? ?? '/',
      updatedAt: DateTime.parse(value['updatedAt']! as String).toUtc(),
      expiresAt: (value['expiresAt'] as String?) == null
          ? null
          : DateTime.parse(value['expiresAt']! as String).toUtc(),
      secure: value['secure'] as bool? ?? true,
      httpOnly: value['httpOnly'] as bool? ?? false,
    );
  }
}

class TaroWebLoginBridge {
  static const _channel = MethodChannel('com.taro.eh/web_login_bridge');

  Future<void> setKeepScreenOn(bool enabled) {
    return _channel.invokeMethod<void>('setKeepScreenOn', {'enabled': enabled});
  }

  Future<List<NativeLoginCookie>> authenticate({required Uri initialUrl}) async {
    final response = await _channel.invokeListMethod<Object?>(
      'authenticate',
      {'initialUrl': initialUrl.toString()},
    );
    return [
      for (final value in response ?? const <Object?>[])
        if (value is Map<Object?, Object?>) NativeLoginCookie.fromMap(value),
    ];
  }
}
