enum LibrarySort { favoriteTime, publishedTime }

class LibraryFilter {
  const LibraryFilter({
    this.sort = LibrarySort.favoriteTime,
    this.date,
  });

  final LibrarySort sort;
  final DateTime? date;

  LibraryFilter copyWith({
    LibrarySort? sort,
    DateTime? date,
    bool clearDate = false,
  }) => LibraryFilter(
        sort: sort ?? this.sort,
        date: clearDate ? null : date ?? this.date,
      );
}
