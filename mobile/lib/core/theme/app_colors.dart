import 'package:flutter/material.dart';

/// Design system color tokens.
/// Source of truth: docs/architecture/DESIGN_SYSTEM.md §3
abstract final class AppColors {
  // ── EVcharge brand gradient ───────────────────────────────────────────────

  /// Brand gradient start — vivid green
  static const brandGreen = Color(0xFF00E676);

  /// Brand gradient end — cyan
  static const brandCyan = Color(0xFF00BCD4);

  // ── Brand primaries ──────────────────────────────────────────────────────

  /// Brand Green — primary interactive color (replaces electric blue)
  static const primary = Color(0xFF00C853);
  static const onPrimary = Color(0xFF00210D);
  static const primaryContainer = Color(0xFFB9F6CA);
  static const onPrimaryContainer = Color(0xFF00210D);

  /// Cyan — secondary accent / info
  static const secondary = Color(0xFF00BCD4);
  static const onSecondary = Color(0xFF002B33);
  static const secondaryContainer = Color(0xFFB2EBF2);
  static const onSecondaryContainer = Color(0xFF002B33);

  /// Amber — tertiary / reservation / premium
  static const tertiary = Color(0xFFFFAB00);
  static const onTertiary = Color(0xFF332200);
  static const tertiaryContainer = Color(0xFFFFECB3);
  static const onTertiaryContainer = Color(0xFF332200);

  // ── Semantic ─────────────────────────────────────────────────────────────

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  static const warning = Color(0xFFE8A000);
  static const onWarning = Color(0xFFFFFFFF);
  static const warningContainer = Color(0xFFFFEDD0);
  static const onWarningContainer = Color(0xFF2B1700);

  // ── Station status (closed semantic set) ─────────────────────────────────

  static const statusAvailable = Color(0xFF00D68F);
  static const statusCharging = Color(0xFF0F5EFF);
  static const statusOccupied = Color(0xFFE8A000);
  static const statusReserved = Color(0xFF6B4EFF);
  static const statusUnavailable = Color(0xFF8E9AAF);
  static const statusFaulted = Color(0xFFBA1A1A);

  // ── Light surface palette ─────────────────────────────────────────────────

  static const surfaceLight = Color(0xFFFAFAFF);
  static const surfaceVariantLight = Color(0xFFE8EAF0);
  static const backgroundLight = Color(0xFFF5F6FA);
  static const outlineLight = Color(0xFF8E9AAF);

  static const textPrimaryLight = Color(0xFF0A0F1E);
  static const textSecondaryLight = Color(0xFF4A5568);
  static const textTertiaryLight = Color(0xFF8E9AAF);

  // ── Dark surface palette ──────────────────────────────────────────────────

  /// Deep navy — dark mode background (not pure black per design spec)
  static const backgroundDark = Color(0xFF0A0F1E);
  static const surfaceDark = Color(0xFF141929);
  static const surfaceVariantDark = Color(0xFF1E2438);
  static const outlineDark = Color(0xFF2D3452);

  static const textPrimaryDark = Color(0xFFEEF0F8);
  static const textSecondaryDark = Color(0xFF9BA8C0);
  static const textTertiaryDark = Color(0xFF5C6880);

  // ── Session screen (always dark regardless of system theme) ──────────────
  static const sessionBackground = Color(0xFF0A0F1E);
  static const sessionSurface = Color(0xFF141929);
  static const sessionRingIdle = Color(0xFF2D3452);
}
