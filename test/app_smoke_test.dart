import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/app/app.dart';

void main() {
  testWidgets('renders the Flutter migration shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaroEhApp()));
    await tester.pumpAndSettle();

    expect(find.text('发现').first, findsOneWidget);
    expect(find.text('TAROEH'), findsOneWidget);
  });
}
