// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'شارژ خودرو برقی';

  @override
  String get tabMap => 'نقشه';

  @override
  String get tabReservations => 'رزروها';

  @override
  String get tabCharging => 'شارژ';

  @override
  String get tabWallet => 'کیف‌پول';

  @override
  String get tabProfile => 'پروفایل';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsAppearance => 'ظاهر';

  @override
  String get settingsNotifications => 'تنظیمات اعلان‌ها';

  @override
  String get settingsLocation => 'موقعیت مکانی';

  @override
  String get settingsAnalytics => 'آمار و تحلیل';

  @override
  String get settingsExportData => 'خروجی داده‌ها';

  @override
  String get settingsDeleteAccount => 'حذف حساب';

  @override
  String get settingsTerms => 'شرایط استفاده';

  @override
  String get settingsPrivacy => 'حریم خصوصی';

  @override
  String get settingsHelp => 'راهنما و پشتیبانی';

  @override
  String get settingsRateApp => 'امتیاز به برنامه';

  @override
  String get themeSystem => 'خودکار سیستم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get walletTitle => 'کیف‌پول';

  @override
  String get walletBalance => 'موجودی';

  @override
  String get walletAddFunds => 'افزودن موجودی';

  @override
  String get walletTransactionHistory => 'تاریخچه تراکنش‌ها';

  @override
  String get walletNoTransactions => 'هیچ تراکنشی وجود ندارد';

  @override
  String get walletAddFundsToStart =>
      'برای شروع شارژ، موجودی کیف‌پول خود را افزایش دهید.';

  @override
  String get walletLowBalance => 'موجودی کم — قبل از شارژ بعدی شارژ کنید';

  @override
  String walletOfflineBalance(String time) {
    return 'موجودی تا $time';
  }

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get profileEditProfile => 'ویرایش پروفایل';

  @override
  String get profileAccountSecurity => 'امنیت حساب';

  @override
  String get profileSignOut => 'خروج';

  @override
  String get profileSignOutConfirm => 'خروج از حساب؟';

  @override
  String get profileSignOutBody =>
      'برای دسترسی به کیف‌پول و سابقه شارژ، دوباره وارد شوید.';

  @override
  String get profileKycVerified => 'هویت تأیید شد';

  @override
  String get profileKycPending => 'در حال بررسی';

  @override
  String get profileKycNotStarted => 'تأیید هویت';

  @override
  String get profileKycRejected => 'تأیید هویت ناموفق بود';

  @override
  String get profileKycRequired => 'برای رزرو و شروع شارژ الزامی است.';

  @override
  String get profileKycVerifyNow => 'تأیید هویت';

  @override
  String get profileKycTryAgain => 'تلاش مجدد';

  @override
  String get profileKycUsually => 'معمولاً ۲ تا ۵ دقیقه';

  @override
  String get notificationsTitle => 'اعلان‌ها';

  @override
  String get notificationsMarkAllRead => 'علامت‌گذاری همه';

  @override
  String get notificationsEmpty => 'هنوز اعلانی وجود ندارد';

  @override
  String get notificationsEmptyBody =>
      'به‌روزرسانی‌های شارژ و رزرو اینجا نمایش داده می‌شوند.';

  @override
  String get notificationsAllCaughtUp => 'همه چیز خوانده شد';

  @override
  String get notificationsDateToday => 'امروز';

  @override
  String get notificationsDateYesterday => 'دیروز';

  @override
  String get reservationsTitle => 'رزروها';

  @override
  String get reservationNoReservations => 'رزروی وجود ندارد';

  @override
  String get reservationFindStation => 'یافتن ایستگاه';

  @override
  String get reservationConfirmed => 'تأیید شد';

  @override
  String get reservationPending => 'در انتظار';

  @override
  String get reservationActive => 'فعال';

  @override
  String get reservationCompleted => 'تکمیل شد';

  @override
  String get reservationCancelled => 'لغو شد';

  @override
  String get reservationExpired => 'منقضی شد';

  @override
  String get reservationNoShow => 'عدم حضور';

  @override
  String get reservationCancel => 'لغو رزرو';

  @override
  String get reservationStartCharging => 'شروع شارژ';

  @override
  String get reservationCheckIn => 'ورود';

  @override
  String get stationAvailable => 'آزاد';

  @override
  String get stationCharging => 'در حال شارژ';

  @override
  String get stationOccupied => 'اشغال';

  @override
  String get stationReserved => 'رزرو شده';

  @override
  String get stationUnavailable => 'غیرفعال';

  @override
  String get stationFaulted => 'خرابی';

  @override
  String get chargingTitle => 'شارژ';

  @override
  String get chargingPreparing => 'در حال آماده‌سازی';

  @override
  String get chargingAuthorizing => 'در حال احراز هویت';

  @override
  String get chargingActive => 'در حال شارژ';

  @override
  String get chargingSuspendedVehicle => 'متوقف توسط خودرو';

  @override
  String get chargingSuspendedCharger => 'متوقف توسط شارژر';

  @override
  String get chargingInterrupted => 'قطع شد';

  @override
  String get chargingFinishing => 'در حال اتمام';

  @override
  String get chargingFaulted => 'خرابی شارژر';

  @override
  String get chargingStop => 'توقف شارژ';

  @override
  String get chargingStopConfirm => 'توقف این جلسه؟';

  @override
  String get chargingStopBody =>
      'جلسه شارژ پایان می‌یابد و مبلغ نهایی محاسبه می‌شود.';

  @override
  String get chargingStopConfirmCta => 'توقف جلسه';

  @override
  String get summaryTitle => 'خلاصه شارژ';

  @override
  String get summaryDone => 'تمام';

  @override
  String get summaryAddFunds => 'افزودن موجودی';

  @override
  String get summaryViewReceipt => 'مشاهده رسید';

  @override
  String get errorGeneric => 'مشکلی پیش آمد';

  @override
  String get errorNetwork => 'اتصال به اینترنت وجود ندارد';

  @override
  String get errorRetry => 'تلاش مجدد';

  @override
  String get errorOffline => 'آفلاین — داده‌های ذخیره شده نمایش داده می‌شوند';

  @override
  String get welcomeTitle => 'به شارژ خودرو برقی خوش آمدید';

  @override
  String get welcomeBody =>
      'ایستگاه‌های شارژ را پیدا کنید، رزرو کنید و جلسات شارژ خود را مدیریت کنید — همه در یک جا.';

  @override
  String get welcomeGetStarted => 'شروع کنید';

  @override
  String get loading => 'در حال بارگذاری…';

  @override
  String get cancel => 'لغو';

  @override
  String get confirm => 'تأیید';

  @override
  String get save => 'ذخیره';

  @override
  String get close => 'بستن';

  @override
  String get back => 'بازگشت';

  @override
  String get continue_ => 'ادامه';

  @override
  String get done => 'تمام';

  @override
  String get or => 'یا';

  @override
  String get kwhUnit => 'کیلووات‌ساعت';

  @override
  String get kmUnit => 'کیلومتر';

  @override
  String get minuteUnit => 'دقیقه';

  @override
  String get tomansUnit => 'تومان';

  @override
  String get currencySymbol => '﷼';
}
