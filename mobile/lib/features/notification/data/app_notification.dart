enum NotificationType {
  reservationCreated,
  reservationReminder,
  chargingStarted,
  chargingCompleted,
  paymentProcessed,
  walletTopUp,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.deepLinkPath,
  });

  final String id;
  final NotificationType type;

  /// Localised at render time via NotificationType → l10n key.
  /// Body is stored as a string; in a real app it arrives from the server
  /// already in the user's preferred language.
  final String body;
  final DateTime timestamp;
  final bool isRead;

  /// GoRouter path to push when the notification is tapped.
  final String? deepLinkPath;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        body: body,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        deepLinkPath: deepLinkPath,
      );
}

abstract final class MockNotifications {
  static final seed = <AppNotification>[
    AppNotification(
      id: 'notif-006',
      type: NotificationType.chargingCompleted,
      body: '۱۸.۵ کیلووات‌ساعت در ایستگاه شارژ تهران پارک تحویل داده شد.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      deepLinkPath: '/charging/ses-001/summary',
    ),
    AppNotification(
      id: 'notif-005',
      type: NotificationType.paymentProcessed,
      body: '۲۵۹٬۰۰۰ تومان برای جلسه شارژ پرداخت شد.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      deepLinkPath: '/wallet/transactions/txn-006',
    ),
    AppNotification(
      id: 'notif-004',
      type: NotificationType.reservationReminder,
      body: 'رزرو شما در مرکز خرید ایران ۳۰ دقیقه دیگر شروع می‌شود.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
      deepLinkPath: '/reservations/r1',
    ),
    AppNotification(
      id: 'notif-003',
      type: NotificationType.walletTopUp,
      body: '۵۰۰٬۰۰۰ تومان به کیف‌پول شما اضافه شد.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      isRead: true,
      deepLinkPath: '/wallet/transactions/txn-005',
    ),
    AppNotification(
      id: 'notif-002',
      type: NotificationType.reservationCreated,
      body: 'رزرو شما در مرکز خرید ایران تأیید شد.',
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      isRead: true,
      deepLinkPath: '/reservations/r2',
    ),
    AppNotification(
      id: 'notif-001',
      type: NotificationType.chargingCompleted,
      body: '۹.۲ کیلووات‌ساعت در ایستگاه مرکز خرید ایران تحویل داده شد.',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
      deepLinkPath: '/charging/ses-002/summary',
    ),
  ];
}
