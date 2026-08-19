import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/library/domain/entities/library_filter.dart';

void main() {
  test('defaults to favorite time and supports date reset', () {
    const initial = LibraryFilter();
    final selected = initial.copyWith(
      sort: LibrarySort.publishedTime,
      date: DateTime(2026, 8, 19),
    );
    final reset = selected.copyWith(clearDate: true);

    expect(initial.sort, LibrarySort.favoriteTime);
    expect(selected.sort, LibrarySort.publishedTime);
    expect(selected.date, DateTime(2026, 8, 19));
    expect(reset.date, isNull);
  });
}
