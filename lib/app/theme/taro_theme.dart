import 'package:flutter/material.dart';

abstract final class TaroColors {
  static const accent = Color(0xFF7157C8);
  static const lightCanvas = Color(0xFFF8F7FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightInk = Color(0xFF1C1A22);
  static const darkCanvas = Color(0xFF111015);
  static const darkSurface = Color(0xFF1B1921);
  static const darkInk = Color(0xFFF2EFF7);
}

abstract final class TaroMotion {
  static const quick = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
}

abstract final class TaroTheme {
  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: TaroColors.accent,
      brightness: brightness,
      surface: isDark ? TaroColors.darkSurface : TaroColors.lightSurface,
    );
    final textTheme = Typography.material2021().black.apply(
          bodyColor: isDark ? TaroColors.darkInk : TaroColors.lightInk,
          displayColor: isDark ? TaroColors.darkInk : TaroColors.lightInk,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? TaroColors.darkCanvas : TaroColors.lightCanvas,
      textTheme: textTheme.copyWith(
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? TaroColors.darkInk : TaroColors.lightInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: isDark ? TaroColors.darkSurface : TaroColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: isDark ? TaroColors.darkSurface : TaroColors.lightSurface,
        indicatorColor: colorScheme.secondaryContainer,
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
