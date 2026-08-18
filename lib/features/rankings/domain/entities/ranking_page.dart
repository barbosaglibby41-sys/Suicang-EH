import '../../../gallery/domain/entities/gallery.dart';

class RankingPage {
  const RankingPage({
    required this.galleries,
    this.nextPage,
  });

  final List<Gallery> galleries;
  final int? nextPage;
}
