abstract interface class SubscribedTagsRepository {
  Stream<List<String>> watchAll();
  Future<bool> contains(String rawName);
  Future<void> toggle(String rawName);
  Future<void> clear();
}
