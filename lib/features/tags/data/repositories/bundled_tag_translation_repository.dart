import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/translated_tag.dart';
import '../../domain/repositories/tag_translation_repository.dart';

class BundledTagTranslationRepository implements TagTranslationRepository {
  final _tags = <TranslatedTag>[];
  final _byId = <String, TranslatedTag>{};
  final _byEnglish = <String, TranslatedTag>{};
  final _byChinese = <String, TranslatedTag>{};
  bool _ready = false;

  @override
  bool get isReady => _ready;

  @override
  Future<void> loadBundled() async {
    if (_ready) return;
    final raw = await rootBundle.loadString('assets/tag_translation_seed.json');
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final values = envelope['tags'] as List<dynamic>? ?? const [];
    for (final value in values.whereType<Map<String, dynamic>>()) {
      final namespace = value['namespace'] as String? ?? 'other';
      final key = value['key'] as String? ?? '';
      final name = value['name'] as String? ?? key;
      if (key.isEmpty) continue;
      final tag = TranslatedTag(
        namespace: namespace,
        key: key,
        name: _stripMarkup(name),
        intro: value['intro'] as String?,
      );
      _tags.add(tag);
      _byId[tag.id.toLowerCase()] = tag;
      _byEnglish.putIfAbsent(tag.key.toLowerCase(), () => tag);
      _byChinese.putIfAbsent(tag.name.toLowerCase(), () => tag);
    }
    _ready = true;
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
    if (term.length < 1) return const [];
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
      if (tag == null || !RegExp(r'[\u3400-\u9fff]').hasMatch(candidate))
        return token;
      return '$prefix${tag.namespace}:"${tag.key}\$"';
    }).join(' ');
  }

  String _stripMarkup(String value) => value
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .trim();
}
