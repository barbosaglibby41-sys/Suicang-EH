import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/app/app.dart';

void main() {
  testWidgets('renders the Flutter migration shell', (tester) async {
    await tester.pumpWidget(const TaroEhApp());
    await tester.pumpAndSettle();

    expect(find.text('发现'), findsOneWidget);
    expect(find.text('TAROEH'), findsOneWidget);
  });
}
