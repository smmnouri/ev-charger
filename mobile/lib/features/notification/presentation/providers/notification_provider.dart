import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_notification.dart';

class NotificationNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => List.of(MockNotifications.seed);

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void delete(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void add(AppNotification notification) {
    state = [notification, ...state];
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<AppNotification>>(
  NotificationNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
