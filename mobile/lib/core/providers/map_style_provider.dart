import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls the user's manual map-theme override.
///
/// [auto]  — follows the app's [ThemeMode] (and device brightness for system).
/// [light] — always renders light (CartoDB Voyager) tiles regardless of app theme.
/// [dark]  — always renders dark (CartoDB DarkMatter) tiles regardless of app theme.
enum MapThemeMode { auto, light, dark }

extension MapThemeModeX on MapThemeMode {
  String get labelFa => switch (this) {
        MapThemeMode.auto => 'خودکار',
        MapThemeMode.light => 'روشن',
        MapThemeMode.dark => 'تیره',
      };
}

const _kPrefKey = 'map_theme_mode';

final mapStyleProvider =
    StateNotifierProvider<MapStyleNotifier, MapThemeMode>(
  (ref) => MapStyleNotifier(),
);

class MapStyleNotifier extends StateNotifier<MapThemeMode> {
  MapStyleNotifier() : super(MapThemeMode.auto);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = _parse(prefs.getString(_kPrefKey) ?? prefs.getString('map_style'));
  }

  Future<void> setStyle(MapThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, mode.name);
  }

  static MapThemeMode _parse(String? s) => switch (s) {
        'light' => MapThemeMode.light,
        'dark' => MapThemeMode.dark,
        _ => MapThemeMode.auto, // covers 'auto', 'standard', 'highContrast', null
      };
}
