import 'package:flutter/material.dart';

/// Design system typography tokens.
/// Source of truth: docs/architecture/DESIGN_SYSTEM.md §4
///
/// Font families:
///   Inter     — Latin script (en locale)
///   Vazirmatn — Persian/Arabic script (fa locale)
///
/// The active font family is resolved at runtime by [AppTheme] based on locale.
abstract final class AppTypography {
  static TextTheme buildTextTheme(String fontFamily) {
    return TextTheme(
      // display → not used in app; reserved
      displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 36, fontWeight: FontWeight.w400),

      // headline
      headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600),

      // title
      titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),

      // body
      bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),

      // label
      labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  /// Numeric display — always Inter, never substituted for locale.
  /// Used for: wallet balance, charging cost, large metrics.
  static const numericDisplay = TextStyle(
    fontFamily: 'Inter',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Numeric medium — always Inter.
  /// Used for: transaction amounts, small counters.
  static const numericMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Duration / HH:MM:SS — always Inter, always LTR.
  /// Must be wrapped in Directionality(ltr) at use site.
  static const duration = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Transaction / session IDs — monospace, always LTR, Latin.
  static const monospaceId = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
}
