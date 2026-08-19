import '../../../gallery/domain/entities/gallery.dart';
import '../entities/followed_creator.dart';

abstract interface class FollowedCreatorRepository {
  Stream<List<FollowedCreator>> watchAll();
  Future<void> follow(FollowedCreator creator);
  Future<void> unfollow(String id);
  Future<bool> isFollowing(String id);
  Future<List<Gallery>> refresh(FollowedCreator creator);
}
