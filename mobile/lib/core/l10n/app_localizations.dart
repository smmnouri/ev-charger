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

  /// Bottom nav: home/map tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabMap;

  /// Bottom nav: reservations tab label
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get tabReservations;

  /// Bottom nav: scan/QR tab label
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get tabScan;

  /// Bottom nav: charging history tab label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

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

  /// Home screen: search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search charging stations…'**
  String get homeSearchHint;

  /// Home screen: nearby stations section header
  ///
  /// In en, this message translates to:
  /// **'Nearby Stations'**
  String get homeNearby;

  /// Home screen: station card reserve button label
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get homeReserve;

  /// Home screen: filter button label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get homeFilter;

  /// No description provided for @homeViewStation.
  ///
  /// In en, this message translates to:
  /// **'View Station'**
  String get homeViewStation;

  /// No description provided for @homeNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get homeNavigate;

  /// No description provided for @homeConnectors.
  ///
  /// In en, this message translates to:
  /// **'CONNECTORS'**
  String get homeConnectors;

  /// No description provided for @homeAmenities.
  ///
  /// In en, this message translates to:
  /// **'AMENITIES'**
  String get homeAmenities;

  /// No description provided for @homeHours.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get homeHours;

  /// No description provided for @homeAllBusy.
  ///
  /// In en, this message translates to:
  /// **'All connectors busy'**
  String get homeAllBusy;

  /// No description provided for @homeFilterType2.
  ///
  /// In en, this message translates to:
  /// **'Type 2'**
  String get homeFilterType2;

  /// No description provided for @homeFilterCCS.
  ///
  /// In en, this message translates to:
  /// **'CCS'**
  String get homeFilterCCS;

  /// No description provided for @homeFilterCHAdeMO.
  ///
  /// In en, this message translates to:
  /// **'CHAdeMO'**
  String get homeFilterCHAdeMO;

  /// No description provided for @homeFilterGBT.
  ///
  /// In en, this message translates to:
  /// **'GB/T'**
  String get homeFilterGBT;

  /// No description provided for @homeFilterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get homeFilterAvailable;

  /// No description provided for @homeFilterDC.
  ///
  /// In en, this message translates to:
  /// **'DC Fast'**
  String get homeFilterDC;

  /// No description provided for @homeFilterAC.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get homeFilterAC;

  /// No description provided for @homeSearchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeSearchRecent;

  /// No description provided for @homeSearchNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby stations'**
  String get homeSearchNearby;

  /// No description provided for @homeNoStationsFilter.
  ///
  /// In en, this message translates to:
  /// **'No stations match filters'**
  String get homeNoStationsFilter;

  /// No description provided for @homeAmenityParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get homeAmenityParking;

  /// No description provided for @homeAmenityCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get homeAmenityCoffee;

  /// No description provided for @homeAmenityRestroom.
  ///
  /// In en, this message translates to:
  /// **'Restroom'**
  String get homeAmenityRestroom;

  /// No description provided for @homeAmenityWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get homeAmenityWifi;

  /// No description provided for @homeHours24.
  ///
  /// In en, this message translates to:
  /// **'Open 24 hours'**
  String get homeHours24;

  /// No description provided for @homeClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get homeClearFilters;

  /// No description provided for @homeActiveFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String homeActiveFiltersCount(int count);

  /// No description provided for @homeFilterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get homeFilterNearby;

  /// No description provided for @homeNoStationsArea.
  ///
  /// In en, this message translates to:
  /// **'No stations in this area'**
  String get homeNoStationsArea;

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

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupportSection;

  /// No description provided for @settingsFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get settingsFaq;

  /// No description provided for @settingsContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsContactSupport;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAboutApp;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get settingsPersonalInfo;

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

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get walletAvailableBalance;

  /// No description provided for @walletHeldBalance.
  ///
  /// In en, this message translates to:
  /// **'Held Balance'**
  String get walletHeldBalance;

  /// No description provided for @walletTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get walletTotalBalance;

  /// No description provided for @walletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get walletTopUp;

  /// No description provided for @walletAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get walletAllFilter;

  /// No description provided for @walletCreditsFilter.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get walletCreditsFilter;

  /// No description provided for @walletDebitsFilter.
  ///
  /// In en, this message translates to:
  /// **'Debits'**
  String get walletDebitsFilter;

  /// No description provided for @walletRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get walletRecentTransactions;

  /// No description provided for @walletSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get walletSeeAll;

  /// No description provided for @walletTopUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get walletTopUpTitle;

  /// No description provided for @walletTopUpSelectAmount.
  ///
  /// In en, this message translates to:
  /// **'Select an amount'**
  String get walletTopUpSelectAmount;

  /// No description provided for @walletTopUpCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom amount'**
  String get walletTopUpCustom;

  /// No description provided for @walletTopUpEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in tomans'**
  String get walletTopUpEnterAmount;

  /// No description provided for @walletTopUpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Top Up'**
  String get walletTopUpConfirm;

  /// No description provided for @walletTopUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Top Up Successful!'**
  String get walletTopUpSuccess;

  /// No description provided for @walletTopUpSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your wallet has been topped up with {amount} tomans.'**
  String walletTopUpSuccessBody(String amount);

  /// No description provided for @txnTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get txnTitle;

  /// No description provided for @txnId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get txnId;

  /// No description provided for @txnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txnDate;

  /// No description provided for @txnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txnAmount;

  /// No description provided for @txnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get txnType;

  /// No description provided for @txnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get txnStatus;

  /// No description provided for @txnBalanceBefore.
  ///
  /// In en, this message translates to:
  /// **'Balance Before'**
  String get txnBalanceBefore;

  /// No description provided for @txnBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance After'**
  String get txnBalanceAfter;

  /// No description provided for @txnTypeTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get txnTypeTopUp;

  /// No description provided for @txnTypeChargingPayment.
  ///
  /// In en, this message translates to:
  /// **'Charging Payment'**
  String get txnTypeChargingPayment;

  /// No description provided for @txnTypeRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get txnTypeRefund;

  /// No description provided for @txnTypeAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get txnTypeAdjustment;

  /// No description provided for @txnStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get txnStatusCompleted;

  /// No description provided for @txnStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get txnStatusPending;

  /// No description provided for @txnStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get txnStatusFailed;

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

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneLabel;

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

  /// No description provided for @notifReservation.
  ///
  /// In en, this message translates to:
  /// **'Reservation Notifications'**
  String get notifReservation;

  /// No description provided for @notifCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging Notifications'**
  String get notifCharging;

  /// No description provided for @notifPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Notifications'**
  String get notifPayment;

  /// No description provided for @notifTypeReservationCreated.
  ///
  /// In en, this message translates to:
  /// **'Reservation Confirmed'**
  String get notifTypeReservationCreated;

  /// No description provided for @notifTypeReservationReminder.
  ///
  /// In en, this message translates to:
  /// **'Reservation Reminder'**
  String get notifTypeReservationReminder;

  /// No description provided for @notifTypeChargingStarted.
  ///
  /// In en, this message translates to:
  /// **'Charging Started'**
  String get notifTypeChargingStarted;

  /// No description provided for @notifTypeChargingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Charging Complete'**
  String get notifTypeChargingCompleted;

  /// No description provided for @notifTypePaymentProcessed.
  ///
  /// In en, this message translates to:
  /// **'Payment Processed'**
  String get notifTypePaymentProcessed;

  /// No description provided for @notifTypeWalletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Wallet Topped Up'**
  String get notifTypeWalletTopUp;

  /// No description provided for @notifDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notifDeleteAction;

  /// No description provided for @notifMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get notifMarkRead;

  /// No description provided for @notifGroupEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifGroupEarlier;

  /// No description provided for @notifUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notifUnreadCount(int count);

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

  /// No description provided for @reservationNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Reservation'**
  String get reservationNewTitle;

  /// No description provided for @reservationSelectConnector.
  ///
  /// In en, this message translates to:
  /// **'Select Connector'**
  String get reservationSelectConnector;

  /// No description provided for @reservationTimeAndDuration.
  ///
  /// In en, this message translates to:
  /// **'Time & Duration'**
  String get reservationTimeAndDuration;

  /// No description provided for @reservationSummaryStep.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reservationSummaryStep;

  /// No description provided for @reservationStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get reservationStartTime;

  /// No description provided for @reservationDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get reservationDuration;

  /// No description provided for @reservationEstCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated Cost'**
  String get reservationEstCost;

  /// No description provided for @reservationEstKwh.
  ///
  /// In en, this message translates to:
  /// **'Approx. {kwh} kWh'**
  String reservationEstKwh(String kwh);

  /// No description provided for @reservationConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reservation'**
  String get reservationConfirmCta;

  /// No description provided for @reservationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation Confirmed!'**
  String get reservationSuccessTitle;

  /// No description provided for @reservationSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your reservation has been placed successfully'**
  String get reservationSuccessSubtitle;

  /// No description provided for @reservationIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get reservationIdLabel;

  /// No description provided for @reservationCountdown.
  ///
  /// In en, this message translates to:
  /// **'Time until start'**
  String get reservationCountdown;

  /// No description provided for @reservationStartsNow.
  ///
  /// In en, this message translates to:
  /// **'Starting now'**
  String get reservationStartsNow;

  /// No description provided for @reservationViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get reservationViewDetails;

  /// No description provided for @reservationNavigateStation.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Station'**
  String get reservationNavigateStation;

  /// No description provided for @reservationCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reservation'**
  String get reservationCancelTitle;

  /// No description provided for @reservationCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Your reservation will be cancelled and the slot will be released.'**
  String get reservationCancelBody;

  /// No description provided for @reservationCancelConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get reservationCancelConfirmBtn;

  /// No description provided for @reservationUpcomingTab.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get reservationUpcomingTab;

  /// No description provided for @reservationActiveTab.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get reservationActiveTab;

  /// No description provided for @reservationCompletedTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reservationCompletedTab;

  /// No description provided for @reservationCancelledTab.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reservationCancelledTab;

  /// No description provided for @reservationStationLabel.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get reservationStationLabel;

  /// No description provided for @reservationConnectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Connector'**
  String get reservationConnectorLabel;

  /// No description provided for @reservationAvailableConnectors.
  ///
  /// In en, this message translates to:
  /// **'Available Connectors'**
  String get reservationAvailableConnectors;

  /// No description provided for @reservationNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get reservationNowLabel;

  /// No description provided for @reservationIn15.
  ///
  /// In en, this message translates to:
  /// **'In 15 min'**
  String get reservationIn15;

  /// No description provided for @reservationIn30.
  ///
  /// In en, this message translates to:
  /// **'In 30 min'**
  String get reservationIn30;

  /// No description provided for @reservationIn1h.
  ///
  /// In en, this message translates to:
  /// **'In 1 hour'**
  String get reservationIn1h;

  /// No description provided for @reservationIn2h.
  ///
  /// In en, this message translates to:
  /// **'In 2 hours'**
  String get reservationIn2h;

  /// No description provided for @reservationDur15.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get reservationDur15;

  /// No description provided for @reservationDur30.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get reservationDur30;

  /// No description provided for @reservationDur45.
  ///
  /// In en, this message translates to:
  /// **'45 min'**
  String get reservationDur45;

  /// No description provided for @reservationDur1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get reservationDur1h;

  /// No description provided for @reservationDur2h.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get reservationDur2h;

  /// No description provided for @reservationNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reservations'**
  String get reservationNoUpcoming;

  /// No description provided for @reservationNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active reservations'**
  String get reservationNoActive;

  /// No description provided for @reservationNoCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed reservations'**
  String get reservationNoCompleted;

  /// No description provided for @reservationNoCancelled.
  ///
  /// In en, this message translates to:
  /// **'No cancelled reservations'**
  String get reservationNoCancelled;

  /// No description provided for @reservationAvailableOnly.
  ///
  /// In en, this message translates to:
  /// **'Only available connectors can be reserved'**
  String get reservationAvailableOnly;

  /// No description provided for @reservationSelectConnectorHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a connector to reserve'**
  String get reservationSelectConnectorHint;

  /// No description provided for @reservationConnectorSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get reservationConnectorSelected;

  /// No description provided for @reservationCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reservation cancelled'**
  String get reservationCancelSuccess;

  /// No description provided for @reservationStepOf.
  ///
  /// In en, this message translates to:
  /// **'{step} of {total}'**
  String reservationStepOf(int step, int total);

  /// No description provided for @reservationEstEnergy.
  ///
  /// In en, this message translates to:
  /// **'Estimated Energy'**
  String get reservationEstEnergy;

  /// No description provided for @reservationPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get reservationPowerLabel;

  /// No description provided for @reservationOperatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get reservationOperatorLabel;

  /// No description provided for @reservationDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get reservationDistanceLabel;

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

  /// No description provided for @chargingStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get chargingStarting;

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

  /// No description provided for @chargingPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get chargingPaused;

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
  /// **'Finishing…'**
  String get chargingFinishing;

  /// No description provided for @chargingFaulted.
  ///
  /// In en, this message translates to:
  /// **'Fault Detected'**
  String get chargingFaulted;

  /// No description provided for @chargingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get chargingCompleted;

  /// No description provided for @chargingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get chargingFailed;

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

  /// No description provided for @chargingEmergencyStop.
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop'**
  String get chargingEmergencyStop;

  /// No description provided for @chargingCurrentPower.
  ///
  /// In en, this message translates to:
  /// **'Current Power'**
  String get chargingCurrentPower;

  /// No description provided for @chargingEnergyDelivered.
  ///
  /// In en, this message translates to:
  /// **'Energy Delivered'**
  String get chargingEnergyDelivered;

  /// No description provided for @chargingDuration.
  ///
  /// In en, this message translates to:
  /// **'Charging Time'**
  String get chargingDuration;

  /// No description provided for @chargingSessionId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get chargingSessionId;

  /// No description provided for @chargingNoSession.
  ///
  /// In en, this message translates to:
  /// **'No active session'**
  String get chargingNoSession;

  /// No description provided for @chargingNoSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Find a station on the map to start charging'**
  String get chargingNoSessionBody;

  /// No description provided for @chargingConnector.
  ///
  /// In en, this message translates to:
  /// **'Connector'**
  String get chargingConnector;

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

  /// No description provided for @summarySessionId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get summarySessionId;

  /// No description provided for @summaryTotalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get summaryTotalDuration;

  /// No description provided for @summaryTotalEnergy.
  ///
  /// In en, this message translates to:
  /// **'Total Energy'**
  String get summaryTotalEnergy;

  /// No description provided for @summaryTotalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get summaryTotalCost;

  /// No description provided for @summaryBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get summaryBackHome;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging History'**
  String get historyTitle;

  /// No description provided for @historyNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No charging sessions yet'**
  String get historyNoSessions;

  /// No description provided for @historyNoSessionsBody.
  ///
  /// In en, this message translates to:
  /// **'Your past charging sessions will appear here'**
  String get historyNoSessionsBody;

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

  /// Welcome screen: hero headline
  ///
  /// In en, this message translates to:
  /// **'Welcome to EV Charger'**
  String get welcomeTitle;

  /// Welcome screen: value proposition body text
  ///
  /// In en, this message translates to:
  /// **'Find charging stations, make reservations, and manage your sessions — all in one place.'**
  String get welcomeBody;

  /// Welcome screen: primary CTA button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcomeGetStarted;

  /// Login screen: app bar title
  ///
  /// In en, this message translates to:
  /// **'Enter your number'**
  String get loginTitle;

  /// Login screen: instruction below title
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to this number.'**
  String get loginSubtitle;

  /// Login screen: phone field placeholder — digits only, always LTR
  ///
  /// In en, this message translates to:
  /// **'000 000 0000'**
  String get loginPhoneHint;

  /// Login screen: country picker bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get loginSelectCountry;

  /// Login screen: country name — Iran
  ///
  /// In en, this message translates to:
  /// **'Iran'**
  String get loginCountryIran;

  /// Login screen: country name — Germany
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get loginCountryGermany;

  /// Login screen: validation error shown below phone field
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get loginInvalidPhone;

  /// OTP screen: app bar title
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// OTP screen: instruction with the destination phone number
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}.'**
  String otpSubtitle(String phone);

  /// OTP screen: countdown label before resend becomes available
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String otpResendIn(String seconds);

  /// OTP screen: button to request a new verification code
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendCode;

  /// OTP screen: error shown when the entered code is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Try again.'**
  String get otpInvalidCode;

  /// OTP screen: accessibility label for the digit input area
  ///
  /// In en, this message translates to:
  /// **'6-digit verification code'**
  String get otpSemanticLabel;

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

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportTitle;

  /// No description provided for @supportFaq.
  ///
  /// In en, this message translates to:
  /// **'Browse FAQ'**
  String get supportFaq;

  /// No description provided for @supportFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get supportFaqTitle;

  /// No description provided for @supportFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get supportFaqSubtitle;

  /// No description provided for @supportFaqSearch.
  ///
  /// In en, this message translates to:
  /// **'Search questions…'**
  String get supportFaqSearch;

  /// No description provided for @supportFaqEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String supportFaqEmpty(String query);

  /// No description provided for @supportMyTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get supportMyTickets;

  /// No description provided for @supportNewTicket.
  ///
  /// In en, this message translates to:
  /// **'New Ticket'**
  String get supportNewTicket;

  /// No description provided for @supportNoTickets.
  ///
  /// In en, this message translates to:
  /// **'No support tickets yet'**
  String get supportNoTickets;

  /// No description provided for @supportNoTicketsBody.
  ///
  /// In en, this message translates to:
  /// **'Submit a ticket and track your issue here'**
  String get supportNoTicketsBody;

  /// No description provided for @supportTicketSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportTicketSubject;

  /// No description provided for @supportTicketCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get supportTicketCategory;

  /// No description provided for @supportTicketDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get supportTicketDescription;

  /// No description provided for @supportTicketDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue in detail…'**
  String get supportTicketDescHint;

  /// No description provided for @supportTicketSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get supportTicketSubmit;

  /// No description provided for @supportTicketSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket Submitted'**
  String get supportTicketSuccess;

  /// No description provided for @supportTicketSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get back to you within 24 hours.'**
  String get supportTicketSuccessBody;

  /// No description provided for @supportTicketDetail.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get supportTicketDetail;

  /// No description provided for @supportTicketId.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID'**
  String get supportTicketId;

  /// No description provided for @supportTicketCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get supportTicketCreated;

  /// No description provided for @supportConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get supportConversation;

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get supportStatusResolved;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @supportCatReservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get supportCatReservations;

  /// No description provided for @supportCatCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get supportCatCharging;

  /// No description provided for @supportCatWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get supportCatWallet;

  /// No description provided for @supportCatPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get supportCatPayments;

  /// No description provided for @supportCatAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get supportCatAccount;

  /// No description provided for @supportContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get supportContactTitle;

  /// No description provided for @supportContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get supportContactEmail;

  /// No description provided for @supportContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get supportContactPhone;

  /// No description provided for @supportContactWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get supportContactWhatsApp;
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
