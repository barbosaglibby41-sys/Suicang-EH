import '../../../tags/domain/entities/translated_tag.dart';

class SearchState {
  const SearchState({this.suggestions = const [], this.isReady = false});

  final List<TranslatedTag> suggestions;
  final bool isReady;
}
