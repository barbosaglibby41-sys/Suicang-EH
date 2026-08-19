import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/app/layout/adaptive_layout.dart';

void main() {
  testWidgets('uses compact, medium and expanded adaptive columns', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox.expand(),
    ));
    expect(AdaptiveLayout.gridColumns(tester.element(find.byType(SizedBox))), 2);

    await tester.binding.setSurfaceSize(const Size(800, 1024));
    await tester.pump();
    expect(AdaptiveLayout.gridColumns(tester.element(find.byType(SizedBox))), 4);

    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester.pump();
    expect(AdaptiveLayout.gridColumns(tester.element(find.byType(SizedBox))), 5);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
