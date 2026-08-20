import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/gallery/presentation/widgets/gallery_card_meta.dart';

void main() {
  testWidgets('shows full China absolute published time on card', (tester) async {
    final gallery = Gallery(
      key: const GalleryKey(source: SiteSource.eHentai, gid: 1),
      title: 'Example',
      category: 'Manga',
      pageCount: 12,
      postedAt: DateTime.utc(2026, 8, 19, 13, 5, 42),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GalleryCardMeta(gallery: gallery)),
      ),
    );

    expect(find.text('Manga · 12 页'), findsOneWidget);
    expect(find.text('2026-08-19 21:05:42'), findsOneWidget);
  });
}
