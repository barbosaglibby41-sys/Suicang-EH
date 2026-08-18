import 'gallery_key.dart';
import 'gallery_tag.dart';

class Gallery {
  const Gallery({
    required this.key,
    required this.title,
    required this.pageCount,
    this.uploader = '',
    this.category = '',
    this.thumbnailUrl,
    this.sourceUrl,
    this.tags = const [],
    this.rating,
    this.postedAt,
  }) : assert(pageCount >= 0, 'pageCount cannot be negative');

  final GalleryKey key;
  final String title;
  final String uploader;
  final String category;
  final Uri? thumbnailUrl;
  final Uri? sourceUrl;
  final int pageCount;
  final List<GalleryTag> tags;
  final double? rating;
  final DateTime? postedAt;

  Gallery copyWith({
    String? title,
    String? uploader,
    String? category,
    Uri? thumbnailUrl,
    Uri? sourceUrl,
    int? pageCount,
    List<GalleryTag>? tags,
    double? rating,
    DateTime? postedAt,
  }) {
    return Gallery(
      key: key,
      title: title ?? this.title,
      uploader: uploader ?? this.uploader,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      pageCount: pageCount ?? this.pageCount,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      postedAt: postedAt ?? this.postedAt,
    );
  }
}
