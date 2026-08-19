// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GalleriesTable extends Galleries
    with TableInfo<$GalleriesTable, GalleryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GalleriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<int> gid = GeneratedColumn<int>(
      'gid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uploaderMeta =
      const VerificationMeta('uploader');
  @override
  late final GeneratedColumn<String> uploader = GeneratedColumn<String>(
      'uploader', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _postedAtMeta =
      const VerificationMeta('postedAt');
  @override
  late final GeneratedColumn<DateTime> postedAt = GeneratedColumn<DateTime>(
      'posted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        source,
        gid,
        title,
        uploader,
        category,
        thumbnailUrl,
        sourceUrl,
        pageCount,
        tagsJson,
        rating,
        postedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'galleries';
  @override
  VerificationContext validateIntegrity(Insertable<GalleryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('uploader')) {
      context.handle(_uploaderMeta,
          uploader.isAcceptableOrUnknown(data['uploader']!, _uploaderMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('posted_at')) {
      context.handle(_postedAtMeta,
          postedAt.isAcceptableOrUnknown(data['posted_at']!, _postedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, gid};
  @override
  GalleryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GalleryRow(
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      uploader: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uploader'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url']),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating']),
      postedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}posted_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GalleriesTable createAlias(String alias) {
    return $GalleriesTable(attachedDatabase, alias);
  }
}

class GalleryRow extends DataClass implements Insertable<GalleryRow> {
  final String source;
  final int gid;
  final String title;
  final String uploader;
  final String category;
  final String? thumbnailUrl;
  final String? sourceUrl;
  final int pageCount;
  final String tagsJson;
  final double? rating;
  final DateTime? postedAt;
  final DateTime updatedAt;
  const GalleryRow(
      {required this.source,
      required this.gid,
      required this.title,
      required this.uploader,
      required this.category,
      this.thumbnailUrl,
      this.sourceUrl,
      required this.pageCount,
      required this.tagsJson,
      this.rating,
      this.postedAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['gid'] = Variable<int>(gid);
    map['title'] = Variable<String>(title);
    map['uploader'] = Variable<String>(uploader);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['page_count'] = Variable<int>(pageCount);
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || postedAt != null) {
      map['posted_at'] = Variable<DateTime>(postedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GalleriesCompanion toCompanion(bool nullToAbsent) {
    return GalleriesCompanion(
      source: Value(source),
      gid: Value(gid),
      title: Value(title),
      uploader: Value(uploader),
      category: Value(category),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      pageCount: Value(pageCount),
      tagsJson: Value(tagsJson),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      postedAt: postedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(postedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GalleryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GalleryRow(
      source: serializer.fromJson<String>(json['source']),
      gid: serializer.fromJson<int>(json['gid']),
      title: serializer.fromJson<String>(json['title']),
      uploader: serializer.fromJson<String>(json['uploader']),
      category: serializer.fromJson<String>(json['category']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      rating: serializer.fromJson<double?>(json['rating']),
      postedAt: serializer.fromJson<DateTime?>(json['postedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'gid': serializer.toJson<int>(gid),
      'title': serializer.toJson<String>(title),
      'uploader': serializer.toJson<String>(uploader),
      'category': serializer.toJson<String>(category),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'pageCount': serializer.toJson<int>(pageCount),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'rating': serializer.toJson<double?>(rating),
      'postedAt': serializer.toJson<DateTime?>(postedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GalleryRow copyWith(
          {String? source,
          int? gid,
          String? title,
          String? uploader,
          String? category,
          Value<String?> thumbnailUrl = const Value.absent(),
          Value<String?> sourceUrl = const Value.absent(),
          int? pageCount,
          String? tagsJson,
          Value<double?> rating = const Value.absent(),
          Value<DateTime?> postedAt = const Value.absent(),
          DateTime? updatedAt}) =>
      GalleryRow(
        source: source ?? this.source,
        gid: gid ?? this.gid,
        title: title ?? this.title,
        uploader: uploader ?? this.uploader,
        category: category ?? this.category,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
        pageCount: pageCount ?? this.pageCount,
        tagsJson: tagsJson ?? this.tagsJson,
        rating: rating.present ? rating.value : this.rating,
        postedAt: postedAt.present ? postedAt.value : this.postedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GalleryRow copyWithCompanion(GalleriesCompanion data) {
    return GalleryRow(
      source: data.source.present ? data.source.value : this.source,
      gid: data.gid.present ? data.gid.value : this.gid,
      title: data.title.present ? data.title.value : this.title,
      uploader: data.uploader.present ? data.uploader.value : this.uploader,
      category: data.category.present ? data.category.value : this.category,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      rating: data.rating.present ? data.rating.value : this.rating,
      postedAt: data.postedAt.present ? data.postedAt.value : this.postedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GalleryRow(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('title: $title, ')
          ..write('uploader: $uploader, ')
          ..write('category: $category, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('pageCount: $pageCount, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('rating: $rating, ')
          ..write('postedAt: $postedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      source,
      gid,
      title,
      uploader,
      category,
      thumbnailUrl,
      sourceUrl,
      pageCount,
      tagsJson,
      rating,
      postedAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GalleryRow &&
          other.source == this.source &&
          other.gid == this.gid &&
          other.title == this.title &&
          other.uploader == this.uploader &&
          other.category == this.category &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.sourceUrl == this.sourceUrl &&
          other.pageCount == this.pageCount &&
          other.tagsJson == this.tagsJson &&
          other.rating == this.rating &&
          other.postedAt == this.postedAt &&
          other.updatedAt == this.updatedAt);
}

class GalleriesCompanion extends UpdateCompanion<GalleryRow> {
  final Value<String> source;
  final Value<int> gid;
  final Value<String> title;
  final Value<String> uploader;
  final Value<String> category;
  final Value<String?> thumbnailUrl;
  final Value<String?> sourceUrl;
  final Value<int> pageCount;
  final Value<String> tagsJson;
  final Value<double?> rating;
  final Value<DateTime?> postedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GalleriesCompanion({
    this.source = const Value.absent(),
    this.gid = const Value.absent(),
    this.title = const Value.absent(),
    this.uploader = const Value.absent(),
    this.category = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.rating = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GalleriesCompanion.insert({
    required String source,
    required int gid,
    required String title,
    this.uploader = const Value.absent(),
    this.category = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.rating = const Value.absent(),
    this.postedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : source = Value(source),
        gid = Value(gid),
        title = Value(title),
        updatedAt = Value(updatedAt);
  static Insertable<GalleryRow> custom({
    Expression<String>? source,
    Expression<int>? gid,
    Expression<String>? title,
    Expression<String>? uploader,
    Expression<String>? category,
    Expression<String>? thumbnailUrl,
    Expression<String>? sourceUrl,
    Expression<int>? pageCount,
    Expression<String>? tagsJson,
    Expression<double>? rating,
    Expression<DateTime>? postedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (gid != null) 'gid': gid,
      if (title != null) 'title': title,
      if (uploader != null) 'uploader': uploader,
      if (category != null) 'category': category,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (pageCount != null) 'page_count': pageCount,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (rating != null) 'rating': rating,
      if (postedAt != null) 'posted_at': postedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GalleriesCompanion copyWith(
      {Value<String>? source,
      Value<int>? gid,
      Value<String>? title,
      Value<String>? uploader,
      Value<String>? category,
      Value<String?>? thumbnailUrl,
      Value<String?>? sourceUrl,
      Value<int>? pageCount,
      Value<String>? tagsJson,
      Value<double?>? rating,
      Value<DateTime?>? postedAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GalleriesCompanion(
      source: source ?? this.source,
      gid: gid ?? this.gid,
      title: title ?? this.title,
      uploader: uploader ?? this.uploader,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      pageCount: pageCount ?? this.pageCount,
      tagsJson: tagsJson ?? this.tagsJson,
      rating: rating ?? this.rating,
      postedAt: postedAt ?? this.postedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (gid.present) {
      map['gid'] = Variable<int>(gid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (uploader.present) {
      map['uploader'] = Variable<String>(uploader.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (postedAt.present) {
      map['posted_at'] = Variable<DateTime>(postedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GalleriesCompanion(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('title: $title, ')
          ..write('uploader: $uploader, ')
          ..write('category: $category, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('pageCount: $pageCount, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('rating: $rating, ')
          ..write('postedAt: $postedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntriesTable extends LibraryEntries
    with TableInfo<$LibraryEntriesTable, LibraryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<int> gid = GeneratedColumn<int>(
      'gid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _favoritedAtMeta =
      const VerificationMeta('favoritedAt');
  @override
  late final GeneratedColumn<DateTime> favoritedAt = GeneratedColumn<DateTime>(
      'favorited_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastOpenedAtMeta =
      const VerificationMeta('lastOpenedAt');
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
      'last_opened_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [source, gid, isFavorite, favoritedAt, lastOpenedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LibraryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('favorited_at')) {
      context.handle(
          _favoritedAtMeta,
          favoritedAt.isAcceptableOrUnknown(
              data['favorited_at']!, _favoritedAtMeta));
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
          _lastOpenedAtMeta,
          lastOpenedAt.isAcceptableOrUnknown(
              data['last_opened_at']!, _lastOpenedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, gid};
  @override
  LibraryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntry(
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gid'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      favoritedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}favorited_at']),
      lastOpenedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_opened_at']),
    );
  }

  @override
  $LibraryEntriesTable createAlias(String alias) {
    return $LibraryEntriesTable(attachedDatabase, alias);
  }
}

class LibraryEntry extends DataClass implements Insertable<LibraryEntry> {
  final String source;
  final int gid;
  final bool isFavorite;
  final DateTime? favoritedAt;
  final DateTime? lastOpenedAt;
  const LibraryEntry(
      {required this.source,
      required this.gid,
      required this.isFavorite,
      this.favoritedAt,
      this.lastOpenedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['gid'] = Variable<int>(gid);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || favoritedAt != null) {
      map['favorited_at'] = Variable<DateTime>(favoritedAt);
    }
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    return map;
  }

  LibraryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntriesCompanion(
      source: Value(source),
      gid: Value(gid),
      isFavorite: Value(isFavorite),
      favoritedAt: favoritedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(favoritedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
    );
  }

  factory LibraryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntry(
      source: serializer.fromJson<String>(json['source']),
      gid: serializer.fromJson<int>(json['gid']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      favoritedAt: serializer.fromJson<DateTime?>(json['favoritedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'gid': serializer.toJson<int>(gid),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'favoritedAt': serializer.toJson<DateTime?>(favoritedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
    };
  }

  LibraryEntry copyWith(
          {String? source,
          int? gid,
          bool? isFavorite,
          Value<DateTime?> favoritedAt = const Value.absent(),
          Value<DateTime?> lastOpenedAt = const Value.absent()}) =>
      LibraryEntry(
        source: source ?? this.source,
        gid: gid ?? this.gid,
        isFavorite: isFavorite ?? this.isFavorite,
        favoritedAt: favoritedAt.present ? favoritedAt.value : this.favoritedAt,
        lastOpenedAt:
            lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
      );
  LibraryEntry copyWithCompanion(LibraryEntriesCompanion data) {
    return LibraryEntry(
      source: data.source.present ? data.source.value : this.source,
      gid: data.gid.present ? data.gid.value : this.gid,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      favoritedAt:
          data.favoritedAt.present ? data.favoritedAt.value : this.favoritedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntry(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('favoritedAt: $favoritedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(source, gid, isFavorite, favoritedAt, lastOpenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntry &&
          other.source == this.source &&
          other.gid == this.gid &&
          other.isFavorite == this.isFavorite &&
          other.favoritedAt == this.favoritedAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class LibraryEntriesCompanion extends UpdateCompanion<LibraryEntry> {
  final Value<String> source;
  final Value<int> gid;
  final Value<bool> isFavorite;
  final Value<DateTime?> favoritedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<int> rowid;
  const LibraryEntriesCompanion({
    this.source = const Value.absent(),
    this.gid = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.favoritedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntriesCompanion.insert({
    required String source,
    required int gid,
    this.isFavorite = const Value.absent(),
    this.favoritedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : source = Value(source),
        gid = Value(gid);
  static Insertable<LibraryEntry> custom({
    Expression<String>? source,
    Expression<int>? gid,
    Expression<bool>? isFavorite,
    Expression<DateTime>? favoritedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (gid != null) 'gid': gid,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (favoritedAt != null) 'favorited_at': favoritedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntriesCompanion copyWith(
      {Value<String>? source,
      Value<int>? gid,
      Value<bool>? isFavorite,
      Value<DateTime?>? favoritedAt,
      Value<DateTime?>? lastOpenedAt,
      Value<int>? rowid}) {
    return LibraryEntriesCompanion(
      source: source ?? this.source,
      gid: gid ?? this.gid,
      isFavorite: isFavorite ?? this.isFavorite,
      favoritedAt: favoritedAt ?? this.favoritedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (gid.present) {
      map['gid'] = Variable<int>(gid.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (favoritedAt.present) {
      map['favorited_at'] = Variable<DateTime>(favoritedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntriesCompanion(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('favoritedAt: $favoritedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressEntriesTable extends ReadingProgressEntries
    with TableInfo<$ReadingProgressEntriesTable, ReadingProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<int> gid = GeneratedColumn<int>(
      'gid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [source, gid, pageIndex, pageCount, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadingProgressEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, gid};
  @override
  ReadingProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressEntry(
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gid'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReadingProgressEntriesTable createAlias(String alias) {
    return $ReadingProgressEntriesTable(attachedDatabase, alias);
  }
}

class ReadingProgressEntry extends DataClass
    implements Insertable<ReadingProgressEntry> {
  final String source;
  final int gid;
  final int pageIndex;
  final int pageCount;
  final DateTime updatedAt;
  const ReadingProgressEntry(
      {required this.source,
      required this.gid,
      required this.pageIndex,
      required this.pageCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['gid'] = Variable<int>(gid);
    map['page_index'] = Variable<int>(pageIndex);
    map['page_count'] = Variable<int>(pageCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressEntriesCompanion(
      source: Value(source),
      gid: Value(gid),
      pageIndex: Value(pageIndex),
      pageCount: Value(pageCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressEntry(
      source: serializer.fromJson<String>(json['source']),
      gid: serializer.fromJson<int>(json['gid']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'gid': serializer.toJson<int>(gid),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'pageCount': serializer.toJson<int>(pageCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressEntry copyWith(
          {String? source,
          int? gid,
          int? pageIndex,
          int? pageCount,
          DateTime? updatedAt}) =>
      ReadingProgressEntry(
        source: source ?? this.source,
        gid: gid ?? this.gid,
        pageIndex: pageIndex ?? this.pageIndex,
        pageCount: pageCount ?? this.pageCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReadingProgressEntry copyWithCompanion(ReadingProgressEntriesCompanion data) {
    return ReadingProgressEntry(
      source: data.source.present ? data.source.value : this.source,
      gid: data.gid.present ? data.gid.value : this.gid,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressEntry(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('pageCount: $pageCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, gid, pageIndex, pageCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressEntry &&
          other.source == this.source &&
          other.gid == this.gid &&
          other.pageIndex == this.pageIndex &&
          other.pageCount == this.pageCount &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressEntriesCompanion
    extends UpdateCompanion<ReadingProgressEntry> {
  final Value<String> source;
  final Value<int> gid;
  final Value<int> pageIndex;
  final Value<int> pageCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingProgressEntriesCompanion({
    this.source = const Value.absent(),
    this.gid = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressEntriesCompanion.insert({
    required String source,
    required int gid,
    required int pageIndex,
    required int pageCount,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : source = Value(source),
        gid = Value(gid),
        pageIndex = Value(pageIndex),
        pageCount = Value(pageCount),
        updatedAt = Value(updatedAt);
  static Insertable<ReadingProgressEntry> custom({
    Expression<String>? source,
    Expression<int>? gid,
    Expression<int>? pageIndex,
    Expression<int>? pageCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (gid != null) 'gid': gid,
      if (pageIndex != null) 'page_index': pageIndex,
      if (pageCount != null) 'page_count': pageCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressEntriesCompanion copyWith(
      {Value<String>? source,
      Value<int>? gid,
      Value<int>? pageIndex,
      Value<int>? pageCount,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ReadingProgressEntriesCompanion(
      source: source ?? this.source,
      gid: gid ?? this.gid,
      pageIndex: pageIndex ?? this.pageIndex,
      pageCount: pageCount ?? this.pageCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (gid.present) {
      map['gid'] = Variable<int>(gid.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressEntriesCompanion(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('pageCount: $pageCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<int> gid = GeneratedColumn<int>(
      'gid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completedPagesMeta =
      const VerificationMeta('completedPages');
  @override
  late final GeneratedColumn<int> completedPages = GeneratedColumn<int>(
      'completed_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _targetDirectoryMeta =
      const VerificationMeta('targetDirectory');
  @override
  late final GeneratedColumn<String> targetDirectory = GeneratedColumn<String>(
      'target_directory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _failureCodeMeta =
      const VerificationMeta('failureCode');
  @override
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
      'failure_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        source,
        gid,
        status,
        totalPages,
        completedPages,
        targetDirectory,
        failureCode,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    }
    if (data.containsKey('completed_pages')) {
      context.handle(
          _completedPagesMeta,
          completedPages.isAcceptableOrUnknown(
              data['completed_pages']!, _completedPagesMeta));
    }
    if (data.containsKey('target_directory')) {
      context.handle(
          _targetDirectoryMeta,
          targetDirectory.isAcceptableOrUnknown(
              data['target_directory']!, _targetDirectoryMeta));
    }
    if (data.containsKey('failure_code')) {
      context.handle(
          _failureCodeMeta,
          failureCode.isAcceptableOrUnknown(
              data['failure_code']!, _failureCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gid'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      completedPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_pages'])!,
      targetDirectory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_directory']),
      failureCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}failure_code']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  final String id;
  final String source;
  final int gid;
  final String status;
  final int totalPages;
  final int completedPages;
  final String? targetDirectory;
  final String? failureCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadTask(
      {required this.id,
      required this.source,
      required this.gid,
      required this.status,
      required this.totalPages,
      required this.completedPages,
      this.targetDirectory,
      this.failureCode,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['gid'] = Variable<int>(gid);
    map['status'] = Variable<String>(status);
    map['total_pages'] = Variable<int>(totalPages);
    map['completed_pages'] = Variable<int>(completedPages);
    if (!nullToAbsent || targetDirectory != null) {
      map['target_directory'] = Variable<String>(targetDirectory);
    }
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      id: Value(id),
      source: Value(source),
      gid: Value(gid),
      status: Value(status),
      totalPages: Value(totalPages),
      completedPages: Value(completedPages),
      targetDirectory: targetDirectory == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDirectory),
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      gid: serializer.fromJson<int>(json['gid']),
      status: serializer.fromJson<String>(json['status']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      completedPages: serializer.fromJson<int>(json['completedPages']),
      targetDirectory: serializer.fromJson<String?>(json['targetDirectory']),
      failureCode: serializer.fromJson<String?>(json['failureCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'gid': serializer.toJson<int>(gid),
      'status': serializer.toJson<String>(status),
      'totalPages': serializer.toJson<int>(totalPages),
      'completedPages': serializer.toJson<int>(completedPages),
      'targetDirectory': serializer.toJson<String?>(targetDirectory),
      'failureCode': serializer.toJson<String?>(failureCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadTask copyWith(
          {String? id,
          String? source,
          int? gid,
          String? status,
          int? totalPages,
          int? completedPages,
          Value<String?> targetDirectory = const Value.absent(),
          Value<String?> failureCode = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DownloadTask(
        id: id ?? this.id,
        source: source ?? this.source,
        gid: gid ?? this.gid,
        status: status ?? this.status,
        totalPages: totalPages ?? this.totalPages,
        completedPages: completedPages ?? this.completedPages,
        targetDirectory: targetDirectory.present
            ? targetDirectory.value
            : this.targetDirectory,
        failureCode: failureCode.present ? failureCode.value : this.failureCode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DownloadTask copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTask(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      gid: data.gid.present ? data.gid.value : this.gid,
      status: data.status.present ? data.status.value : this.status,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
      completedPages: data.completedPages.present
          ? data.completedPages.value
          : this.completedPages,
      targetDirectory: data.targetDirectory.present
          ? data.targetDirectory.value
          : this.targetDirectory,
      failureCode:
          data.failureCode.present ? data.failureCode.value : this.failureCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('status: $status, ')
          ..write('totalPages: $totalPages, ')
          ..write('completedPages: $completedPages, ')
          ..write('targetDirectory: $targetDirectory, ')
          ..write('failureCode: $failureCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, source, gid, status, totalPages,
      completedPages, targetDirectory, failureCode, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.id == this.id &&
          other.source == this.source &&
          other.gid == this.gid &&
          other.status == this.status &&
          other.totalPages == this.totalPages &&
          other.completedPages == this.completedPages &&
          other.targetDirectory == this.targetDirectory &&
          other.failureCode == this.failureCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<String> id;
  final Value<String> source;
  final Value<int> gid;
  final Value<String> status;
  final Value<int> totalPages;
  final Value<int> completedPages;
  final Value<String?> targetDirectory;
  final Value<String?> failureCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.gid = const Value.absent(),
    this.status = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.completedPages = const Value.absent(),
    this.targetDirectory = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String id,
    required String source,
    required int gid,
    required String status,
    this.totalPages = const Value.absent(),
    this.completedPages = const Value.absent(),
    this.targetDirectory = const Value.absent(),
    this.failureCode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        source = Value(source),
        gid = Value(gid),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DownloadTask> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<int>? gid,
    Expression<String>? status,
    Expression<int>? totalPages,
    Expression<int>? completedPages,
    Expression<String>? targetDirectory,
    Expression<String>? failureCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (gid != null) 'gid': gid,
      if (status != null) 'status': status,
      if (totalPages != null) 'total_pages': totalPages,
      if (completedPages != null) 'completed_pages': completedPages,
      if (targetDirectory != null) 'target_directory': targetDirectory,
      if (failureCode != null) 'failure_code': failureCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? source,
      Value<int>? gid,
      Value<String>? status,
      Value<int>? totalPages,
      Value<int>? completedPages,
      Value<String?>? targetDirectory,
      Value<String?>? failureCode,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DownloadTasksCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      gid: gid ?? this.gid,
      status: status ?? this.status,
      totalPages: totalPages ?? this.totalPages,
      completedPages: completedPages ?? this.completedPages,
      targetDirectory: targetDirectory ?? this.targetDirectory,
      failureCode: failureCode ?? this.failureCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (gid.present) {
      map['gid'] = Variable<int>(gid.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (completedPages.present) {
      map['completed_pages'] = Variable<int>(completedPages.value);
    }
    if (targetDirectory.present) {
      map['target_directory'] = Variable<String>(targetDirectory.value);
    }
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('status: $status, ')
          ..write('totalPages: $totalPages, ')
          ..write('completedPages: $completedPages, ')
          ..write('targetDirectory: $targetDirectory, ')
          ..write('failureCode: $failureCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadPagesTable extends DownloadPages
    with TableInfo<$DownloadPagesTable, DownloadPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageUrlMeta =
      const VerificationMeta('pageUrl');
  @override
  late final GeneratedColumn<String> pageUrl = GeneratedColumn<String>(
      'page_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _byteCountMeta =
      const VerificationMeta('byteCount');
  @override
  late final GeneratedColumn<int> byteCount = GeneratedColumn<int>(
      'byte_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        taskId,
        pageIndex,
        pageUrl,
        localPath,
        byteCount,
        status,
        checksum,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_pages';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadPage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('page_url')) {
      context.handle(_pageUrlMeta,
          pageUrl.isAcceptableOrUnknown(data['page_url']!, _pageUrlMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('byte_count')) {
      context.handle(_byteCountMeta,
          byteCount.isAcceptableOrUnknown(data['byte_count']!, _byteCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, pageIndex};
  @override
  DownloadPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadPage(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      pageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_url']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      byteCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}byte_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DownloadPagesTable createAlias(String alias) {
    return $DownloadPagesTable(attachedDatabase, alias);
  }
}

class DownloadPage extends DataClass implements Insertable<DownloadPage> {
  final String taskId;
  final int pageIndex;
  final String? pageUrl;
  final String? localPath;
  final int byteCount;
  final String status;
  final String? checksum;
  final DateTime updatedAt;
  const DownloadPage(
      {required this.taskId,
      required this.pageIndex,
      this.pageUrl,
      this.localPath,
      required this.byteCount,
      required this.status,
      this.checksum,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['page_index'] = Variable<int>(pageIndex);
    if (!nullToAbsent || pageUrl != null) {
      map['page_url'] = Variable<String>(pageUrl);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['byte_count'] = Variable<int>(byteCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadPagesCompanion toCompanion(bool nullToAbsent) {
    return DownloadPagesCompanion(
      taskId: Value(taskId),
      pageIndex: Value(pageIndex),
      pageUrl: pageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pageUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      byteCount: Value(byteCount),
      status: Value(status),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadPage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadPage(
      taskId: serializer.fromJson<String>(json['taskId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      pageUrl: serializer.fromJson<String?>(json['pageUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      byteCount: serializer.fromJson<int>(json['byteCount']),
      status: serializer.fromJson<String>(json['status']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'pageUrl': serializer.toJson<String?>(pageUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'byteCount': serializer.toJson<int>(byteCount),
      'status': serializer.toJson<String>(status),
      'checksum': serializer.toJson<String?>(checksum),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadPage copyWith(
          {String? taskId,
          int? pageIndex,
          Value<String?> pageUrl = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          int? byteCount,
          String? status,
          Value<String?> checksum = const Value.absent(),
          DateTime? updatedAt}) =>
      DownloadPage(
        taskId: taskId ?? this.taskId,
        pageIndex: pageIndex ?? this.pageIndex,
        pageUrl: pageUrl.present ? pageUrl.value : this.pageUrl,
        localPath: localPath.present ? localPath.value : this.localPath,
        byteCount: byteCount ?? this.byteCount,
        status: status ?? this.status,
        checksum: checksum.present ? checksum.value : this.checksum,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DownloadPage copyWithCompanion(DownloadPagesCompanion data) {
    return DownloadPage(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      pageUrl: data.pageUrl.present ? data.pageUrl.value : this.pageUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      byteCount: data.byteCount.present ? data.byteCount.value : this.byteCount,
      status: data.status.present ? data.status.value : this.status,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadPage(')
          ..write('taskId: $taskId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('localPath: $localPath, ')
          ..write('byteCount: $byteCount, ')
          ..write('status: $status, ')
          ..write('checksum: $checksum, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, pageIndex, pageUrl, localPath,
      byteCount, status, checksum, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadPage &&
          other.taskId == this.taskId &&
          other.pageIndex == this.pageIndex &&
          other.pageUrl == this.pageUrl &&
          other.localPath == this.localPath &&
          other.byteCount == this.byteCount &&
          other.status == this.status &&
          other.checksum == this.checksum &&
          other.updatedAt == this.updatedAt);
}

class DownloadPagesCompanion extends UpdateCompanion<DownloadPage> {
  final Value<String> taskId;
  final Value<int> pageIndex;
  final Value<String?> pageUrl;
  final Value<String?> localPath;
  final Value<int> byteCount;
  final Value<String> status;
  final Value<String?> checksum;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadPagesCompanion({
    this.taskId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.pageUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.byteCount = const Value.absent(),
    this.status = const Value.absent(),
    this.checksum = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadPagesCompanion.insert({
    required String taskId,
    required int pageIndex,
    this.pageUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.byteCount = const Value.absent(),
    required String status,
    this.checksum = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        pageIndex = Value(pageIndex),
        status = Value(status),
        updatedAt = Value(updatedAt);
  static Insertable<DownloadPage> custom({
    Expression<String>? taskId,
    Expression<int>? pageIndex,
    Expression<String>? pageUrl,
    Expression<String>? localPath,
    Expression<int>? byteCount,
    Expression<String>? status,
    Expression<String>? checksum,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (pageUrl != null) 'page_url': pageUrl,
      if (localPath != null) 'local_path': localPath,
      if (byteCount != null) 'byte_count': byteCount,
      if (status != null) 'status': status,
      if (checksum != null) 'checksum': checksum,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadPagesCompanion copyWith(
      {Value<String>? taskId,
      Value<int>? pageIndex,
      Value<String?>? pageUrl,
      Value<String?>? localPath,
      Value<int>? byteCount,
      Value<String>? status,
      Value<String?>? checksum,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DownloadPagesCompanion(
      taskId: taskId ?? this.taskId,
      pageIndex: pageIndex ?? this.pageIndex,
      pageUrl: pageUrl ?? this.pageUrl,
      localPath: localPath ?? this.localPath,
      byteCount: byteCount ?? this.byteCount,
      status: status ?? this.status,
      checksum: checksum ?? this.checksum,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (pageUrl.present) {
      map['page_url'] = Variable<String>(pageUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (byteCount.present) {
      map['byte_count'] = Variable<int>(byteCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadPagesCompanion(')
          ..write('taskId: $taskId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('localPath: $localPath, ')
          ..write('byteCount: $byteCount, ')
          ..write('status: $status, ')
          ..write('checksum: $checksum, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageUrlCacheEntriesTable extends ImageUrlCacheEntries
    with TableInfo<$ImageUrlCacheEntriesTable, ImageUrlCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageUrlCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<int> gid = GeneratedColumn<int>(
      'gid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageUrlMeta =
      const VerificationMeta('pageUrl');
  @override
  late final GeneratedColumn<String> pageUrl = GeneratedColumn<String>(
      'page_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolvedImageUrlMeta =
      const VerificationMeta('resolvedImageUrl');
  @override
  late final GeneratedColumn<String> resolvedImageUrl = GeneratedColumn<String>(
      'resolved_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [source, gid, pageIndex, pageUrl, resolvedImageUrl, expiresAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_url_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ImageUrlCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('page_url')) {
      context.handle(_pageUrlMeta,
          pageUrl.isAcceptableOrUnknown(data['page_url']!, _pageUrlMeta));
    }
    if (data.containsKey('resolved_image_url')) {
      context.handle(
          _resolvedImageUrlMeta,
          resolvedImageUrl.isAcceptableOrUnknown(
              data['resolved_image_url']!, _resolvedImageUrlMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, gid, pageIndex};
  @override
  ImageUrlCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageUrlCacheEntry(
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gid'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      pageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_url']),
      resolvedImageUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolved_image_url']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ImageUrlCacheEntriesTable createAlias(String alias) {
    return $ImageUrlCacheEntriesTable(attachedDatabase, alias);
  }
}

class ImageUrlCacheEntry extends DataClass
    implements Insertable<ImageUrlCacheEntry> {
  final String source;
  final int gid;
  final int pageIndex;
  final String? pageUrl;
  final String? resolvedImageUrl;
  final DateTime expiresAt;
  final DateTime updatedAt;
  const ImageUrlCacheEntry(
      {required this.source,
      required this.gid,
      required this.pageIndex,
      this.pageUrl,
      this.resolvedImageUrl,
      required this.expiresAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['gid'] = Variable<int>(gid);
    map['page_index'] = Variable<int>(pageIndex);
    if (!nullToAbsent || pageUrl != null) {
      map['page_url'] = Variable<String>(pageUrl);
    }
    if (!nullToAbsent || resolvedImageUrl != null) {
      map['resolved_image_url'] = Variable<String>(resolvedImageUrl);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ImageUrlCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ImageUrlCacheEntriesCompanion(
      source: Value(source),
      gid: Value(gid),
      pageIndex: Value(pageIndex),
      pageUrl: pageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pageUrl),
      resolvedImageUrl: resolvedImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedImageUrl),
      expiresAt: Value(expiresAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ImageUrlCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageUrlCacheEntry(
      source: serializer.fromJson<String>(json['source']),
      gid: serializer.fromJson<int>(json['gid']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      pageUrl: serializer.fromJson<String?>(json['pageUrl']),
      resolvedImageUrl: serializer.fromJson<String?>(json['resolvedImageUrl']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'gid': serializer.toJson<int>(gid),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'pageUrl': serializer.toJson<String?>(pageUrl),
      'resolvedImageUrl': serializer.toJson<String?>(resolvedImageUrl),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ImageUrlCacheEntry copyWith(
          {String? source,
          int? gid,
          int? pageIndex,
          Value<String?> pageUrl = const Value.absent(),
          Value<String?> resolvedImageUrl = const Value.absent(),
          DateTime? expiresAt,
          DateTime? updatedAt}) =>
      ImageUrlCacheEntry(
        source: source ?? this.source,
        gid: gid ?? this.gid,
        pageIndex: pageIndex ?? this.pageIndex,
        pageUrl: pageUrl.present ? pageUrl.value : this.pageUrl,
        resolvedImageUrl: resolvedImageUrl.present
            ? resolvedImageUrl.value
            : this.resolvedImageUrl,
        expiresAt: expiresAt ?? this.expiresAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ImageUrlCacheEntry copyWithCompanion(ImageUrlCacheEntriesCompanion data) {
    return ImageUrlCacheEntry(
      source: data.source.present ? data.source.value : this.source,
      gid: data.gid.present ? data.gid.value : this.gid,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      pageUrl: data.pageUrl.present ? data.pageUrl.value : this.pageUrl,
      resolvedImageUrl: data.resolvedImageUrl.present
          ? data.resolvedImageUrl.value
          : this.resolvedImageUrl,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageUrlCacheEntry(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('resolvedImageUrl: $resolvedImageUrl, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      source, gid, pageIndex, pageUrl, resolvedImageUrl, expiresAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageUrlCacheEntry &&
          other.source == this.source &&
          other.gid == this.gid &&
          other.pageIndex == this.pageIndex &&
          other.pageUrl == this.pageUrl &&
          other.resolvedImageUrl == this.resolvedImageUrl &&
          other.expiresAt == this.expiresAt &&
          other.updatedAt == this.updatedAt);
}

class ImageUrlCacheEntriesCompanion
    extends UpdateCompanion<ImageUrlCacheEntry> {
  final Value<String> source;
  final Value<int> gid;
  final Value<int> pageIndex;
  final Value<String?> pageUrl;
  final Value<String?> resolvedImageUrl;
  final Value<DateTime> expiresAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ImageUrlCacheEntriesCompanion({
    this.source = const Value.absent(),
    this.gid = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.pageUrl = const Value.absent(),
    this.resolvedImageUrl = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageUrlCacheEntriesCompanion.insert({
    required String source,
    required int gid,
    required int pageIndex,
    this.pageUrl = const Value.absent(),
    this.resolvedImageUrl = const Value.absent(),
    required DateTime expiresAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : source = Value(source),
        gid = Value(gid),
        pageIndex = Value(pageIndex),
        expiresAt = Value(expiresAt),
        updatedAt = Value(updatedAt);
  static Insertable<ImageUrlCacheEntry> custom({
    Expression<String>? source,
    Expression<int>? gid,
    Expression<int>? pageIndex,
    Expression<String>? pageUrl,
    Expression<String>? resolvedImageUrl,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (gid != null) 'gid': gid,
      if (pageIndex != null) 'page_index': pageIndex,
      if (pageUrl != null) 'page_url': pageUrl,
      if (resolvedImageUrl != null) 'resolved_image_url': resolvedImageUrl,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageUrlCacheEntriesCompanion copyWith(
      {Value<String>? source,
      Value<int>? gid,
      Value<int>? pageIndex,
      Value<String?>? pageUrl,
      Value<String?>? resolvedImageUrl,
      Value<DateTime>? expiresAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ImageUrlCacheEntriesCompanion(
      source: source ?? this.source,
      gid: gid ?? this.gid,
      pageIndex: pageIndex ?? this.pageIndex,
      pageUrl: pageUrl ?? this.pageUrl,
      resolvedImageUrl: resolvedImageUrl ?? this.resolvedImageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (gid.present) {
      map['gid'] = Variable<int>(gid.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (pageUrl.present) {
      map['page_url'] = Variable<String>(pageUrl.value);
    }
    if (resolvedImageUrl.present) {
      map['resolved_image_url'] = Variable<String>(resolvedImageUrl.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageUrlCacheEntriesCompanion(')
          ..write('source: $source, ')
          ..write('gid: $gid, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('resolvedImageUrl: $resolvedImageUrl, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryEntriesTable extends SearchHistoryEntries
    with TableInfo<$SearchHistoryEntriesTable, SearchHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
      'query', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<DateTime> usedAt = GeneratedColumn<DateTime>(
      'used_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, query, usedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SearchHistoryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
          _queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(_usedAtMeta,
          usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta));
    } else if (isInserting) {
      context.missing(_usedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      query: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query'])!,
      usedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}used_at'])!,
    );
  }

  @override
  $SearchHistoryEntriesTable createAlias(String alias) {
    return $SearchHistoryEntriesTable(attachedDatabase, alias);
  }
}

class SearchHistoryEntry extends DataClass
    implements Insertable<SearchHistoryEntry> {
  final int id;
  final String query;
  final DateTime usedAt;
  const SearchHistoryEntry(
      {required this.id, required this.query, required this.usedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['used_at'] = Variable<DateTime>(usedAt);
    return map;
  }

  SearchHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryEntriesCompanion(
      id: Value(id),
      query: Value(query),
      usedAt: Value(usedAt),
    );
  }

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      usedAt: serializer.fromJson<DateTime>(json['usedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'usedAt': serializer.toJson<DateTime>(usedAt),
    };
  }

  SearchHistoryEntry copyWith({int? id, String? query, DateTime? usedAt}) =>
      SearchHistoryEntry(
        id: id ?? this.id,
        query: query ?? this.query,
        usedAt: usedAt ?? this.usedAt,
      );
  SearchHistoryEntry copyWithCompanion(SearchHistoryEntriesCompanion data) {
    return SearchHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntry(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, usedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryEntry &&
          other.id == this.id &&
          other.query == this.query &&
          other.usedAt == this.usedAt);
}

class SearchHistoryEntriesCompanion
    extends UpdateCompanion<SearchHistoryEntry> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> usedAt;
  const SearchHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.usedAt = const Value.absent(),
  });
  SearchHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime usedAt,
  })  : query = Value(query),
        usedAt = Value(usedAt);
  static Insertable<SearchHistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? usedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (usedAt != null) 'used_at': usedAt,
    });
  }

  SearchHistoryEntriesCompanion copyWith(
      {Value<int>? id, Value<String>? query, Value<DateTime>? usedAt}) {
    return SearchHistoryEntriesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<DateTime>(usedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }
}

class $SubscribedTagsTable extends SubscribedTags
    with TableInfo<$SubscribedTagsTable, SubscribedTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscribedTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rawNameMeta =
      const VerificationMeta('rawName');
  @override
  late final GeneratedColumn<String> rawName = GeneratedColumn<String>(
      'raw_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [rawName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscribed_tags';
  @override
  VerificationContext validateIntegrity(Insertable<SubscribedTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('raw_name')) {
      context.handle(_rawNameMeta,
          rawName.isAcceptableOrUnknown(data['raw_name']!, _rawNameMeta));
    } else if (isInserting) {
      context.missing(_rawNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rawName};
  @override
  SubscribedTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscribedTag(
      rawName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubscribedTagsTable createAlias(String alias) {
    return $SubscribedTagsTable(attachedDatabase, alias);
  }
}

class SubscribedTag extends DataClass implements Insertable<SubscribedTag> {
  final String rawName;
  final DateTime createdAt;
  const SubscribedTag({required this.rawName, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['raw_name'] = Variable<String>(rawName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubscribedTagsCompanion toCompanion(bool nullToAbsent) {
    return SubscribedTagsCompanion(
      rawName: Value(rawName),
      createdAt: Value(createdAt),
    );
  }

  factory SubscribedTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscribedTag(
      rawName: serializer.fromJson<String>(json['rawName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rawName': serializer.toJson<String>(rawName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubscribedTag copyWith({String? rawName, DateTime? createdAt}) =>
      SubscribedTag(
        rawName: rawName ?? this.rawName,
        createdAt: createdAt ?? this.createdAt,
      );
  SubscribedTag copyWithCompanion(SubscribedTagsCompanion data) {
    return SubscribedTag(
      rawName: data.rawName.present ? data.rawName.value : this.rawName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscribedTag(')
          ..write('rawName: $rawName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rawName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscribedTag &&
          other.rawName == this.rawName &&
          other.createdAt == this.createdAt);
}

class SubscribedTagsCompanion extends UpdateCompanion<SubscribedTag> {
  final Value<String> rawName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SubscribedTagsCompanion({
    this.rawName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscribedTagsCompanion.insert({
    required String rawName,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : rawName = Value(rawName),
        createdAt = Value(createdAt);
  static Insertable<SubscribedTag> custom({
    Expression<String>? rawName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rawName != null) 'raw_name': rawName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscribedTagsCompanion copyWith(
      {Value<String>? rawName, Value<DateTime>? createdAt, Value<int>? rowid}) {
    return SubscribedTagsCompanion(
      rawName: rawName ?? this.rawName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rawName.present) {
      map['raw_name'] = Variable<String>(rawName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscribedTagsCompanion(')
          ..write('rawName: $rawName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FollowedCreatorsTable extends FollowedCreators
    with TableInfo<$FollowedCreatorsTable, FollowedCreator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowedCreatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastCheckedAtMeta =
      const VerificationMeta('lastCheckedAt');
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>('last_checked_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSeenPublishedAtMeta =
      const VerificationMeta('lastSeenPublishedAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenPublishedAt =
      GeneratedColumn<DateTime>('last_seen_published_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        source,
        kind,
        value,
        displayName,
        createdAt,
        lastCheckedAt,
        lastSeenPublishedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'followed_creators';
  @override
  VerificationContext validateIntegrity(Insertable<FollowedCreator> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
          _lastCheckedAtMeta,
          lastCheckedAt.isAcceptableOrUnknown(
              data['last_checked_at']!, _lastCheckedAtMeta));
    }
    if (data.containsKey('last_seen_published_at')) {
      context.handle(
          _lastSeenPublishedAtMeta,
          lastSeenPublishedAt.isAcceptableOrUnknown(
              data['last_seen_published_at']!, _lastSeenPublishedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FollowedCreator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FollowedCreator(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_checked_at']),
      lastSeenPublishedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_seen_published_at']),
    );
  }

  @override
  $FollowedCreatorsTable createAlias(String alias) {
    return $FollowedCreatorsTable(attachedDatabase, alias);
  }
}

class FollowedCreator extends DataClass implements Insertable<FollowedCreator> {
  final String id;
  final String source;
  final String kind;
  final String value;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastCheckedAt;
  final DateTime? lastSeenPublishedAt;
  const FollowedCreator(
      {required this.id,
      required this.source,
      required this.kind,
      required this.value,
      required this.displayName,
      required this.createdAt,
      this.lastCheckedAt,
      this.lastSeenPublishedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['kind'] = Variable<String>(kind);
    map['value'] = Variable<String>(value);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    if (!nullToAbsent || lastSeenPublishedAt != null) {
      map['last_seen_published_at'] = Variable<DateTime>(lastSeenPublishedAt);
    }
    return map;
  }

  FollowedCreatorsCompanion toCompanion(bool nullToAbsent) {
    return FollowedCreatorsCompanion(
      id: Value(id),
      source: Value(source),
      kind: Value(kind),
      value: Value(value),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      lastSeenPublishedAt: lastSeenPublishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenPublishedAt),
    );
  }

  factory FollowedCreator.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FollowedCreator(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<String>(json['value']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      lastSeenPublishedAt:
          serializer.fromJson<DateTime?>(json['lastSeenPublishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<String>(value),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'lastSeenPublishedAt': serializer.toJson<DateTime?>(lastSeenPublishedAt),
    };
  }

  FollowedCreator copyWith(
          {String? id,
          String? source,
          String? kind,
          String? value,
          String? displayName,
          DateTime? createdAt,
          Value<DateTime?> lastCheckedAt = const Value.absent(),
          Value<DateTime?> lastSeenPublishedAt = const Value.absent()}) =>
      FollowedCreator(
        id: id ?? this.id,
        source: source ?? this.source,
        kind: kind ?? this.kind,
        value: value ?? this.value,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt ?? this.createdAt,
        lastCheckedAt:
            lastCheckedAt.present ? lastCheckedAt.value : this.lastCheckedAt,
        lastSeenPublishedAt: lastSeenPublishedAt.present
            ? lastSeenPublishedAt.value
            : this.lastSeenPublishedAt,
      );
  FollowedCreator copyWithCompanion(FollowedCreatorsCompanion data) {
    return FollowedCreator(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      lastSeenPublishedAt: data.lastSeenPublishedAt.present
          ? data.lastSeenPublishedAt.value
          : this.lastSeenPublishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowedCreator(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSeenPublishedAt: $lastSeenPublishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, source, kind, value, displayName,
      createdAt, lastCheckedAt, lastSeenPublishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowedCreator &&
          other.id == this.id &&
          other.source == this.source &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.lastSeenPublishedAt == this.lastSeenPublishedAt);
}

class FollowedCreatorsCompanion extends UpdateCompanion<FollowedCreator> {
  final Value<String> id;
  final Value<String> source;
  final Value<String> kind;
  final Value<String> value;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime?> lastSeenPublishedAt;
  final Value<int> rowid;
  const FollowedCreatorsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastSeenPublishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FollowedCreatorsCompanion.insert({
    required String id,
    required String source,
    required String kind,
    required String value,
    required String displayName,
    required DateTime createdAt,
    this.lastCheckedAt = const Value.absent(),
    this.lastSeenPublishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        source = Value(source),
        kind = Value(kind),
        value = Value(value),
        displayName = Value(displayName),
        createdAt = Value(createdAt);
  static Insertable<FollowedCreator> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? kind,
    Expression<String>? value,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? lastSeenPublishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (lastSeenPublishedAt != null)
        'last_seen_published_at': lastSeenPublishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FollowedCreatorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? source,
      Value<String>? kind,
      Value<String>? value,
      Value<String>? displayName,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastCheckedAt,
      Value<DateTime?>? lastSeenPublishedAt,
      Value<int>? rowid}) {
    return FollowedCreatorsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSeenPublishedAt: lastSeenPublishedAt ?? this.lastSeenPublishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (lastSeenPublishedAt.present) {
      map['last_seen_published_at'] =
          Variable<DateTime>(lastSeenPublishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowedCreatorsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSeenPublishedAt: $lastSeenPublishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagDatabaseMetadataTable extends TagDatabaseMetadata
    with TableInfo<$TagDatabaseMetadataTable, TagDatabaseMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagDatabaseMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, version, source, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_database_metadata';
  @override
  VerificationContext validateIntegrity(
      Insertable<TagDatabaseMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagDatabaseMetadataData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagDatabaseMetadataData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TagDatabaseMetadataTable createAlias(String alias) {
    return $TagDatabaseMetadataTable(attachedDatabase, alias);
  }
}

class TagDatabaseMetadataData extends DataClass
    implements Insertable<TagDatabaseMetadataData> {
  final int id;
  final int version;
  final String source;
  final DateTime updatedAt;
  const TagDatabaseMetadataData(
      {required this.id,
      required this.version,
      required this.source,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<int>(version);
    map['source'] = Variable<String>(source);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagDatabaseMetadataCompanion toCompanion(bool nullToAbsent) {
    return TagDatabaseMetadataCompanion(
      id: Value(id),
      version: Value(version),
      source: Value(source),
      updatedAt: Value(updatedAt),
    );
  }

  factory TagDatabaseMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagDatabaseMetadataData(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      source: serializer.fromJson<String>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<int>(version),
      'source': serializer.toJson<String>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TagDatabaseMetadataData copyWith(
          {int? id, int? version, String? source, DateTime? updatedAt}) =>
      TagDatabaseMetadataData(
        id: id ?? this.id,
        version: version ?? this.version,
        source: source ?? this.source,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TagDatabaseMetadataData copyWithCompanion(TagDatabaseMetadataCompanion data) {
    return TagDatabaseMetadataData(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagDatabaseMetadataData(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, source, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagDatabaseMetadataData &&
          other.id == this.id &&
          other.version == this.version &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt);
}

class TagDatabaseMetadataCompanion
    extends UpdateCompanion<TagDatabaseMetadataData> {
  final Value<int> id;
  final Value<int> version;
  final Value<String> source;
  final Value<DateTime> updatedAt;
  const TagDatabaseMetadataCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TagDatabaseMetadataCompanion.insert({
    this.id = const Value.absent(),
    required int version,
    required String source,
    required DateTime updatedAt,
  })  : version = Value(version),
        source = Value(source),
        updatedAt = Value(updatedAt);
  static Insertable<TagDatabaseMetadataData> custom({
    Expression<int>? id,
    Expression<int>? version,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TagDatabaseMetadataCompanion copyWith(
      {Value<int>? id,
      Value<int>? version,
      Value<String>? source,
      Value<DateTime>? updatedAt}) {
    return TagDatabaseMetadataCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagDatabaseMetadataCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MigrationJournalTable extends MigrationJournal
    with TableInfo<$MigrationJournalTable, MigrationJournalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationJournalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceVersionMeta =
      const VerificationMeta('sourceVersion');
  @override
  late final GeneratedColumn<int> sourceVersion = GeneratedColumn<int>(
      'source_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importedAtMeta =
      const VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sourceVersion, status, checksum, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_journal';
  @override
  VerificationContext validateIntegrity(
      Insertable<MigrationJournalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_version')) {
      context.handle(
          _sourceVersionMeta,
          sourceVersion.isAcceptableOrUnknown(
              data['source_version']!, _sourceVersionMeta));
    } else if (isInserting) {
      context.missing(_sourceVersionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MigrationJournalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationJournalData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_version'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at']),
    );
  }

  @override
  $MigrationJournalTable createAlias(String alias) {
    return $MigrationJournalTable(attachedDatabase, alias);
  }
}

class MigrationJournalData extends DataClass
    implements Insertable<MigrationJournalData> {
  final String id;
  final int sourceVersion;
  final String status;
  final String? checksum;
  final DateTime? importedAt;
  const MigrationJournalData(
      {required this.id,
      required this.sourceVersion,
      required this.status,
      this.checksum,
      this.importedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_version'] = Variable<int>(sourceVersion);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    return map;
  }

  MigrationJournalCompanion toCompanion(bool nullToAbsent) {
    return MigrationJournalCompanion(
      id: Value(id),
      sourceVersion: Value(sourceVersion),
      status: Value(status),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
    );
  }

  factory MigrationJournalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationJournalData(
      id: serializer.fromJson<String>(json['id']),
      sourceVersion: serializer.fromJson<int>(json['sourceVersion']),
      status: serializer.fromJson<String>(json['status']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceVersion': serializer.toJson<int>(sourceVersion),
      'status': serializer.toJson<String>(status),
      'checksum': serializer.toJson<String?>(checksum),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
    };
  }

  MigrationJournalData copyWith(
          {String? id,
          int? sourceVersion,
          String? status,
          Value<String?> checksum = const Value.absent(),
          Value<DateTime?> importedAt = const Value.absent()}) =>
      MigrationJournalData(
        id: id ?? this.id,
        sourceVersion: sourceVersion ?? this.sourceVersion,
        status: status ?? this.status,
        checksum: checksum.present ? checksum.value : this.checksum,
        importedAt: importedAt.present ? importedAt.value : this.importedAt,
      );
  MigrationJournalData copyWithCompanion(MigrationJournalCompanion data) {
    return MigrationJournalData(
      id: data.id.present ? data.id.value : this.id,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      status: data.status.present ? data.status.value : this.status,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      importedAt:
          data.importedAt.present ? data.importedAt.value : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationJournalData(')
          ..write('id: $id, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('status: $status, ')
          ..write('checksum: $checksum, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceVersion, status, checksum, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationJournalData &&
          other.id == this.id &&
          other.sourceVersion == this.sourceVersion &&
          other.status == this.status &&
          other.checksum == this.checksum &&
          other.importedAt == this.importedAt);
}

class MigrationJournalCompanion extends UpdateCompanion<MigrationJournalData> {
  final Value<String> id;
  final Value<int> sourceVersion;
  final Value<String> status;
  final Value<String?> checksum;
  final Value<DateTime?> importedAt;
  final Value<int> rowid;
  const MigrationJournalCompanion({
    this.id = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.checksum = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MigrationJournalCompanion.insert({
    required String id,
    required int sourceVersion,
    required String status,
    this.checksum = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceVersion = Value(sourceVersion),
        status = Value(status);
  static Insertable<MigrationJournalData> custom({
    Expression<String>? id,
    Expression<int>? sourceVersion,
    Expression<String>? status,
    Expression<String>? checksum,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (status != null) 'status': status,
      if (checksum != null) 'checksum': checksum,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MigrationJournalCompanion copyWith(
      {Value<String>? id,
      Value<int>? sourceVersion,
      Value<String>? status,
      Value<String?>? checksum,
      Value<DateTime?>? importedAt,
      Value<int>? rowid}) {
    return MigrationJournalCompanion(
      id: id ?? this.id,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      status: status ?? this.status,
      checksum: checksum ?? this.checksum,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<int>(sourceVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationJournalCompanion(')
          ..write('id: $id, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('status: $status, ')
          ..write('checksum: $checksum, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GalleriesTable galleries = $GalleriesTable(this);
  late final $LibraryEntriesTable libraryEntries = $LibraryEntriesTable(this);
  late final $ReadingProgressEntriesTable readingProgressEntries =
      $ReadingProgressEntriesTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $DownloadPagesTable downloadPages = $DownloadPagesTable(this);
  late final $ImageUrlCacheEntriesTable imageUrlCacheEntries =
      $ImageUrlCacheEntriesTable(this);
  late final $SearchHistoryEntriesTable searchHistoryEntries =
      $SearchHistoryEntriesTable(this);
  late final $SubscribedTagsTable subscribedTags = $SubscribedTagsTable(this);
  late final $FollowedCreatorsTable followedCreators =
      $FollowedCreatorsTable(this);
  late final $TagDatabaseMetadataTable tagDatabaseMetadata =
      $TagDatabaseMetadataTable(this);
  late final $MigrationJournalTable migrationJournal =
      $MigrationJournalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        galleries,
        libraryEntries,
        readingProgressEntries,
        downloadTasks,
        downloadPages,
        imageUrlCacheEntries,
        searchHistoryEntries,
        subscribedTags,
        followedCreators,
        tagDatabaseMetadata,
        migrationJournal
      ];
}

typedef $$GalleriesTableCreateCompanionBuilder = GalleriesCompanion Function({
  required String source,
  required int gid,
  required String title,
  Value<String> uploader,
  Value<String> category,
  Value<String?> thumbnailUrl,
  Value<String?> sourceUrl,
  Value<int> pageCount,
  Value<String> tagsJson,
  Value<double?> rating,
  Value<DateTime?> postedAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GalleriesTableUpdateCompanionBuilder = GalleriesCompanion Function({
  Value<String> source,
  Value<int> gid,
  Value<String> title,
  Value<String> uploader,
  Value<String> category,
  Value<String?> thumbnailUrl,
  Value<String?> sourceUrl,
  Value<int> pageCount,
  Value<String> tagsJson,
  Value<double?> rating,
  Value<DateTime?> postedAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GalleriesTableFilterComposer
    extends Composer<_$AppDatabase, $GalleriesTable> {
  $$GalleriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploader => $composableBuilder(
      column: $table.uploader, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get postedAt => $composableBuilder(
      column: $table.postedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GalleriesTableOrderingComposer
    extends Composer<_$AppDatabase, $GalleriesTable> {
  $$GalleriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploader => $composableBuilder(
      column: $table.uploader, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get postedAt => $composableBuilder(
      column: $table.postedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GalleriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GalleriesTable> {
  $$GalleriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get gid =>
      $composableBuilder(column: $table.gid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get uploader =>
      $composableBuilder(column: $table.uploader, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get postedAt =>
      $composableBuilder(column: $table.postedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GalleriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GalleriesTable,
    GalleryRow,
    $$GalleriesTableFilterComposer,
    $$GalleriesTableOrderingComposer,
    $$GalleriesTableAnnotationComposer,
    $$GalleriesTableCreateCompanionBuilder,
    $$GalleriesTableUpdateCompanionBuilder,
    (GalleryRow, BaseReferences<_$AppDatabase, $GalleriesTable, GalleryRow>),
    GalleryRow,
    PrefetchHooks Function()> {
  $$GalleriesTableTableManager(_$AppDatabase db, $GalleriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GalleriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GalleriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GalleriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> source = const Value.absent(),
            Value<int> gid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> uploader = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<DateTime?> postedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GalleriesCompanion(
            source: source,
            gid: gid,
            title: title,
            uploader: uploader,
            category: category,
            thumbnailUrl: thumbnailUrl,
            sourceUrl: sourceUrl,
            pageCount: pageCount,
            tagsJson: tagsJson,
            rating: rating,
            postedAt: postedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String source,
            required int gid,
            required String title,
            Value<String> uploader = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<DateTime?> postedAt = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GalleriesCompanion.insert(
            source: source,
            gid: gid,
            title: title,
            uploader: uploader,
            category: category,
            thumbnailUrl: thumbnailUrl,
            sourceUrl: sourceUrl,
            pageCount: pageCount,
            tagsJson: tagsJson,
            rating: rating,
            postedAt: postedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GalleriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GalleriesTable,
    GalleryRow,
    $$GalleriesTableFilterComposer,
    $$GalleriesTableOrderingComposer,
    $$GalleriesTableAnnotationComposer,
    $$GalleriesTableCreateCompanionBuilder,
    $$GalleriesTableUpdateCompanionBuilder,
    (GalleryRow, BaseReferences<_$AppDatabase, $GalleriesTable, GalleryRow>),
    GalleryRow,
    PrefetchHooks Function()>;
typedef $$LibraryEntriesTableCreateCompanionBuilder = LibraryEntriesCompanion
    Function({
  required String source,
  required int gid,
  Value<bool> isFavorite,
  Value<DateTime?> favoritedAt,
  Value<DateTime?> lastOpenedAt,
  Value<int> rowid,
});
typedef $$LibraryEntriesTableUpdateCompanionBuilder = LibraryEntriesCompanion
    Function({
  Value<String> source,
  Value<int> gid,
  Value<bool> isFavorite,
  Value<DateTime?> favoritedAt,
  Value<DateTime?> lastOpenedAt,
  Value<int> rowid,
});

class $$LibraryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get favoritedAt => $composableBuilder(
      column: $table.favoritedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
      column: $table.lastOpenedAt, builder: (column) => ColumnFilters(column));
}

class $$LibraryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get favoritedAt => $composableBuilder(
      column: $table.favoritedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
      column: $table.lastOpenedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LibraryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get gid =>
      $composableBuilder(column: $table.gid, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get favoritedAt => $composableBuilder(
      column: $table.favoritedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
      column: $table.lastOpenedAt, builder: (column) => column);
}

class $$LibraryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LibraryEntriesTable,
    LibraryEntry,
    $$LibraryEntriesTableFilterComposer,
    $$LibraryEntriesTableOrderingComposer,
    $$LibraryEntriesTableAnnotationComposer,
    $$LibraryEntriesTableCreateCompanionBuilder,
    $$LibraryEntriesTableUpdateCompanionBuilder,
    (
      LibraryEntry,
      BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry>
    ),
    LibraryEntry,
    PrefetchHooks Function()> {
  $$LibraryEntriesTableTableManager(
      _$AppDatabase db, $LibraryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> source = const Value.absent(),
            Value<int> gid = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> favoritedAt = const Value.absent(),
            Value<DateTime?> lastOpenedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryEntriesCompanion(
            source: source,
            gid: gid,
            isFavorite: isFavorite,
            favoritedAt: favoritedAt,
            lastOpenedAt: lastOpenedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String source,
            required int gid,
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> favoritedAt = const Value.absent(),
            Value<DateTime?> lastOpenedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryEntriesCompanion.insert(
            source: source,
            gid: gid,
            isFavorite: isFavorite,
            favoritedAt: favoritedAt,
            lastOpenedAt: lastOpenedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LibraryEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LibraryEntriesTable,
    LibraryEntry,
    $$LibraryEntriesTableFilterComposer,
    $$LibraryEntriesTableOrderingComposer,
    $$LibraryEntriesTableAnnotationComposer,
    $$LibraryEntriesTableCreateCompanionBuilder,
    $$LibraryEntriesTableUpdateCompanionBuilder,
    (
      LibraryEntry,
      BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry>
    ),
    LibraryEntry,
    PrefetchHooks Function()>;
typedef $$ReadingProgressEntriesTableCreateCompanionBuilder
    = ReadingProgressEntriesCompanion Function({
  required String source,
  required int gid,
  required int pageIndex,
  required int pageCount,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ReadingProgressEntriesTableUpdateCompanionBuilder
    = ReadingProgressEntriesCompanion Function({
  Value<String> source,
  Value<int> gid,
  Value<int> pageIndex,
  Value<int> pageCount,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ReadingProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressEntriesTable> {
  $$ReadingProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ReadingProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressEntriesTable> {
  $$ReadingProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReadingProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressEntriesTable> {
  $$ReadingProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get gid =>
      $composableBuilder(column: $table.gid, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingProgressEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingProgressEntriesTable,
    ReadingProgressEntry,
    $$ReadingProgressEntriesTableFilterComposer,
    $$ReadingProgressEntriesTableOrderingComposer,
    $$ReadingProgressEntriesTableAnnotationComposer,
    $$ReadingProgressEntriesTableCreateCompanionBuilder,
    $$ReadingProgressEntriesTableUpdateCompanionBuilder,
    (
      ReadingProgressEntry,
      BaseReferences<_$AppDatabase, $ReadingProgressEntriesTable,
          ReadingProgressEntry>
    ),
    ReadingProgressEntry,
    PrefetchHooks Function()> {
  $$ReadingProgressEntriesTableTableManager(
      _$AppDatabase db, $ReadingProgressEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> source = const Value.absent(),
            Value<int> gid = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressEntriesCompanion(
            source: source,
            gid: gid,
            pageIndex: pageIndex,
            pageCount: pageCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String source,
            required int gid,
            required int pageIndex,
            required int pageCount,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressEntriesCompanion.insert(
            source: source,
            gid: gid,
            pageIndex: pageIndex,
            pageCount: pageCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingProgressEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ReadingProgressEntriesTable,
        ReadingProgressEntry,
        $$ReadingProgressEntriesTableFilterComposer,
        $$ReadingProgressEntriesTableOrderingComposer,
        $$ReadingProgressEntriesTableAnnotationComposer,
        $$ReadingProgressEntriesTableCreateCompanionBuilder,
        $$ReadingProgressEntriesTableUpdateCompanionBuilder,
        (
          ReadingProgressEntry,
          BaseReferences<_$AppDatabase, $ReadingProgressEntriesTable,
              ReadingProgressEntry>
        ),
        ReadingProgressEntry,
        PrefetchHooks Function()>;
typedef $$DownloadTasksTableCreateCompanionBuilder = DownloadTasksCompanion
    Function({
  required String id,
  required String source,
  required int gid,
  required String status,
  Value<int> totalPages,
  Value<int> completedPages,
  Value<String?> targetDirectory,
  Value<String?> failureCode,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DownloadTasksTableUpdateCompanionBuilder = DownloadTasksCompanion
    Function({
  Value<String> id,
  Value<String> source,
  Value<int> gid,
  Value<String> status,
  Value<int> totalPages,
  Value<int> completedPages,
  Value<String?> targetDirectory,
  Value<String?> failureCode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DownloadTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedPages => $composableBuilder(
      column: $table.completedPages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDirectory => $composableBuilder(
      column: $table.targetDirectory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get failureCode => $composableBuilder(
      column: $table.failureCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DownloadTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedPages => $composableBuilder(
      column: $table.completedPages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDirectory => $composableBuilder(
      column: $table.targetDirectory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get failureCode => $composableBuilder(
      column: $table.failureCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get gid =>
      $composableBuilder(column: $table.gid, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  GeneratedColumn<int> get completedPages => $composableBuilder(
      column: $table.completedPages, builder: (column) => column);

  GeneratedColumn<String> get targetDirectory => $composableBuilder(
      column: $table.targetDirectory, builder: (column) => column);

  GeneratedColumn<String> get failureCode => $composableBuilder(
      column: $table.failureCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadTasksTable,
    DownloadTask,
    $$DownloadTasksTableFilterComposer,
    $$DownloadTasksTableOrderingComposer,
    $$DownloadTasksTableAnnotationComposer,
    $$DownloadTasksTableCreateCompanionBuilder,
    $$DownloadTasksTableUpdateCompanionBuilder,
    (
      DownloadTask,
      BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>
    ),
    DownloadTask,
    PrefetchHooks Function()> {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> gid = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<int> completedPages = const Value.absent(),
            Value<String?> targetDirectory = const Value.absent(),
            Value<String?> failureCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadTasksCompanion(
            id: id,
            source: source,
            gid: gid,
            status: status,
            totalPages: totalPages,
            completedPages: completedPages,
            targetDirectory: targetDirectory,
            failureCode: failureCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String source,
            required int gid,
            required String status,
            Value<int> totalPages = const Value.absent(),
            Value<int> completedPages = const Value.absent(),
            Value<String?> targetDirectory = const Value.absent(),
            Value<String?> failureCode = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadTasksCompanion.insert(
            id: id,
            source: source,
            gid: gid,
            status: status,
            totalPages: totalPages,
            completedPages: completedPages,
            targetDirectory: targetDirectory,
            failureCode: failureCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadTasksTable,
    DownloadTask,
    $$DownloadTasksTableFilterComposer,
    $$DownloadTasksTableOrderingComposer,
    $$DownloadTasksTableAnnotationComposer,
    $$DownloadTasksTableCreateCompanionBuilder,
    $$DownloadTasksTableUpdateCompanionBuilder,
    (
      DownloadTask,
      BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>
    ),
    DownloadTask,
    PrefetchHooks Function()>;
typedef $$DownloadPagesTableCreateCompanionBuilder = DownloadPagesCompanion
    Function({
  required String taskId,
  required int pageIndex,
  Value<String?> pageUrl,
  Value<String?> localPath,
  Value<int> byteCount,
  required String status,
  Value<String?> checksum,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DownloadPagesTableUpdateCompanionBuilder = DownloadPagesCompanion
    Function({
  Value<String> taskId,
  Value<int> pageIndex,
  Value<String?> pageUrl,
  Value<String?> localPath,
  Value<int> byteCount,
  Value<String> status,
  Value<String?> checksum,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DownloadPagesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadPagesTable> {
  $$DownloadPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageUrl => $composableBuilder(
      column: $table.pageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get byteCount => $composableBuilder(
      column: $table.byteCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DownloadPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadPagesTable> {
  $$DownloadPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageUrl => $composableBuilder(
      column: $table.pageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get byteCount => $composableBuilder(
      column: $table.byteCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadPagesTable> {
  $$DownloadPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<String> get pageUrl =>
      $composableBuilder(column: $table.pageUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get byteCount =>
      $composableBuilder(column: $table.byteCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadPagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadPagesTable,
    DownloadPage,
    $$DownloadPagesTableFilterComposer,
    $$DownloadPagesTableOrderingComposer,
    $$DownloadPagesTableAnnotationComposer,
    $$DownloadPagesTableCreateCompanionBuilder,
    $$DownloadPagesTableUpdateCompanionBuilder,
    (
      DownloadPage,
      BaseReferences<_$AppDatabase, $DownloadPagesTable, DownloadPage>
    ),
    DownloadPage,
    PrefetchHooks Function()> {
  $$DownloadPagesTableTableManager(_$AppDatabase db, $DownloadPagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<String?> pageUrl = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<int> byteCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadPagesCompanion(
            taskId: taskId,
            pageIndex: pageIndex,
            pageUrl: pageUrl,
            localPath: localPath,
            byteCount: byteCount,
            status: status,
            checksum: checksum,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required int pageIndex,
            Value<String?> pageUrl = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<int> byteCount = const Value.absent(),
            required String status,
            Value<String?> checksum = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadPagesCompanion.insert(
            taskId: taskId,
            pageIndex: pageIndex,
            pageUrl: pageUrl,
            localPath: localPath,
            byteCount: byteCount,
            status: status,
            checksum: checksum,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadPagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadPagesTable,
    DownloadPage,
    $$DownloadPagesTableFilterComposer,
    $$DownloadPagesTableOrderingComposer,
    $$DownloadPagesTableAnnotationComposer,
    $$DownloadPagesTableCreateCompanionBuilder,
    $$DownloadPagesTableUpdateCompanionBuilder,
    (
      DownloadPage,
      BaseReferences<_$AppDatabase, $DownloadPagesTable, DownloadPage>
    ),
    DownloadPage,
    PrefetchHooks Function()>;
typedef $$ImageUrlCacheEntriesTableCreateCompanionBuilder
    = ImageUrlCacheEntriesCompanion Function({
  required String source,
  required int gid,
  required int pageIndex,
  Value<String?> pageUrl,
  Value<String?> resolvedImageUrl,
  required DateTime expiresAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ImageUrlCacheEntriesTableUpdateCompanionBuilder
    = ImageUrlCacheEntriesCompanion Function({
  Value<String> source,
  Value<int> gid,
  Value<int> pageIndex,
  Value<String?> pageUrl,
  Value<String?> resolvedImageUrl,
  Value<DateTime> expiresAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ImageUrlCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ImageUrlCacheEntriesTable> {
  $$ImageUrlCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageUrl => $composableBuilder(
      column: $table.pageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolvedImageUrl => $composableBuilder(
      column: $table.resolvedImageUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ImageUrlCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageUrlCacheEntriesTable> {
  $$ImageUrlCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gid => $composableBuilder(
      column: $table.gid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageUrl => $composableBuilder(
      column: $table.pageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolvedImageUrl => $composableBuilder(
      column: $table.resolvedImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ImageUrlCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageUrlCacheEntriesTable> {
  $$ImageUrlCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get gid =>
      $composableBuilder(column: $table.gid, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<String> get pageUrl =>
      $composableBuilder(column: $table.pageUrl, builder: (column) => column);

  GeneratedColumn<String> get resolvedImageUrl => $composableBuilder(
      column: $table.resolvedImageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ImageUrlCacheEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageUrlCacheEntriesTable,
    ImageUrlCacheEntry,
    $$ImageUrlCacheEntriesTableFilterComposer,
    $$ImageUrlCacheEntriesTableOrderingComposer,
    $$ImageUrlCacheEntriesTableAnnotationComposer,
    $$ImageUrlCacheEntriesTableCreateCompanionBuilder,
    $$ImageUrlCacheEntriesTableUpdateCompanionBuilder,
    (
      ImageUrlCacheEntry,
      BaseReferences<_$AppDatabase, $ImageUrlCacheEntriesTable,
          ImageUrlCacheEntry>
    ),
    ImageUrlCacheEntry,
    PrefetchHooks Function()> {
  $$ImageUrlCacheEntriesTableTableManager(
      _$AppDatabase db, $ImageUrlCacheEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageUrlCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageUrlCacheEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageUrlCacheEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> source = const Value.absent(),
            Value<int> gid = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<String?> pageUrl = const Value.absent(),
            Value<String?> resolvedImageUrl = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageUrlCacheEntriesCompanion(
            source: source,
            gid: gid,
            pageIndex: pageIndex,
            pageUrl: pageUrl,
            resolvedImageUrl: resolvedImageUrl,
            expiresAt: expiresAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String source,
            required int gid,
            required int pageIndex,
            Value<String?> pageUrl = const Value.absent(),
            Value<String?> resolvedImageUrl = const Value.absent(),
            required DateTime expiresAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageUrlCacheEntriesCompanion.insert(
            source: source,
            gid: gid,
            pageIndex: pageIndex,
            pageUrl: pageUrl,
            resolvedImageUrl: resolvedImageUrl,
            expiresAt: expiresAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImageUrlCacheEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ImageUrlCacheEntriesTable,
        ImageUrlCacheEntry,
        $$ImageUrlCacheEntriesTableFilterComposer,
        $$ImageUrlCacheEntriesTableOrderingComposer,
        $$ImageUrlCacheEntriesTableAnnotationComposer,
        $$ImageUrlCacheEntriesTableCreateCompanionBuilder,
        $$ImageUrlCacheEntriesTableUpdateCompanionBuilder,
        (
          ImageUrlCacheEntry,
          BaseReferences<_$AppDatabase, $ImageUrlCacheEntriesTable,
              ImageUrlCacheEntry>
        ),
        ImageUrlCacheEntry,
        PrefetchHooks Function()>;
typedef $$SearchHistoryEntriesTableCreateCompanionBuilder
    = SearchHistoryEntriesCompanion Function({
  Value<int> id,
  required String query,
  required DateTime usedAt,
});
typedef $$SearchHistoryEntriesTableUpdateCompanionBuilder
    = SearchHistoryEntriesCompanion Function({
  Value<int> id,
  Value<String> query,
  Value<DateTime> usedAt,
});

class $$SearchHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnFilters(column));
}

class $$SearchHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnOrderings(column));
}

class $$SearchHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);
}

class $$SearchHistoryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchHistoryEntriesTable,
    SearchHistoryEntry,
    $$SearchHistoryEntriesTableFilterComposer,
    $$SearchHistoryEntriesTableOrderingComposer,
    $$SearchHistoryEntriesTableAnnotationComposer,
    $$SearchHistoryEntriesTableCreateCompanionBuilder,
    $$SearchHistoryEntriesTableUpdateCompanionBuilder,
    (
      SearchHistoryEntry,
      BaseReferences<_$AppDatabase, $SearchHistoryEntriesTable,
          SearchHistoryEntry>
    ),
    SearchHistoryEntry,
    PrefetchHooks Function()> {
  $$SearchHistoryEntriesTableTableManager(
      _$AppDatabase db, $SearchHistoryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> query = const Value.absent(),
            Value<DateTime> usedAt = const Value.absent(),
          }) =>
              SearchHistoryEntriesCompanion(
            id: id,
            query: query,
            usedAt: usedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String query,
            required DateTime usedAt,
          }) =>
              SearchHistoryEntriesCompanion.insert(
            id: id,
            query: query,
            usedAt: usedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchHistoryEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SearchHistoryEntriesTable,
        SearchHistoryEntry,
        $$SearchHistoryEntriesTableFilterComposer,
        $$SearchHistoryEntriesTableOrderingComposer,
        $$SearchHistoryEntriesTableAnnotationComposer,
        $$SearchHistoryEntriesTableCreateCompanionBuilder,
        $$SearchHistoryEntriesTableUpdateCompanionBuilder,
        (
          SearchHistoryEntry,
          BaseReferences<_$AppDatabase, $SearchHistoryEntriesTable,
              SearchHistoryEntry>
        ),
        SearchHistoryEntry,
        PrefetchHooks Function()>;
typedef $$SubscribedTagsTableCreateCompanionBuilder = SubscribedTagsCompanion
    Function({
  required String rawName,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SubscribedTagsTableUpdateCompanionBuilder = SubscribedTagsCompanion
    Function({
  Value<String> rawName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SubscribedTagsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscribedTagsTable> {
  $$SubscribedTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rawName => $composableBuilder(
      column: $table.rawName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SubscribedTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscribedTagsTable> {
  $$SubscribedTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rawName => $composableBuilder(
      column: $table.rawName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SubscribedTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscribedTagsTable> {
  $$SubscribedTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rawName =>
      $composableBuilder(column: $table.rawName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SubscribedTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscribedTagsTable,
    SubscribedTag,
    $$SubscribedTagsTableFilterComposer,
    $$SubscribedTagsTableOrderingComposer,
    $$SubscribedTagsTableAnnotationComposer,
    $$SubscribedTagsTableCreateCompanionBuilder,
    $$SubscribedTagsTableUpdateCompanionBuilder,
    (
      SubscribedTag,
      BaseReferences<_$AppDatabase, $SubscribedTagsTable, SubscribedTag>
    ),
    SubscribedTag,
    PrefetchHooks Function()> {
  $$SubscribedTagsTableTableManager(
      _$AppDatabase db, $SubscribedTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscribedTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscribedTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscribedTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> rawName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscribedTagsCompanion(
            rawName: rawName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String rawName,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscribedTagsCompanion.insert(
            rawName: rawName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscribedTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscribedTagsTable,
    SubscribedTag,
    $$SubscribedTagsTableFilterComposer,
    $$SubscribedTagsTableOrderingComposer,
    $$SubscribedTagsTableAnnotationComposer,
    $$SubscribedTagsTableCreateCompanionBuilder,
    $$SubscribedTagsTableUpdateCompanionBuilder,
    (
      SubscribedTag,
      BaseReferences<_$AppDatabase, $SubscribedTagsTable, SubscribedTag>
    ),
    SubscribedTag,
    PrefetchHooks Function()>;
typedef $$FollowedCreatorsTableCreateCompanionBuilder
    = FollowedCreatorsCompanion Function({
  required String id,
  required String source,
  required String kind,
  required String value,
  required String displayName,
  required DateTime createdAt,
  Value<DateTime?> lastCheckedAt,
  Value<DateTime?> lastSeenPublishedAt,
  Value<int> rowid,
});
typedef $$FollowedCreatorsTableUpdateCompanionBuilder
    = FollowedCreatorsCompanion Function({
  Value<String> id,
  Value<String> source,
  Value<String> kind,
  Value<String> value,
  Value<String> displayName,
  Value<DateTime> createdAt,
  Value<DateTime?> lastCheckedAt,
  Value<DateTime?> lastSeenPublishedAt,
  Value<int> rowid,
});

class $$FollowedCreatorsTableFilterComposer
    extends Composer<_$AppDatabase, $FollowedCreatorsTable> {
  $$FollowedCreatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeenPublishedAt => $composableBuilder(
      column: $table.lastSeenPublishedAt,
      builder: (column) => ColumnFilters(column));
}

class $$FollowedCreatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $FollowedCreatorsTable> {
  $$FollowedCreatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeenPublishedAt => $composableBuilder(
      column: $table.lastSeenPublishedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$FollowedCreatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FollowedCreatorsTable> {
  $$FollowedCreatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenPublishedAt => $composableBuilder(
      column: $table.lastSeenPublishedAt, builder: (column) => column);
}

class $$FollowedCreatorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FollowedCreatorsTable,
    FollowedCreator,
    $$FollowedCreatorsTableFilterComposer,
    $$FollowedCreatorsTableOrderingComposer,
    $$FollowedCreatorsTableAnnotationComposer,
    $$FollowedCreatorsTableCreateCompanionBuilder,
    $$FollowedCreatorsTableUpdateCompanionBuilder,
    (
      FollowedCreator,
      BaseReferences<_$AppDatabase, $FollowedCreatorsTable, FollowedCreator>
    ),
    FollowedCreator,
    PrefetchHooks Function()> {
  $$FollowedCreatorsTableTableManager(
      _$AppDatabase db, $FollowedCreatorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FollowedCreatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowedCreatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowedCreatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<DateTime?> lastSeenPublishedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FollowedCreatorsCompanion(
            id: id,
            source: source,
            kind: kind,
            value: value,
            displayName: displayName,
            createdAt: createdAt,
            lastCheckedAt: lastCheckedAt,
            lastSeenPublishedAt: lastSeenPublishedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String source,
            required String kind,
            required String value,
            required String displayName,
            required DateTime createdAt,
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<DateTime?> lastSeenPublishedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FollowedCreatorsCompanion.insert(
            id: id,
            source: source,
            kind: kind,
            value: value,
            displayName: displayName,
            createdAt: createdAt,
            lastCheckedAt: lastCheckedAt,
            lastSeenPublishedAt: lastSeenPublishedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FollowedCreatorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FollowedCreatorsTable,
    FollowedCreator,
    $$FollowedCreatorsTableFilterComposer,
    $$FollowedCreatorsTableOrderingComposer,
    $$FollowedCreatorsTableAnnotationComposer,
    $$FollowedCreatorsTableCreateCompanionBuilder,
    $$FollowedCreatorsTableUpdateCompanionBuilder,
    (
      FollowedCreator,
      BaseReferences<_$AppDatabase, $FollowedCreatorsTable, FollowedCreator>
    ),
    FollowedCreator,
    PrefetchHooks Function()>;
typedef $$TagDatabaseMetadataTableCreateCompanionBuilder
    = TagDatabaseMetadataCompanion Function({
  Value<int> id,
  required int version,
  required String source,
  required DateTime updatedAt,
});
typedef $$TagDatabaseMetadataTableUpdateCompanionBuilder
    = TagDatabaseMetadataCompanion Function({
  Value<int> id,
  Value<int> version,
  Value<String> source,
  Value<DateTime> updatedAt,
});

class $$TagDatabaseMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $TagDatabaseMetadataTable> {
  $$TagDatabaseMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TagDatabaseMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $TagDatabaseMetadataTable> {
  $$TagDatabaseMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TagDatabaseMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagDatabaseMetadataTable> {
  $$TagDatabaseMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TagDatabaseMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagDatabaseMetadataTable,
    TagDatabaseMetadataData,
    $$TagDatabaseMetadataTableFilterComposer,
    $$TagDatabaseMetadataTableOrderingComposer,
    $$TagDatabaseMetadataTableAnnotationComposer,
    $$TagDatabaseMetadataTableCreateCompanionBuilder,
    $$TagDatabaseMetadataTableUpdateCompanionBuilder,
    (
      TagDatabaseMetadataData,
      BaseReferences<_$AppDatabase, $TagDatabaseMetadataTable,
          TagDatabaseMetadataData>
    ),
    TagDatabaseMetadataData,
    PrefetchHooks Function()> {
  $$TagDatabaseMetadataTableTableManager(
      _$AppDatabase db, $TagDatabaseMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagDatabaseMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagDatabaseMetadataTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagDatabaseMetadataTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TagDatabaseMetadataCompanion(
            id: id,
            version: version,
            source: source,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int version,
            required String source,
            required DateTime updatedAt,
          }) =>
              TagDatabaseMetadataCompanion.insert(
            id: id,
            version: version,
            source: source,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagDatabaseMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagDatabaseMetadataTable,
    TagDatabaseMetadataData,
    $$TagDatabaseMetadataTableFilterComposer,
    $$TagDatabaseMetadataTableOrderingComposer,
    $$TagDatabaseMetadataTableAnnotationComposer,
    $$TagDatabaseMetadataTableCreateCompanionBuilder,
    $$TagDatabaseMetadataTableUpdateCompanionBuilder,
    (
      TagDatabaseMetadataData,
      BaseReferences<_$AppDatabase, $TagDatabaseMetadataTable,
          TagDatabaseMetadataData>
    ),
    TagDatabaseMetadataData,
    PrefetchHooks Function()>;
typedef $$MigrationJournalTableCreateCompanionBuilder
    = MigrationJournalCompanion Function({
  required String id,
  required int sourceVersion,
  required String status,
  Value<String?> checksum,
  Value<DateTime?> importedAt,
  Value<int> rowid,
});
typedef $$MigrationJournalTableUpdateCompanionBuilder
    = MigrationJournalCompanion Function({
  Value<String> id,
  Value<int> sourceVersion,
  Value<String> status,
  Value<String?> checksum,
  Value<DateTime?> importedAt,
  Value<int> rowid,
});

class $$MigrationJournalTableFilterComposer
    extends Composer<_$AppDatabase, $MigrationJournalTable> {
  $$MigrationJournalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourceVersion => $composableBuilder(
      column: $table.sourceVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnFilters(column));
}

class $$MigrationJournalTableOrderingComposer
    extends Composer<_$AppDatabase, $MigrationJournalTable> {
  $$MigrationJournalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourceVersion => $composableBuilder(
      column: $table.sourceVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnOrderings(column));
}

class $$MigrationJournalTableAnnotationComposer
    extends Composer<_$AppDatabase, $MigrationJournalTable> {
  $$MigrationJournalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceVersion => $composableBuilder(
      column: $table.sourceVersion, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => column);
}

class $$MigrationJournalTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MigrationJournalTable,
    MigrationJournalData,
    $$MigrationJournalTableFilterComposer,
    $$MigrationJournalTableOrderingComposer,
    $$MigrationJournalTableAnnotationComposer,
    $$MigrationJournalTableCreateCompanionBuilder,
    $$MigrationJournalTableUpdateCompanionBuilder,
    (
      MigrationJournalData,
      BaseReferences<_$AppDatabase, $MigrationJournalTable,
          MigrationJournalData>
    ),
    MigrationJournalData,
    PrefetchHooks Function()> {
  $$MigrationJournalTableTableManager(
      _$AppDatabase db, $MigrationJournalTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationJournalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationJournalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MigrationJournalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> sourceVersion = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<DateTime?> importedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MigrationJournalCompanion(
            id: id,
            sourceVersion: sourceVersion,
            status: status,
            checksum: checksum,
            importedAt: importedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int sourceVersion,
            required String status,
            Value<String?> checksum = const Value.absent(),
            Value<DateTime?> importedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MigrationJournalCompanion.insert(
            id: id,
            sourceVersion: sourceVersion,
            status: status,
            checksum: checksum,
            importedAt: importedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MigrationJournalTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MigrationJournalTable,
    MigrationJournalData,
    $$MigrationJournalTableFilterComposer,
    $$MigrationJournalTableOrderingComposer,
    $$MigrationJournalTableAnnotationComposer,
    $$MigrationJournalTableCreateCompanionBuilder,
    $$MigrationJournalTableUpdateCompanionBuilder,
    (
      MigrationJournalData,
      BaseReferences<_$AppDatabase, $MigrationJournalTable,
          MigrationJournalData>
    ),
    MigrationJournalData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GalleriesTableTableManager get galleries =>
      $$GalleriesTableTableManager(_db, _db.galleries);
  $$LibraryEntriesTableTableManager get libraryEntries =>
      $$LibraryEntriesTableTableManager(_db, _db.libraryEntries);
  $$ReadingProgressEntriesTableTableManager get readingProgressEntries =>
      $$ReadingProgressEntriesTableTableManager(
          _db, _db.readingProgressEntries);
  $$DownloadTasksTableTableManager get downloadTasks =>
      $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$DownloadPagesTableTableManager get downloadPages =>
      $$DownloadPagesTableTableManager(_db, _db.downloadPages);
  $$ImageUrlCacheEntriesTableTableManager get imageUrlCacheEntries =>
      $$ImageUrlCacheEntriesTableTableManager(_db, _db.imageUrlCacheEntries);
  $$SearchHistoryEntriesTableTableManager get searchHistoryEntries =>
      $$SearchHistoryEntriesTableTableManager(_db, _db.searchHistoryEntries);
  $$SubscribedTagsTableTableManager get subscribedTags =>
      $$SubscribedTagsTableTableManager(_db, _db.subscribedTags);
  $$FollowedCreatorsTableTableManager get followedCreators =>
      $$FollowedCreatorsTableTableManager(_db, _db.followedCreators);
  $$TagDatabaseMetadataTableTableManager get tagDatabaseMetadata =>
      $$TagDatabaseMetadataTableTableManager(_db, _db.tagDatabaseMetadata);
  $$MigrationJournalTableTableManager get migrationJournal =>
      $$MigrationJournalTableTableManager(_db, _db.migrationJournal);
}
