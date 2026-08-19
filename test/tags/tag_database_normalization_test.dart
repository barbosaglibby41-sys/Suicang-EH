import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/tags/data/repositories/bundled_tag_translation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled repository exposes normalized namespace key index', () async {
    final repository = BundledTagTranslationRepository();
    await repository.loadBundled();

    final tag = repository.find('female:footjob');
    expect(tag?.rawName, 'female:footjob');
    expect(tag?.namespace, 'female');
    expect(repository.revision, greaterThan(0));
  });

  test('remote group schema can be represented by canonical tags envelope', () {
    final input = {
      'version': 8,
      'data': [
        {
          'namespace': 'rows',
          'data': {
            'female': {'name': '女性'}
          },
        },
        {
          'namespace': 'female',
          'data': {
            'footjob': {'name': '<p>足交</p>', 'intro': '<p>说明</p>'},
          },
        },
      ],
    };
    final groups = input['data'] as List<dynamic>;
    final canonical = <Map<String, String>>[];
    for (final group in groups.cast<Map<String, dynamic>>()) {
      if (group['namespace'] == 'rows') continue;
      final values = group['data'] as Map<String, dynamic>;
      for (final entry in values.entries) {
        canonical.add({
          'namespace': group['namespace'] as String,
          'key': entry.key,
          'name': (entry.value as Map<String, dynamic>)['name'] as String,
        });
      }
    }
    expect(jsonEncode(canonical), contains('footjob'));
    expect(canonical.single['namespace'], 'female');
  });
}
