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
          await _apply(await local.readAsString(), isBundled: false);
          return;
        } catch (_) {
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
    final response = await Dio().get<String>(
      _remoteUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final raw = response.data;
    if (raw == null || raw.isEmpty) {
      throw StateError('Tag database update returned no data.');
    }
    final normalized = _normalizeRemote(raw);
    final local = await _localFile();
    final temporary = File('${local.path}.part');
    await temporary.writeAsString(normalized, flush: true);
    await temporary.rename(local.path);
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
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final tags = decoded['tags'] as List<dynamic>? ?? const [];
    _tags.clear();
    _byId.clear();
    _byEnglish.clear();
    _byChinese.clear();
    for (final value in tags.whereType<Map<String, dynamic>>()) {
      final namespace =
          (value['namespace'] as String? ?? 'other').trim().toLowerCase();
      final key = (value['key'] as String? ?? '').trim();
      final name = (value['name'] as String? ?? key).trim();
      if (key.isEmpty) continue;
      final tag = TranslatedTag(
        namespace: namespace,
        key: key,
        name: _stripMarkup(name),
        intro: value['intro'] == null
            ? null
            : _stripMarkup(value['intro'] as String),
      );
      _tags.add(tag);
      _byId[tag.id.toLowerCase()] = tag;
      _byEnglish.putIfAbsent(tag.key.toLowerCase(), () => tag);
      _byChinese.putIfAbsent(tag.name.toLowerCase(), () => tag);
    }
    _version = decoded['version'] as int? ?? 0;
    _updatedAt =
        DateTime.tryParse(decoded['updatedAt'] as String? ?? '')?.toUtc();
    _isBundled = isBundled;
    _ready = true;
    _revision += 1;
    notifyListeners();
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
