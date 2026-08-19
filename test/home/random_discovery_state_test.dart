import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/home/presentation/state/discovery_state.dart';

void main() {
  test('random state permits paging until an empty batch exhausts it', () {
    const initial = DiscoveryState(
      source: SiteSource.eHentai,
      galleries: [Gallery(key: GalleryKey(source: SiteSource.eHentai, gid: 1), title: 'A', pageCount: 1)],
      isRandom: true,
      randomRound: 1,
    );
    final exhausted = initial.copyWith(randomExhausted: true);

    expect(initial.hasMore, isTrue);
    expect(exhausted.hasMore, isFalse);
  });
}
