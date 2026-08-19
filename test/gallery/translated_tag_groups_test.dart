import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_tag.dart';
import 'package:suicang_eh/features/gallery/presentation/widgets/translated_tag_groups.dart';

void main() {
  testWidgets('shows translated name and raw fallback together', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TranslatedTagGroups(
              tags: [
                GalleryTag(namespace: 'female', key: 'footjob'),
                GalleryTag(namespace: 'other', key: 'unknown_custom_tag'),
              ],
              onSearch: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('女性'), findsOneWidget);
    expect(find.text('other:unknown_custom_tag'), findsOneWidget);
  });
}

void _noop(GalleryTag tag) {}
