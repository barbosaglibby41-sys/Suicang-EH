import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/gallery/presentation/widgets/gallery_card_meta.dart';

void main() {
  testWidgets('shows category pages and relative published time', (tester) async {
    final now = DateTime.now().toUtc();
    final gallery = Gallery(
      key: const GalleryKey(source: SiteSource.eHentai, gid: 1),
      title: 'Example',
      category: 'Manga',
      pageCount: 12,
      postedAt: now.subtract(const Duration(hours: 2, minutes: 4)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GalleryCardMeta(gallery: gallery)),
      ),
    );

    expect(find.textContaining('Manga · 12 页 ·'), findsOneWidget);
  });
}
