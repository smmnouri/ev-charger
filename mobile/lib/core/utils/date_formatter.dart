import 'package:shamsi_date/shamsi_date.dart';

/// Locale-aware date formatter.
/// Uses Jalali (Shamsi) calendar + Persian numerals when languageCode == 'fa'.
abstract final class AppDateFormatter {
  static const _jalaliMonths = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر',
    'مرداد', 'شهریور', 'مهر', 'آبان',
    'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  static const _gregorianMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _persianDigits(String s) {
    const d = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return s.replaceAllMapped(
      RegExp(r'[0-9]'),
      (m) => d[int.parse(m.group(0)!)],
    );
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');

  static Jalali _toJalali(DateTime dt) =>
      Gregorian(dt.year, dt.month, dt.day).toJalali();

  /// "24 خرداد ۱۴۰۵"  /  "Jun 24, 2026"
  static String date(DateTime dt, String languageCode) {
    if (languageCode == 'fa') {
      final j = _toJalali(dt);
      return _persianDigits('${j.day} ${_jalaliMonths[j.month - 1]} ${j.year}');
    }
    return '${_gregorianMonths[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  /// "24 خرداد"  /  "Jun 24"
  static String shortDate(DateTime dt, String languageCode) {
    if (languageCode == 'fa') {
      final j = _toJalali(dt);
      return _persianDigits('${j.day} ${_jalaliMonths[j.month - 1]}');
    }
    return '${_gregorianMonths[dt.month - 1]} ${dt.day}';
  }

  /// "۱۸:۳۰"  /  "18:30"
  static String time(DateTime dt, String languageCode) {
    final t = '${_pad2(dt.hour)}:${_pad2(dt.minute)}';
    return languageCode == 'fa' ? _persianDigits(t) : t;
  }

  /// "24 خرداد  ۱۸:۳۰"  /  "Jun 24, 18:30"
  static String dateTime(DateTime dt, String languageCode) {
    if (languageCode == 'fa') {
      final j = _toJalali(dt);
      final t = _persianDigits('${_pad2(dt.hour)}:${_pad2(dt.minute)}');
      return '${_persianDigits(j.day.toString())} ${_jalaliMonths[j.month - 1]}  $t';
    }
    return '${_gregorianMonths[dt.month - 1]} ${dt.day}, ${_pad2(dt.hour)}:${_pad2(dt.minute)}';
  }

  /// Full: "24 خرداد ۱۴۰۵ · ۱۸:۳۰"  /  "Jun 24, 2026 · 18:30"
  static String fullDateTime(DateTime dt, String languageCode) {
    if (languageCode == 'fa') {
      final j = _toJalali(dt);
      final t = _persianDigits('${_pad2(dt.hour)}:${_pad2(dt.minute)}');
      return '${_persianDigits(j.day.toString())} ${_jalaliMonths[j.month - 1]} ${_persianDigits(j.year.toString())} · $t';
    }
    return '${_gregorianMonths[dt.month - 1]} ${dt.day}, ${dt.year} · ${_pad2(dt.hour)}:${_pad2(dt.minute)}';
  }
}
