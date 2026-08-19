import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/image/media_kind.dart';

void main() {
  test('classifies animated images and videos without network assumptions', () {
    expect(MediaKindResolver.fromUri(Uri.parse('https://x/a.gif')), MediaKind.animatedImage);
    expect(MediaKindResolver.fromUri(Uri.parse('https://x/a.webp')), MediaKind.animatedImage);
    expect(MediaKindResolver.fromUri(Uri.parse('https://x/a.mp4')), MediaKind.video);
    expect(MediaKindResolver.fromUri(Uri.parse('https://x/a.jpg')), MediaKind.image);
  });
}
