class TranslatedTag {
  const TranslatedTag({
    required this.namespace,
    required this.key,
    required this.name,
    this.intro,
  });

  final String namespace;
  final String key;
  final String name;
  final String? intro;

  String get id => '$namespace:$key';
  String get rawName => id;
}
