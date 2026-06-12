import 'package:intl/intl.dart';

/// Formats monetary amounts for display.
/// Source of truth: ARCHITECTURE_FINAL.md §13, WALLET_SCREENS.md §1
///
/// Internal storage: Rials (integer).
/// Display: Tomans = Rials ÷ 10.
/// Persian locale: substitutes Eastern Arabic-Indic digits (۰–۹).
abstract final class CurrencyFormatter {
  static final _enFormat = NumberFormat('#,##0', 'en_US');
  static final _faFormat = NumberFormat('#,##0', 'fa_IR');

  /// Format Rial amount as Toman for display.
  /// [amountRials] is the internal Rial value.
  /// [locale] is the current app locale ('en' or 'fa').
  static String formatToman(int amountRials, {String locale = 'en'}) {
    final tomans = amountRials ~/ 10;
    final formatted = locale == 'fa'
        ? _faFormat.format(tomans)
        : _enFormat.format(tomans);
    return formatted;
  }

  /// Returns the integer (whole Toman) and fractional (sub-Toman) parts.
  static ({String integer, String fraction}) splitToman(
    int amountRials, {
    String locale = 'en',
  }) {
    final tomans = amountRials / 10;
    final intPart = tomans.truncate();
    final fracPart = ((tomans - intPart) * 10).truncate(); // tenths of a toman

    final intStr = locale == 'fa'
        ? _faFormat.format(intPart)
        : _enFormat.format(intPart);
    final fracStr = locale == 'fa'
        ? _toEasternArabic(fracPart.toString())
        : fracPart.toString();

    return (integer: intStr, fraction: fracStr);
  }

  /// Substitutes Western digits with Eastern Arabic-Indic (Persian) digits.
  static String _toEasternArabic(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var result = input;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }

  /// Format energy in kWh.
  static String formatKwh(double kwh, {String locale = 'en'}) {
    final formatted = kwh.toStringAsFixed(2);
    return locale == 'fa' ? _toEasternArabic(formatted) : formatted;
  }

  /// Format distance in km (rounded to 1 decimal).
  static String formatKm(double km, {String locale = 'en'}) {
    final formatted = km.toStringAsFixed(1);
    return locale == 'fa' ? _toEasternArabic(formatted) : formatted;
  }
}
