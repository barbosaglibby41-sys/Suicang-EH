import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../entities/cloud_favorite_category.dart';
import '../entities/cloud_favorites_page.dart';

abstract interface class CloudFavoritesRepository {
  Future<CloudFavoritesPage> load({
    required SiteSource source,
    required int category,
    Uri? pageUrl,
  });
  Future<void> setFavorite({
    required Gallery gallery,
    required int category,
    required bool value,
  });
  List<CloudFavoriteCategory> defaultCategories();
}
