import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MapStyle { standard, dark, highContrast }

extension MapStyleX on MapStyle {
  String get labelFa => switch (this) {
        MapStyle.standard => 'استاندارد',
        MapStyle.dark => 'تیره',
        MapStyle.highContrast => 'کنتراست بالا',
      };

  ColorFilter get tileFilter => switch (this) {
        MapStyle.dark => const ColorFilter.matrix(<double>[
            1.20, 0, 0, 0, 8,
            0, 1.20, 0, 0, 8,
            0, 0, 1.20, 0, 8,
            0, 0, 0, 1, 0,
          ]),
        MapStyle.highContrast => const ColorFilter.matrix(<double>[
            1.70, 0, 0, 0, 30,
            0, 1.70, 0, 0, 30,
            0, 0, 1.70, 0, 30,
            0, 0, 0, 1, 0,
          ]),
        MapStyle.standard => const ColorFilter.matrix(<double>[
            1.45, 0, 0, 0, 20,
            0, 1.45, 0, 0, 20,
            0, 0, 1.45, 0, 20,
            0, 0, 0, 1, 0,
          ]),
      };
}

final mapStyleProvider = StateNotifierProvider<MapStyleNotifier, MapStyle>(
  (ref) => MapStyleNotifier(),
);

class MapStyleNotifier extends StateNotifier<MapStyle> {
  MapStyleNotifier() : super(MapStyle.standard);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = _parse(prefs.getString('map_style') ?? 'standard');
  }

  Future<void> setStyle(MapStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('map_style', style.name);
  }

  static MapStyle _parse(String s) => switch (s) {
        'dark' => MapStyle.dark,
        'highContrast' => MapStyle.highContrast,
        _ => MapStyle.standard,
      };
}
