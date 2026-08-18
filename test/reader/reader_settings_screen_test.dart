import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/reader/domain/entities/reader_preferences.dart';
import 'package:taro_eh_flutter/features/reader/presentation/providers/reader_preferences_providers.dart';
import 'package:taro_eh_flutter/features/reader/presentation/reader_settings_screen.dart';

void main() {
  testWidgets('renders reader preference controls', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerPreferencesProvider.overrideWith(() => _PreferencesNotifier()),
        ],
        child: const MaterialApp(home: ReaderSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('横向分页'), findsOneWidget);
    expect(find.text('从右到左'), findsOneWidget);
    expect(find.text('阅读时保持屏幕常亮'), findsOneWidget);
  });
}

class _PreferencesNotifier extends ReaderPreferencesNotifier {
  @override
  Future<ReaderPreferences> build() async => const ReaderPreferences();
}
