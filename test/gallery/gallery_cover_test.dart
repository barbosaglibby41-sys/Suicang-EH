import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';
import 'package:taro_eh_flutter/features/gallery/presentation/widgets/gallery_cover.dart';
import 'package:taro_eh_flutter/features/gallery/presentation/widgets/gallery_cover_placeholder.dart';

void main() {
  testWidgets('uses stable placeholder for galleries without thumbnails', (tester) async {
    const gallery = Gallery(
      key: GalleryKey(source: SiteSource.eHentai, gid: 1),
      title: 'No cover',
      pageCount: 1,
    );
    await tester.pumpWidget(
      const MaterialApp(home: SizedBox(width: 100, height: 140, child: GalleryCover(gallery: gallery))),
    );

    expect(find.byType(GalleryCoverPlaceholder), findsOneWidget);
  });
}
