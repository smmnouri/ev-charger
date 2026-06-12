import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'EV Charger'**
  String get appName;

  /// Bottom nav: map tab label
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// Bottom nav: reservations tab label
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get tabReservations;

  /// Bottom nav: active charging tab label
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get tabCharging;

  /// Bottom nav: wallet tab label
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get tabWallet;

  /// Bottom nav: profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsNotifications;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// No description provided for @settingsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get settingsAnalytics;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get settingsHelp;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get settingsRateApp;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePersian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get languagePersian;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get walletBalance;

  /// No description provided for @walletAddFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get walletAddFunds;

  /// No description provided for @walletTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get walletTransactionHistory;

  /// No description provided for @walletNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get walletNoTransactions;

  /// No description provided for @walletAddFundsToStart.
  ///
  /// In en, this message translates to:
  /// **'Add funds to your wallet to start charging.'**
  String get walletAddFundsToStart;

  /// No description provided for @walletLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low balance — add funds before your next charge'**
  String get walletLowBalance;

  /// No description provided for @walletOfflineBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance as of {time}'**
  String walletOfflineBalance(String time);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get profileAccountSecurity;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your wallet and charging history.'**
  String get profileSignOutBody;

  /// No description provided for @profileKycVerified.
  ///
  /// In en, this message translates to:
  /// **'Identity Verified'**
  String get profileKycVerified;

  /// No description provided for @profileKycPending.
  ///
  /// In en, this message translates to:
  /// **'Verification in Progress'**
  String get profileKycPending;

  /// No description provided for @profileKycNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get profileKycNotStarted;

  /// No description provided for @profileKycRejected.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get profileKycRejected;

  /// No description provided for @profileKycRequired.
  ///
  /// In en, this message translates to:
  /// **'Required to reserve and start charging.'**
  String get profileKycRequired;

  /// No description provided for @profileKycVerifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get profileKycVerifyNow;

  /// No description provided for @profileKycTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get profileKycTryAgain;

  /// No description provided for @profileKycUsually.
  ///
  /// In en, this message translates to:
  /// **'Usually 2–5 min'**
  String get profileKycUsually;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see charging and reservation updates here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsAllCaughtUp;

  /// No description provided for @notificationsDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsDateToday;

  /// No description provided for @notificationsDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsDateYesterday;

  /// No description provided for @reservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservationsTitle;

  /// No description provided for @reservationNoReservations.
  ///
  /// In en, this message translates to:
  /// **'No reservations'**
  String get reservationNoReservations;

  /// No description provided for @reservationFindStation.
  ///
  /// In en, this message translates to:
  /// **'Find a station'**
  String get reservationFindStation;

  /// No description provided for @reservationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get reservationConfirmed;

  /// No description provided for @reservationPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reservationPending;

  /// No description provided for @reservationActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get reservationActive;

  /// No description provided for @reservationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reservationCompleted;

  /// No description provided for @reservationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reservationCancelled;

  /// No description provided for @reservationExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reservationExpired;

  /// No description provided for @reservationNoShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get reservationNoShow;

  /// No description provided for @reservationCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reservation'**
  String get reservationCancel;

  /// No description provided for @reservationStartCharging.
  ///
  /// In en, this message translates to:
  /// **'Start Charging'**
  String get reservationStartCharging;

  /// No description provided for @reservationCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get reservationCheckIn;

  /// No description provided for @stationAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get stationAvailable;

  /// No description provided for @stationCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get stationCharging;

  /// No description provided for @stationOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get stationOccupied;

  /// No description provided for @stationReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get stationReserved;

  /// No description provided for @stationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get stationUnavailable;

  /// No description provided for @stationFaulted.
  ///
  /// In en, this message translates to:
  /// **'Faulted'**
  String get stationFaulted;

  /// No description provided for @chargingTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get chargingTitle;

  /// No description provided for @chargingPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get chargingPreparing;

  /// No description provided for @chargingAuthorizing.
  ///
  /// In en, this message translates to:
  /// **'Authorizing'**
  String get chargingAuthorizing;

  /// No description provided for @chargingActive.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get chargingActive;

  /// No description provided for @chargingSuspendedVehicle.
  ///
  /// In en, this message translates to:
  /// **'Paused by Vehicle'**
  String get chargingSuspendedVehicle;

  /// No description provided for @chargingSuspendedCharger.
  ///
  /// In en, this message translates to:
  /// **'Paused by Charger'**
  String get chargingSuspendedCharger;

  /// No description provided for @chargingInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Interrupted'**
  String get chargingInterrupted;

  /// No description provided for @chargingFinishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing'**
  String get chargingFinishing;

  /// No description provided for @chargingFaulted.
  ///
  /// In en, this message translates to:
  /// **'Fault Detected'**
  String get chargingFaulted;

  /// No description provided for @chargingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop Charging'**
  String get chargingStop;

  /// No description provided for @chargingStopConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stop this session?'**
  String get chargingStopConfirm;

  /// No description provided for @chargingStopBody.
  ///
  /// In en, this message translates to:
  /// **'Your session will end and final billing will be calculated.'**
  String get chargingStopBody;

  /// No description provided for @chargingStopConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Stop Session'**
  String get chargingStopConfirmCta;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging Summary'**
  String get summaryTitle;

  /// No description provided for @summaryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get summaryDone;

  /// No description provided for @summaryAddFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get summaryAddFunds;

  /// No description provided for @summaryViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get summaryViewReceipt;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved data'**
  String get errorOffline;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @kwhUnit.
  ///
  /// In en, this message translates to:
  /// **'kWh'**
  String get kwhUnit;

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmUnit;

  /// No description provided for @minuteUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minuteUnit;

  /// No description provided for @tomansUnit.
  ///
  /// In en, this message translates to:
  /// **'tomans'**
  String get tomansUnit;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'¥'**
  String get currencySymbol;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
