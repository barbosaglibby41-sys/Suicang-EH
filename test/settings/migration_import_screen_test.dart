import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/settings/presentation/migration_import_screen.dart';

void main() {
  testWidgets('communicates non-sensitive migration boundaries',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MigrationImportScreen()),
      ),
    );

    expect(find.text('可导入内容'), findsOneWidget);
    expect(find.text('不会导入'), findsOneWidget);
    expect(find.textContaining('Cookie、Keychain'), findsOneWidget);
  });
}
