import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';
import 'package:taro_eh_flutter/features/gallery/presentation/widgets/gallery_cover.dart';

void main() {
  testWidgets('gallery cover exposes semantic image label', (tester) async {
    const gallery = Gallery(
      key: GalleryKey(source: SiteSource.eHentai, gid: 1),
      title: 'Accessible Gallery',
      pageCount: 2,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 120,
          height: 160,
          child: GalleryCover(gallery: gallery),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(GalleryCover));
    expect(semantics.label, contains('Accessible Gallery'));
    expect(semantics.hasFlag(SemanticsFlag.isImage), isTrue);
  });
}
