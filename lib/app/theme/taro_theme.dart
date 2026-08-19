import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class SuicangColors {
  static const canvas = Color(0xFF090A0D);
  static const surface = Color(0xFF121319);
  static const elevated = Color(0xFF1A1B22);
  static const ink = Color(0xFFF5F5F7);
  static const secondary = Color(0xFFA1A1A6);
  static const muted = Color(0xFF686970);
  static const border = Color(0x1FFFFFFF);
}

abstract final class TaroMotion {
  static const quick = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
}

abstract final class TaroTheme {
  static ThemeData light() => _light();
  static ThemeData dark() => _dark();

  static ThemeData _dark() {
    const scheme = ColorScheme.dark(
      primary: SuicangColors.ink,
      onPrimary: Colors.black,
      secondary: SuicangColors.secondary,
      surface: SuicangColors.surface,
      onSurface: SuicangColors.ink,
      outlineVariant: SuicangColors.border,
    );
    return _base(scheme, canvas: SuicangColors.canvas, dark: true);
  }

  static ThemeData _light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5B9D),
      brightness: Brightness.light,
    );
    return _base(scheme, canvas: const Color(0xFFF8F7FB), dark: false);
  }

  static ThemeData _base(
    ColorScheme scheme, {
    required Color canvas,
    required bool dark,
  }) {
    final text = Typography.material2021().black.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark ? SuicangColors.surface : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? SuicangColors.surface : Colors.white,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dark ? SuicangColors.ink : scheme.primary,
          foregroundColor: dark ? Colors.black : scheme.onPrimary,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: scheme.outlineVariant),
          shape: const StadiumBorder(),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: dark ? const Color(0xEE101117) : Colors.white,
        indicatorColor: dark ? SuicangColors.elevated : scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: scheme.onSurface, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
