/// All named routes in the application.
/// Source of truth: docs/ui/SCREEN_INVENTORY_FINAL.md §2
abstract final class AppRoutes {
  // Auth
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/onboarding/login';
  static const onboardingVerify = '/onboarding/verify';

  // Main tabs
  static const map = '/map';
  static const reservations = '/reservations';
  static const wallet = '/wallet';
  static const profile = '/profile';
  static const notifications = '/notifications';

  // Station
  static const stationDetails = '/stations/:id';
  static const stationGallery = '/stations/:id/gallery';

  static String stationDetailsPath(String id) => '/stations/$id';
  static String stationGalleryPath(String id) => '/stations/$id/gallery';

  // Reservation
  static const reservationCreate = '/reservations/create/:stationId';
  static const reservationDetail = '/reservations/:id';

  static String reservationCreatePath(String stationId) => '/reservations/create/$stationId';
  static String reservationDetailPath(String id) => '/reservations/$id';

  // Additional main tabs
  static const scan = '/scan';
  static const history = '/history';

  // Charging
  static const chargingHub = '/charging';
  static const chargingSession = '/charging/:sessionId';
  static const chargingSummary = '/charging/:sessionId/summary';

  static String chargingSessionPath(String sessionId) => '/charging/$sessionId';
  static String chargingSummaryPath(String sessionId) => '/charging/$sessionId/summary';

  // Wallet
  static const walletTopup = '/wallet/topup';
  static const walletTransactionDetail = '/wallet/transactions/:id';

  static String walletTransactionDetailPath(String id) => '/wallet/transactions/$id';

  // Profile
  static const profileEdit = '/profile/edit';
  static const profileKyc = '/profile/kyc';
  static const profileKycStatus = '/profile/kyc/status';
  static const profileSecurity = '/profile/security';

  // Support
  static const support = '/support';
  static const supportFaq = '/support/faq';
  static const supportTicketCreate = '/support/tickets/new';
  static const supportTicketDetail = '/support/tickets/:id';

  static String supportTicketDetailPath(String id) => '/support/tickets/$id';

  // Settings
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static const settingsAppearance = '/settings/appearance';
  static const settingsNotifications = '/settings/notifications';
  static const settingsLocation = '/settings/location';
}
