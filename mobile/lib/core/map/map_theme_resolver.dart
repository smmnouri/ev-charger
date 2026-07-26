import 'package:flutter/material.dart';

import '../providers/map_style_provider.dart';
import 'tile_provider_config.dart';

/// The resolved output for a given combination of map-theme mode, app theme,
/// and platform brightness.
class MapThemeConfig {
  const MapThemeConfig({
    required this.tileConfig,
    required this.colorFilter,
    required this.overlayColor,
    required this.overlayOpacity,
  });

  /// Tile source and URL templates for this theme.
  final TileProviderConfig tileConfig;

  /// ColorFilter applied over the TileLayer (brightness / contrast boost).
  final ColorFilter colorFilter;

  /// Base color used for the top/bottom gradient scrims.
  final Color overlayColor;

  /// Max alpha applied to [overlayColor] in the gradient scrims.
  final double overlayOpacity;
}

/// Resolves the effective map appearance from three inputs:
///
///  - [MapThemeMode] — the user's manual map override (auto / light / dark)
///  - [ThemeMode]    — the app's selected theme (light / dark / system)
///  - [Brightness]   — the device's current platform brightness (for system mode)
///
/// Output: [MapThemeConfig] carrying tile source, color filter, and overlay
/// parameters.  The widget layer is responsible for triggering tile-provider
/// reinitialization when [effectiveBrightness] changes.
abstract final class MapThemeResolver {
  // ── Dark config ──────────────────────────────────────────────────────────

  /// Readability boost for CartoDB DarkMatter tiles.
  /// Scale 1.40 + offset 18 lifts mid-tone roads to clearly readable contrast
  /// while keeping the deep background intact.
  static const _darkFilter = ColorFilter.matrix(<double>[
    1.40, 0,    0,    0,  18,
    0,    1.40, 0,    0,  18,
    0,    0,    1.40, 0,  18,
    0,    0,    0,    1,   0,
  ]);

  static const _dark = MapThemeConfig(
    tileConfig: IranResidentDarkTileConfig(),
    colorFilter: _darkFilter,
    overlayColor: Color(0xFF0A0F1E), // AppColors.backgroundDark
    overlayOpacity: 0.10,
  );

  // ── Light config ─────────────────────────────────────────────────────────

  /// Identity filter — CartoDB Voyager tiles are already well-balanced.
  static const _identityFilter = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const _light = MapThemeConfig(
    tileConfig: IranResidentLightTileConfig(),
    colorFilter: _identityFilter,
    overlayColor: Color(0xFFFFFFFF), // white scrim for light UI
    overlayOpacity: 0.06,
  );

  // ── Public API ───────────────────────────────────────────────────────────

  /// Returns true when the given combination of settings should render a dark map.
  static bool isDark({
    required MapThemeMode mapThemeMode,
    required ThemeMode appThemeMode,
    required Brightness platformBrightness,
  }) =>
      switch (mapThemeMode) {
        MapThemeMode.dark => true,
        MapThemeMode.light => false,
        MapThemeMode.auto => switch (appThemeMode) {
            ThemeMode.dark => true,
            ThemeMode.light => false,
            ThemeMode.system => platformBrightness == Brightness.dark,
          },
      };

  /// Returns the [MapThemeConfig] for the given inputs.
  static MapThemeConfig resolve({
    required MapThemeMode mapThemeMode,
    required ThemeMode appThemeMode,
    required Brightness platformBrightness,
  }) =>
      isDark(
        mapThemeMode: mapThemeMode,
        appThemeMode: appThemeMode,
        platformBrightness: platformBrightness,
      )
          ? _dark
          : _light;
}
