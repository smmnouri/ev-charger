import 'package:flutter/material.dart';

/// Design system border radius tokens.
/// Source of truth: docs/architecture/DESIGN_SYSTEM.md §6
abstract final class AppRadius {
  static const double none = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 9999.0;

  static const BorderRadius rNone = BorderRadius.zero;
  static const BorderRadius rXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rFull = BorderRadius.all(Radius.circular(full));

  /// Bottom sheet: rounded top corners only
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Collapsing nav bar hero image: top-only
  static const BorderRadius topImage = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
}
