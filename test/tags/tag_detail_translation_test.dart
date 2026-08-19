import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/tags/data/repositories/bundled_tag_translation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('translates complete namespace key for detail display', () async {
    final repository = BundledTagTranslationRepository();
    await repository.loadBundled();

    final tag = repository.find('female:footjob');
    expect(tag?.namespace, 'female');
    expect(tag?.name, isNotEmpty);
  });
}
