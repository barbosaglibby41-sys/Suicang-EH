import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/tag_database_status.dart';
import '../../domain/entities/translated_tag.dart';
import '../../domain/repositories/tag_translation_repository.dart';

class BundledTagTranslationRepository extends ChangeNotifier
    implements TagTranslationRepository {
  static const _assetPath = 'assets/tag_translation_seed.json';
  static const _fileName = 'tag_translation.json';
  static const _remoteUrl =
      'https://fastly.jsdelivr.net/gh/EhTagTranslation/DatabaseReleases/db.html.json';

  final _tags = <TranslatedTag>[];
  final _byId = <String, TranslatedTag>{};
  final _byEnglish = <String, TranslatedTag>{};
  final _byChinese = <String, TranslatedTag>{};
  int _version = 0;
  DateTime? _updatedAt;
  bool _isBundled = true;
  bool _ready = false;
  int _revision = 0;

  @override
  int get revision => _revision;

  @override
  bool get isReady => _ready;

  @override
  Future<void> loadBundled() async {
    if (_ready) return;
    try {
      final local = await _localFile();
      if (await local.exists()) {
        try {
          final raw = await local.readAsString();
          _validateDatabase(raw);
          await _apply(raw, isBundled: false);
          return;
        } catch (_) {
          // A failed update should be recoverable without reinstalling.
          await local.delete();
        }
      }
    } catch (_) {
      // path_provider may be unavailable in pure widget/unit tests.
      // The bundled asset remains a safe read-only fallback.
    }
    await _apply(await rootBundle.loadString(_assetPath), isBundled: true);
  }

  @override
  Future<TagDatabaseStatus> status() async {
    await loadBundled();
    return TagDatabaseStatus(
      version: _version,
      updatedAt: _updatedAt,
      tagCount: _tags.length,
      isBundled: _isBundled,
    );
  }

  @override
  Future<TagDatabaseStatus> updateFromRemote() async {
    await loadBundled();
    final response = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 20),
      ),
    ).get<String>(
      _remoteUrl,
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    final raw = response.data;
    if (raw == null || raw.trim().isEmpty) {
      throw StateError('标签数据库下载为空。');
    }

    // Normalize and fully validate before touching the active in-memory data
    // or the persisted file. A partial/corrupt update must never break the
    // discovery page on the next request.
    final normalized = _normalizeRemote(raw);
    _validateDatabase(normalized);
    final local = await _localFile();
    final temporary = File('${local.path}.part');
    try {
      await temporary.writeAsString(normalized, flush: true);
      if (await local.exists()) await local.delete();
      await temporary.rename(local.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
    await _apply(normalized, isBundled: false);
    return status();
  }

  @override
  Future<void> restoreBundled() async {
    final local = await _localFile();
    if (await local.exists()) await local.delete();
    await _apply(await rootBundle.loadString(_assetPath), isBundled: true);
  }

  @override
  TranslatedTag? find(String value) {
    final normalized = value.trim().toLowerCase();
    final exact =
        _byId[normalized] ?? _byEnglish[normalized] ?? _byChinese[normalized];
    if (exact != null) return exact;
    for (final tag in _tags) {
      if (tag.name.toLowerCase().contains(normalized)) return tag;
    }
    return null;
  }

  @override
  List<TranslatedTag> suggestions(String token, {int limit = 12}) {
    final term = token.trim().toLowerCase();
    if (term.isEmpty) return const [];
    final scored = <({TranslatedTag tag, int score})>[];
    for (final tag in _tags) {
      final name = tag.name.toLowerCase();
      final key = tag.key.toLowerCase();
      final score = name == term || key == term
          ? 100
          : name.startsWith(term) || key.startsWith(term)
              ? 70
              : name.contains(term) || key.contains(term)
                  ? 30
                  : 0;
      if (score > 0) scored.add((tag: tag, score: score));
    }
    scored.sort((left, right) {
      final score = right.score.compareTo(left.score);
      return score == 0 ? left.tag.name.compareTo(right.tag.name) : score;
    });
    return scored.take(limit).map((item) => item.tag).toList(growable: false);
  }

  @override
  String translateQuery(String query) {
    return query
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .map((token) {
      final prefix =
          token.startsWith('-') || token.startsWith('~') ? token[0] : '';
      final value = prefix.isEmpty ? token : token.substring(1);
      final separator = value.indexOf(':');
      final candidate = separator < 0 ? value : value.substring(separator + 1);
      final tag = find(candidate);
      if (tag == null || !RegExp(r'[\u3400-\u9fff]').hasMatch(candidate)) {
        return token;
      }
      return '$prefix${tag.namespace}:"${tag.key}\$"';
    }).join(' ');
  }

  Future<void> _apply(String raw, {required bool isBundled}) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('标签数据库根节点无效。');
    }
    final values = decoded['tags'];
    if (values is! List) {
      throw const FormatException('标签数据库缺少 tags 列表。');
    }

    // Parse into fresh collections first. If one entry is malformed, the
    // previous valid database stays active instead of being half-cleared.
    final nextTags = <TranslatedTag>[];
    final nextById = <String, TranslatedTag>{};
    final nextByEnglish = <String, TranslatedTag>{};
    final nextByChinese = <String, TranslatedTag>{};
    for (final value in values) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('标签数据库包含无效条目。');
      }
      final namespace =
          (value['namespace'] as String? ?? 'other').trim().toLowerCase();
      final key = (value['key'] as String? ?? '').trim();
      final name = (value['name'] as String? ?? key).trim();
      final introValue = value['intro'];
      if (key.isEmpty ||
          name.isEmpty ||
          (introValue != null && introValue is! String)) {
        throw const FormatException('标签数据库包含无效字段。');
      }
      final tag = TranslatedTag(
        namespace: namespace,
        key: key,
        name: _stripMarkup(name),
        intro: introValue == null ? null : _stripMarkup(introValue as String),
      );
      nextTags.add(tag);
      nextById[tag.id.toLowerCase()] = tag;
      nextByEnglish.putIfAbsent(tag.key.toLowerCase(), () => tag);
      nextByChinese.putIfAbsent(tag.name.toLowerCase(), () => tag);
    }
    if (nextTags.isEmpty) {
      throw const FormatException('标签数据库没有可用标签。');
    }

    _tags
      ..clear()
      ..addAll(nextTags);
    _byId
      ..clear()
      ..addAll(nextById);
    _byEnglish
      ..clear()
      ..addAll(nextByEnglish);
    _byChinese
      ..clear()
      ..addAll(nextByChinese);
    _version = decoded['version'] as int? ?? 0;
    _updatedAt =
        DateTime.tryParse(decoded['updatedAt'] as String? ?? '')?.toUtc();
    _isBundled = isBundled;
    _ready = true;
    _revision += 1;
    notifyListeners();
  }

  void _validateDatabase(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['tags'] is! List) {
      throw const FormatException('标签数据库格式无效。');
    }
    final tags = decoded['tags'] as List<dynamic>;
    if (tags.isEmpty) {
      throw const FormatException('标签数据库没有标签。');
    }
    for (final value in tags) {
      if (value is! Map<String, dynamic> ||
          value['key'] is! String ||
          (value['key'] as String).trim().isEmpty ||
          value['name'] is! String) {
        throw const FormatException('标签数据库包含无效条目。');
      }
    }
  }

  String _normalizeRemote(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['tags'] is List) return raw;
    final groups = decoded['data'] as List<dynamic>? ?? const [];
    final tags = <Map<String, String>>[];
    for (final group in groups.whereType<Map<String, dynamic>>()) {
      final namespace = group['namespace'] as String? ?? 'other';
      if (namespace == 'rows') continue;
      final values = group['data'] as Map<String, dynamic>? ?? const {};
      for (final entry in values.entries) {
        final item = entry.value as Map<String, dynamic>? ?? const {};
        tags.add({
          'namespace': namespace,
          'key': entry.key,
          'name': _stripMarkup(item['name'] as String? ?? entry.key),
        });
      }
    }
    final updatedAt = ((decoded['head'] as Map<String, dynamic>?)?['committer']
        as Map<String, dynamic>?)?['when'] as String?;
    return jsonEncode({
      'version': decoded['version'] as int? ?? 0,
      'updatedAt': updatedAt ?? DateTime.now().toUtc().toIso8601String(),
      'tags': tags,
    });
  }

  Future<File> _localFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(path.join(directory.path, _fileName));
  }

  String _stripMarkup(String value) => value
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .trim();
}
