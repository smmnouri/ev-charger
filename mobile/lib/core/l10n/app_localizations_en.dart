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
  String get tabMap => 'Home';

  @override
  String get tabReservations => 'Reservations';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabHistory => 'History';

  @override
  String get tabCharging => 'Charging';

  @override
  String get tabWallet => 'Wallet';

  @override
  String get tabProfile => 'Profile';

  @override
  String get homeSearchHint => 'Search charging stations…';

  @override
  String get homeNearby => 'Nearby Stations';

  @override
  String get homeReserve => 'Reserve';

  @override
  String get homeFilter => 'Filter';

  @override
  String get homeViewStation => 'View Station';

  @override
  String get homeNavigate => 'Navigate';

  @override
  String get homeConnectors => 'CONNECTORS';

  @override
  String get homeAmenities => 'AMENITIES';

  @override
  String get homeHours => 'HOURS';

  @override
  String get homeAllBusy => 'All connectors busy';

  @override
  String get homeFilterType2 => 'Type 2';

  @override
  String get homeFilterCCS => 'CCS';

  @override
  String get homeFilterCHAdeMO => 'CHAdeMO';

  @override
  String get homeFilterGBT => 'GB/T';

  @override
  String get homeFilterAvailable => 'Available';

  @override
  String get homeFilterDC => 'DC Fast';

  @override
  String get homeFilterAC => 'AC';

  @override
  String get homeSearchRecent => 'Recent';

  @override
  String get homeSearchNearby => 'Nearby stations';

  @override
  String get homeNoStationsFilter => 'No stations match filters';

  @override
  String get homeAmenityParking => 'Parking';

  @override
  String get homeAmenityCoffee => 'Coffee';

  @override
  String get homeAmenityRestroom => 'Restroom';

  @override
  String get homeAmenityWifi => 'Wi-Fi';

  @override
  String get homeHours24 => 'Open 24 hours';

  @override
  String get homeClearFilters => 'Clear filters';

  @override
  String homeActiveFiltersCount(int count) {
    return '$count active';
  }

  @override
  String get homeFilterNearby => 'Nearby';

  @override
  String get homeNoStationsArea => 'No stations in this area';

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
  String get settingsAccount => 'Account';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsFaq => 'FAQ';

  @override
  String get settingsContactSupport => 'Contact Support';

  @override
  String get settingsAboutApp => 'About App';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsPersonalInfo => 'Personal Information';

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
  String get profilePhoneLabel => 'Phone Number';

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
  String get notifReservation => 'Reservation Notifications';

  @override
  String get notifCharging => 'Charging Notifications';

  @override
  String get notifPayment => 'Payment Notifications';

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
  String get reservationNewTitle => 'New Reservation';

  @override
  String get reservationSelectConnector => 'Select Connector';

  @override
  String get reservationTimeAndDuration => 'Time & Duration';

  @override
  String get reservationSummaryStep => 'Summary';

  @override
  String get reservationStartTime => 'Start Time';

  @override
  String get reservationDuration => 'Duration';

  @override
  String get reservationEstCost => 'Estimated Cost';

  @override
  String reservationEstKwh(String kwh) {
    return 'Approx. $kwh kWh';
  }

  @override
  String get reservationConfirmCta => 'Confirm Reservation';

  @override
  String get reservationSuccessTitle => 'Reservation Confirmed!';

  @override
  String get reservationSuccessSubtitle =>
      'Your reservation has been placed successfully';

  @override
  String get reservationIdLabel => 'Booking ID';

  @override
  String get reservationCountdown => 'Time until start';

  @override
  String get reservationStartsNow => 'Starting now';

  @override
  String get reservationViewDetails => 'View Details';

  @override
  String get reservationNavigateStation => 'Navigate to Station';

  @override
  String get reservationCancelTitle => 'Cancel Reservation';

  @override
  String get reservationCancelBody =>
      'Your reservation will be cancelled and the slot will be released.';

  @override
  String get reservationCancelConfirmBtn => 'Yes, Cancel';

  @override
  String get reservationUpcomingTab => 'Upcoming';

  @override
  String get reservationActiveTab => 'Active';

  @override
  String get reservationCompletedTab => 'Completed';

  @override
  String get reservationCancelledTab => 'Cancelled';

  @override
  String get reservationStationLabel => 'Station';

  @override
  String get reservationConnectorLabel => 'Connector';

  @override
  String get reservationAvailableConnectors => 'Available Connectors';

  @override
  String get reservationNowLabel => 'Now';

  @override
  String get reservationIn15 => 'In 15 min';

  @override
  String get reservationIn30 => 'In 30 min';

  @override
  String get reservationIn1h => 'In 1 hour';

  @override
  String get reservationIn2h => 'In 2 hours';

  @override
  String get reservationDur15 => '15 min';

  @override
  String get reservationDur30 => '30 min';

  @override
  String get reservationDur45 => '45 min';

  @override
  String get reservationDur1h => '1 hour';

  @override
  String get reservationDur2h => '2 hours';

  @override
  String get reservationNoUpcoming => 'No upcoming reservations';

  @override
  String get reservationNoActive => 'No active reservations';

  @override
  String get reservationNoCompleted => 'No completed reservations';

  @override
  String get reservationNoCancelled => 'No cancelled reservations';

  @override
  String get reservationAvailableOnly =>
      'Only available connectors can be reserved';

  @override
  String get reservationSelectConnectorHint => 'Choose a connector to reserve';

  @override
  String get reservationConnectorSelected => 'Selected';

  @override
  String get reservationCancelSuccess => 'Reservation cancelled';

  @override
  String reservationStepOf(int step, int total) {
    return '$step of $total';
  }

  @override
  String get reservationEstEnergy => 'Estimated Energy';

  @override
  String get reservationPowerLabel => 'Power';

  @override
  String get reservationOperatorLabel => 'Operator';

  @override
  String get reservationDistanceLabel => 'Distance';

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
  String get chargingStarting => 'Starting';

  @override
  String get chargingAuthorizing => 'Authorizing';

  @override
  String get chargingActive => 'Charging';

  @override
  String get chargingPaused => 'Paused';

  @override
  String get chargingSuspendedVehicle => 'Paused by Vehicle';

  @override
  String get chargingSuspendedCharger => 'Paused by Charger';

  @override
  String get chargingInterrupted => 'Interrupted';

  @override
  String get chargingFinishing => 'Finishing…';

  @override
  String get chargingFaulted => 'Fault Detected';

  @override
  String get chargingCompleted => 'Completed';

  @override
  String get chargingFailed => 'Failed';

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
  String get chargingEmergencyStop => 'Emergency Stop';

  @override
  String get chargingCurrentPower => 'Current Power';

  @override
  String get chargingEnergyDelivered => 'Energy Delivered';

  @override
  String get chargingDuration => 'Charging Time';

  @override
  String get chargingSessionId => 'Session ID';

  @override
  String get chargingNoSession => 'No active session';

  @override
  String get chargingNoSessionBody =>
      'Find a station on the map to start charging';

  @override
  String get chargingConnector => 'Connector';

  @override
  String get summaryTitle => 'Charging Summary';

  @override
  String get summaryDone => 'Done';

  @override
  String get summaryAddFunds => 'Add Funds';

  @override
  String get summaryViewReceipt => 'View Receipt';

  @override
  String get summarySessionId => 'Session ID';

  @override
  String get summaryTotalDuration => 'Total Duration';

  @override
  String get summaryTotalEnergy => 'Total Energy';

  @override
  String get summaryTotalCost => 'Total Cost';

  @override
  String get summaryBackHome => 'Back to Home';

  @override
  String get historyTitle => 'Charging History';

  @override
  String get historyNoSessions => 'No charging sessions yet';

  @override
  String get historyNoSessionsBody =>
      'Your past charging sessions will appear here';

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
  String get loginTitle => 'Enter your number';

  @override
  String get loginSubtitle => 'We\'ll send a verification code to this number.';

  @override
  String get loginPhoneHint => '000 000 0000';

  @override
  String get loginSelectCountry => 'Select country';

  @override
  String get loginCountryIran => 'Iran';

  @override
  String get loginCountryGermany => 'Germany';

  @override
  String get loginInvalidPhone => 'Enter a valid phone number';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone.';
  }

  @override
  String otpResendIn(String seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpResendCode => 'Resend code';

  @override
  String get otpInvalidCode => 'Incorrect code. Try again.';

  @override
  String get otpSemanticLabel => '6-digit verification code';

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
