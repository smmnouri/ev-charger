/// Design system elevation tokens (dp).
/// Source of truth: docs/architecture/DESIGN_SYSTEM.md §7
///
/// All shadows use a blue-tinted color (primary at low opacity) on dark
/// surfaces rather than pure black, per the design spec.
abstract final class AppElevation {
  static const double flat = 0;
  static const double card = 1.0;
  static const double raised = 2.0;
  static const double navBar = 4.0;
  static const double floatingSheet = 5.0; // bottom sheets, modals
  static const double modalSheet = 6.0; // dialogs, overlays
  static const double overlay = 8.0; // highest — full-screen overlays
}
