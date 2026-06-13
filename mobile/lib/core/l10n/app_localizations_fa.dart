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
  String get tabMap => 'خانه';

  @override
  String get tabReservations => 'رزروها';

  @override
  String get tabScan => 'اسکن';

  @override
  String get tabHistory => 'تاریخچه';

  @override
  String get tabCharging => 'شارژ';

  @override
  String get tabWallet => 'کیف‌پول';

  @override
  String get tabProfile => 'پروفایل';

  @override
  String get homeSearchHint => 'جستجوی ایستگاه‌های شارژ…';

  @override
  String get homeNearby => 'ایستگاه‌های نزدیک';

  @override
  String get homeReserve => 'رزرو';

  @override
  String get homeFilter => 'فیلتر';

  @override
  String get homeViewStation => 'مشاهده ایستگاه';

  @override
  String get homeNavigate => 'مسیریابی';

  @override
  String get homeConnectors => 'پریزها';

  @override
  String get homeAmenities => 'امکانات';

  @override
  String get homeHours => 'ساعت کار';

  @override
  String get homeAllBusy => 'همه پریزها اشغال‌اند';

  @override
  String get homeFilterType2 => 'Type 2';

  @override
  String get homeFilterCCS => 'CCS';

  @override
  String get homeFilterCHAdeMO => 'CHAdeMO';

  @override
  String get homeFilterGBT => 'GB/T';

  @override
  String get homeFilterAvailable => 'آزاد';

  @override
  String get homeFilterDC => 'DC سریع';

  @override
  String get homeFilterAC => 'AC';

  @override
  String get homeSearchRecent => 'اخیر';

  @override
  String get homeSearchNearby => 'ایستگاه‌های نزدیک';

  @override
  String get homeNoStationsFilter => 'ایستگاهی با این فیلتر یافت نشد';

  @override
  String get homeAmenityParking => 'پارکینگ';

  @override
  String get homeAmenityCoffee => 'کافه';

  @override
  String get homeAmenityRestroom => 'سرویس';

  @override
  String get homeAmenityWifi => 'Wi-Fi';

  @override
  String get homeHours24 => '۲۴ ساعته';

  @override
  String get homeClearFilters => 'پاک کردن';

  @override
  String homeActiveFiltersCount(int count) {
    return '$count فعال';
  }

  @override
  String get homeFilterNearby => 'نزدیک';

  @override
  String get homeNoStationsArea => 'ایستگاهی در این منطقه یافت نشد';

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
  String get settingsAccount => 'حساب کاربری';

  @override
  String get settingsPreferences => 'تنظیمات برگزیده';

  @override
  String get settingsSupportSection => 'پشتیبانی';

  @override
  String get settingsFaq => 'سوالات متداول';

  @override
  String get settingsContactSupport => 'تماس با پشتیبانی';

  @override
  String get settingsAboutApp => 'درباره برنامه';

  @override
  String get settingsAppVersion => 'نسخه برنامه';

  @override
  String get settingsPersonalInfo => 'اطلاعات شخصی';

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
  String get profilePhoneLabel => 'شماره تلفن';

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
  String get notifReservation => 'اعلان‌های رزرو';

  @override
  String get notifCharging => 'اعلان‌های شارژ';

  @override
  String get notifPayment => 'اعلان‌های پرداخت';

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
  String get reservationNewTitle => 'رزرو جدید';

  @override
  String get reservationSelectConnector => 'انتخاب پریز';

  @override
  String get reservationTimeAndDuration => 'زمان و مدت';

  @override
  String get reservationSummaryStep => 'خلاصه';

  @override
  String get reservationStartTime => 'زمان شروع';

  @override
  String get reservationDuration => 'مدت زمان';

  @override
  String get reservationEstCost => 'هزینه تخمینی';

  @override
  String reservationEstKwh(String kwh) {
    return 'تقریباً $kwh کیلووات‌ساعت';
  }

  @override
  String get reservationConfirmCta => 'تأیید رزرو';

  @override
  String get reservationSuccessTitle => 'رزرو تأیید شد!';

  @override
  String get reservationSuccessSubtitle => 'رزرو شما با موفقیت ثبت شد';

  @override
  String get reservationIdLabel => 'شناسه رزرو';

  @override
  String get reservationCountdown => 'زمان تا شروع';

  @override
  String get reservationStartsNow => 'شروع شده';

  @override
  String get reservationViewDetails => 'مشاهده جزئیات';

  @override
  String get reservationNavigateStation => 'مسیریابی به ایستگاه';

  @override
  String get reservationCancelTitle => 'لغو رزرو';

  @override
  String get reservationCancelBody =>
      'رزرو شما لغو خواهد شد و پریز رزرو شده آزاد می‌شود.';

  @override
  String get reservationCancelConfirmBtn => 'بله، لغو کن';

  @override
  String get reservationUpcomingTab => 'پیش‌رو';

  @override
  String get reservationActiveTab => 'فعال';

  @override
  String get reservationCompletedTab => 'تکمیل‌شده';

  @override
  String get reservationCancelledTab => 'لغوشده';

  @override
  String get reservationStationLabel => 'ایستگاه';

  @override
  String get reservationConnectorLabel => 'پریز';

  @override
  String get reservationAvailableConnectors => 'پریزهای آزاد';

  @override
  String get reservationNowLabel => 'همین الان';

  @override
  String get reservationIn15 => '۱۵ دقیقه دیگر';

  @override
  String get reservationIn30 => '۳۰ دقیقه دیگر';

  @override
  String get reservationIn1h => '۱ ساعت دیگر';

  @override
  String get reservationIn2h => '۲ ساعت دیگر';

  @override
  String get reservationDur15 => '۱۵ دقیقه';

  @override
  String get reservationDur30 => '۳۰ دقیقه';

  @override
  String get reservationDur45 => '۴۵ دقیقه';

  @override
  String get reservationDur1h => '۱ ساعت';

  @override
  String get reservationDur2h => '۲ ساعت';

  @override
  String get reservationNoUpcoming => 'رزروی پیش‌رو وجود ندارد';

  @override
  String get reservationNoActive => 'رزرو فعالی وجود ندارد';

  @override
  String get reservationNoCompleted => 'رزرو تکمیل‌شده‌ای وجود ندارد';

  @override
  String get reservationNoCancelled => 'رزرو لغوشده‌ای وجود ندارد';

  @override
  String get reservationAvailableOnly => 'فقط پریزهای آزاد قابل رزرو هستند';

  @override
  String get reservationSelectConnectorHint => 'پریزی برای رزرو انتخاب کنید';

  @override
  String get reservationConnectorSelected => 'انتخاب شد';

  @override
  String get reservationCancelSuccess => 'رزرو لغو شد';

  @override
  String reservationStepOf(int step, int total) {
    return '$step از $total';
  }

  @override
  String get reservationEstEnergy => 'انرژی تخمینی';

  @override
  String get reservationPowerLabel => 'توان';

  @override
  String get reservationOperatorLabel => 'اپراتور';

  @override
  String get reservationDistanceLabel => 'فاصله';

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
  String get loginTitle => 'شماره را وارد کنید';

  @override
  String get loginSubtitle => 'کد تأیید به این شماره ارسال می‌شود.';

  @override
  String get loginPhoneHint => '000 000 0000';

  @override
  String get loginSelectCountry => 'انتخاب کشور';

  @override
  String get loginCountryIran => 'ایران';

  @override
  String get loginCountryGermany => 'آلمان';

  @override
  String get loginInvalidPhone => 'یک شماره تلفن معتبر وارد کنید';

  @override
  String get otpTitle => 'تأیید شماره';

  @override
  String otpSubtitle(String phone) {
    return 'کد ۶ رقمی ارسال شده به $phone را وارد کنید.';
  }

  @override
  String otpResendIn(String seconds) {
    return 'ارسال مجدد در $seconds ثانیه';
  }

  @override
  String get otpResendCode => 'ارسال مجدد کد';

  @override
  String get otpInvalidCode => 'کد نادرست است. دوباره امتحان کنید.';

  @override
  String get otpSemanticLabel => 'کد تأیید ۶ رقمی';

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
