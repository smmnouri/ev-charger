// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EV Charger';

  @override
  String get tabMap => 'Map';

  @override
  String get tabReservations => 'Reservations';

  @override
  String get tabCharging => 'Charging';

  @override
  String get tabWallet => 'Wallet';

  @override
  String get tabProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsNotifications => 'Notification Settings';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsAnalytics => 'Analytics';

  @override
  String get settingsExportData => 'Export My Data';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsHelp => 'Help and Support';

  @override
  String get settingsRateApp => 'Rate the App';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'Persian';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletBalance => 'Balance';

  @override
  String get walletAddFunds => 'Add Funds';

  @override
  String get walletTransactionHistory => 'Transaction History';

  @override
  String get walletNoTransactions => 'No transactions yet';

  @override
  String get walletAddFundsToStart =>
      'Add funds to your wallet to start charging.';

  @override
  String get walletLowBalance =>
      'Low balance — add funds before your next charge';

  @override
  String walletOfflineBalance(String time) {
    return 'Balance as of $time';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileAccountSecurity => 'Account Security';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Sign out?';

  @override
  String get profileSignOutBody =>
      'You\'ll need to sign in again to access your wallet and charging history.';

  @override
  String get profileKycVerified => 'Identity Verified';

  @override
  String get profileKycPending => 'Verification in Progress';

  @override
  String get profileKycNotStarted => 'Verify Your Identity';

  @override
  String get profileKycRejected => 'Verification Failed';

  @override
  String get profileKycRequired => 'Required to reserve and start charging.';

  @override
  String get profileKycVerifyNow => 'Verify Now';

  @override
  String get profileKycTryAgain => 'Try Again';

  @override
  String get profileKycUsually => 'Usually 2–5 min';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'You\'ll see charging and reservation updates here.';

  @override
  String get notificationsAllCaughtUp => 'You\'re all caught up';

  @override
  String get notificationsDateToday => 'Today';

  @override
  String get notificationsDateYesterday => 'Yesterday';

  @override
  String get reservationsTitle => 'Reservations';

  @override
  String get reservationNoReservations => 'No reservations';

  @override
  String get reservationFindStation => 'Find a station';

  @override
  String get reservationConfirmed => 'Confirmed';

  @override
  String get reservationPending => 'Pending';

  @override
  String get reservationActive => 'Active';

  @override
  String get reservationCompleted => 'Completed';

  @override
  String get reservationCancelled => 'Cancelled';

  @override
  String get reservationExpired => 'Expired';

  @override
  String get reservationNoShow => 'No Show';

  @override
  String get reservationCancel => 'Cancel Reservation';

  @override
  String get reservationStartCharging => 'Start Charging';

  @override
  String get reservationCheckIn => 'Check In';

  @override
  String get stationAvailable => 'Available';

  @override
  String get stationCharging => 'Charging';

  @override
  String get stationOccupied => 'Occupied';

  @override
  String get stationReserved => 'Reserved';

  @override
  String get stationUnavailable => 'Unavailable';

  @override
  String get stationFaulted => 'Faulted';

  @override
  String get chargingTitle => 'Charging';

  @override
  String get chargingPreparing => 'Preparing';

  @override
  String get chargingAuthorizing => 'Authorizing';

  @override
  String get chargingActive => 'Charging';

  @override
  String get chargingSuspendedVehicle => 'Paused by Vehicle';

  @override
  String get chargingSuspendedCharger => 'Paused by Charger';

  @override
  String get chargingInterrupted => 'Interrupted';

  @override
  String get chargingFinishing => 'Finishing';

  @override
  String get chargingFaulted => 'Fault Detected';

  @override
  String get chargingStop => 'Stop Charging';

  @override
  String get chargingStopConfirm => 'Stop this session?';

  @override
  String get chargingStopBody =>
      'Your session will end and final billing will be calculated.';

  @override
  String get chargingStopConfirmCta => 'Stop Session';

  @override
  String get summaryTitle => 'Charging Summary';

  @override
  String get summaryDone => 'Done';

  @override
  String get summaryAddFunds => 'Add Funds';

  @override
  String get summaryViewReceipt => 'View Receipt';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorRetry => 'Retry';

  @override
  String get errorOffline => 'Offline — showing saved data';

  @override
  String get welcomeTitle => 'Welcome to EV Charger';

  @override
  String get welcomeBody =>
      'Find charging stations, make reservations, and manage your sessions — all in one place.';

  @override
  String get welcomeGetStarted => 'Get Started';

  @override
  String get loading => 'Loading…';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get continue_ => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get or => 'or';

  @override
  String get kwhUnit => 'kWh';

  @override
  String get kmUnit => 'km';

  @override
  String get minuteUnit => 'min';

  @override
  String get tomansUnit => 'tomans';

  @override
  String get currencySymbol => '¥';
}
