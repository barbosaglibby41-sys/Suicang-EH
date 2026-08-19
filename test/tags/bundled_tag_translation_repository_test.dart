import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/tags/data/repositories/bundled_tag_translation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keeps the English query while translating Chinese tag tokens',
      () async {
    final repository = BundledTagTranslationRepository();
    await repository.loadBundled();

    final suggestions = repository.suggestions('女性');
    expect(suggestions, isNotEmpty);
    expect(repository.translateQuery('女性'), contains(':"'));
    expect(repository.find('female:__unknown__'), isNull);
    expect(repository.translateQuery('female:__unknown__'), 'female:__unknown__');
  });

  test('suggestions are ranked by exact or prefix matches', () async {
    final repository = BundledTagTranslationRepository();
    await repository.loadBundled();
    final suggestions = repository.suggestions('artist');

    expect(suggestions, isNotEmpty);
    expect(suggestions.first.key.toLowerCase(), contains('artist'));
  });
}
