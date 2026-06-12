import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

const _kLocaleKey = 'locale_preference';
const _kDefaultLocale = 'en';

/// Supported locales for the application.
/// Source of truth: ARCHITECTURE_FINAL.md §25
const appSupportedLocales = [
  Locale('en'),
  Locale('fa'),
];

/// App-lifetime locale notifier.
/// Priority order (per ARCHITECTURE_FINAL.md §25):
///   1. User's stored preference (SharedPreferences)
///   2. Device locale if supported
///   3. English fallback
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() => const Locale(_kDefaultLocale);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLocaleKey);
    if (stored != null && _isSupported(stored)) {
      state = Locale(stored);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  bool _isSupported(String code) =>
      appSupportedLocales.any((l) => l.languageCode == code);

  /// The font family appropriate for the current locale.
  String get fontFamily => state.languageCode == 'fa' ? 'Vazirmatn' : 'Inter';

  /// Text direction for the current locale.
  TextDirection get textDirection =>
      state.languageCode == 'fa' ? TextDirection.rtl : TextDirection.ltr;
}
