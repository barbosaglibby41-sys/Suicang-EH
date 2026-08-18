import '../../../gallery/domain/entities/gallery.dart';
import 'cloud_favorite_category.dart';

class CloudFavoritesPage {
  const CloudFavoritesPage({
    required this.categories,
    required this.galleries,
    this.nextUrl,
  });

  final List<CloudFavoriteCategory> categories;
  final List<Gallery> galleries;
  final Uri? nextUrl;
}
