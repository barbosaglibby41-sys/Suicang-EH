import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/app/app.dart';

void main() {
  testWidgets('switches tabs without replacing the navigation shell',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SuicangEhApp()));
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('书架').last);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('书架'), findsWidgets);

    await tester.tap(find.text('发现').last);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('SUICANG EH'), findsOneWidget);
  });
}
