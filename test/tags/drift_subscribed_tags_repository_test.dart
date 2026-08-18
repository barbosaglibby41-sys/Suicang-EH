import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/core/database/app_database.dart';
import 'package:taro_eh_flutter/features/tags/data/repositories/drift_subscribed_tags_repository.dart';

void main() {
  late AppDatabase database;
  late DriftSubscribedTagsRepository repository;

  setUp(() {
    database = openTestDatabase(NativeDatabase.memory());
    repository = DriftSubscribedTagsRepository(database);
  });

  tearDown(() => database.close());

  test('toggles a subscription without creating duplicate rows', () async {
    await repository.toggle('artist:sample');
    await repository.toggle('artist:sample');
    expect(await repository.contains('artist:sample'), isFalse);

    await repository.toggle('artist:sample');
    expect(await repository.contains('artist:sample'), isTrue);
    final rows = await database.select(database.subscribedTags).get();
    expect(rows, hasLength(1));
  });
}
