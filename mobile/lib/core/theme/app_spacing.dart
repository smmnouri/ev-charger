/// Design system spacing tokens — 8dp grid.
/// Source of truth: docs/architecture/DESIGN_SYSTEM.md §5
abstract final class AppSpacing {
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s7 = 32.0;
  static const double s8 = 40.0;
  static const double s9 = 48.0;
  static const double s10 = 64.0;

  // Semantic aliases
  static const double screenHorizontal = s4; // 16dp outer margin
  static const double cardPadding = s4; // 16dp standard card padding
  static const double cardPaddingLarge = s6; // 24dp hero card padding
  static const double sectionGap = s7; // 32dp between sections
  static const double buttonHeight = s9; // 48dp standard button
  static const double buttonHeightLarge = 56.0; // 56dp large button
  static const double rowHeight = 52.0; // settings row height
  static const double cardHeight = 72.0; // standard list card
  static const double ctaBarHeight = 80.0; // sticky CTA bar incl safe area
  static const double navBarHeight = 56.0; // top navigation bar
  static const double tabBarHeight = 56.0; // bottom tab bar
  static const double touchTarget = 44.0; // minimum touch target
  static const double iconSize = 24.0; // standard icon
  static const double iconSizeSmall = 20.0; // small icon
  static const double iconSizeLarge = 32.0; // large icon (KYC, empty states)
  static const double avatarSize = 72.0; // profile avatar
  static const double avatarSizeLarge = 96.0; // edit profile avatar
  static const double sessionRingSize = 220.0; // charging session ring
  static const double sessionRingStroke = 12.0; // ring stroke width
  static const double summaryMedallionSize = 80.0; // post-session medallion
}
