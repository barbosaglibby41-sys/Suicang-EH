class GalleryComment {
  const GalleryComment({
    required this.id,
    required this.author,
    required this.postedAt,
    required this.content,
    this.score,
    this.isUploader = false,
    this.votes,
  });

  final int id;
  final String author;
  final String postedAt;
  final String content;
  final int? score;
  final bool isUploader;
  final String? votes;
}
