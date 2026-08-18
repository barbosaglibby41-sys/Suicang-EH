import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/session_cookie.dart';
import 'secure_cookie_store.dart';

class FlutterSecureCookieStore implements SecureCookieStore {
  FlutterSecureCookieStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'taro_eh.auth.cookies.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<List<SessionCookie>> readAll() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) {
        return const [];
      }
      final payload = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in payload.whereType<Map<String, dynamic>>())
          _fromJson(item),
      ];
    } on FormatException catch (error) {
      throw StorageException('Saved session data is invalid.', cause: error);
    } catch (error) {
      throw StorageException('Unable to read the secure session.',
          cause: error);
    }
  }

  @override
  Future<void> writeAll(Iterable<SessionCookie> cookies) async {
    try {
      final payload =
          jsonEncode([for (final cookie in cookies) _toJson(cookie)]);
      await _storage.write(key: _key, value: payload);
    } catch (error) {
      throw StorageException('Unable to save the secure session.',
          cause: error);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (error) {
      throw StorageException('Unable to clear the secure session.',
          cause: error);
    }
  }

  Map<String, Object?> _toJson(SessionCookie cookie) => {
        'name': cookie.name,
        'value': cookie.value,
        'domain': cookie.domain,
        'path': cookie.path,
        'updatedAt': cookie.updatedAt.toUtc().toIso8601String(),
        'expiresAt': cookie.expiresAt?.toUtc().toIso8601String(),
        'secure': cookie.secure,
        'httpOnly': cookie.httpOnly,
      };

  SessionCookie _fromJson(Map<String, dynamic> json) {
    return SessionCookie(
      name: json['name'] as String,
      value: json['value'] as String,
      domain: json['domain'] as String,
      path: json['path'] as String? ?? '/',
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      expiresAt: (json['expiresAt'] as String?) == null
          ? null
          : DateTime.parse(json['expiresAt'] as String).toUtc(),
      secure: json['secure'] as bool? ?? true,
      httpOnly: json['httpOnly'] as bool? ?? false,
    );
  }
}
