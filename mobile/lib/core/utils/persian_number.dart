/// Persian (Farsi) digit formatting utilities.
///
/// Converts Western Arabic numerals (0-9) to Eastern Arabic/Persian digits
/// (۰-۹) as required by the Persian-first UI standard.
const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
final _digitRe = RegExp(r'\d');

/// Converts all ASCII digits in [input] to Persian equivalents.
/// Non-digit characters (commas, periods, minus signs, letters) pass through.
String toPersian(String input) =>
    input.replaceAllMapped(_digitRe, (m) => _persianDigits[int.parse(m[0]!)]);

/// Formats [toman] as a Persian thousands-separated string.
/// E.g. 1273000 → "۱،۲۷۳،۰۰۰"
String formatToman(int toman) {
  final negative = toman < 0;
  final digits = toman.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('،');
    buf.write(_persianDigits[int.parse(digits[i])]);
  }
  return negative ? '-${buf.toString()}' : buf.toString();
}

/// Formats [value] as Persian with [decimals] decimal places.
/// E.g. formatPersianDecimal(24.6, 1) → "۲۴٫۶"
String formatPersianDecimal(double value, [int decimals = 1]) =>
    toPersian(value.toStringAsFixed(decimals).replaceAll('.', '٫'));

/// Formats [percent] as "۷۸٪" style.
String formatPersianPercent(int percent) => '${toPersian(percent.toString())}٪';

/// Formats a duration as "۱:۲۳" style (h:mm or m:ss).
String formatPersianDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) {
    return toPersian('$h:${m.toString().padLeft(2, '0')}');
  }
  return toPersian('$m:${s.toString().padLeft(2, '0')}');
}

/// Converts a simple integer to a Persian digit string.
String persianInt(int n) => toPersian(n.toString());
