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
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.deepLinkPath,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  /// GoRouter path to push when the notification is tapped.
  final String? deepLinkPath;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
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
      title: 'Charging Complete',
      body: '18.5 kWh delivered at Tehran Park Charging Station.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      deepLinkPath: '/charging/ses-001/summary',
    ),
    AppNotification(
      id: 'notif-005',
      type: NotificationType.paymentProcessed,
      title: 'Payment Processed',
      body: '259,000 tomans charged for charging session.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      deepLinkPath: '/wallet/transactions/txn-006',
    ),
    AppNotification(
      id: 'notif-004',
      type: NotificationType.reservationReminder,
      title: 'Reservation Reminder',
      body: 'Your reservation at Mall of Iran starts in 30 minutes.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
      deepLinkPath: '/reservations/r1',
    ),
    AppNotification(
      id: 'notif-003',
      type: NotificationType.walletTopUp,
      title: 'Wallet Topped Up',
      body: '500,000 tomans added to your wallet.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      isRead: true,
      deepLinkPath: '/wallet/transactions/txn-005',
    ),
    AppNotification(
      id: 'notif-002',
      type: NotificationType.reservationCreated,
      title: 'Reservation Confirmed',
      body: 'Your reservation at Mall of Iran is confirmed.',
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      isRead: true,
      deepLinkPath: '/reservations/r2',
    ),
    AppNotification(
      id: 'notif-001',
      type: NotificationType.chargingCompleted,
      title: 'Charging Complete',
      body: '9.2 kWh delivered at Mall of Iran Station.',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
      deepLinkPath: '/charging/ses-002/summary',
    ),
  ];
}
