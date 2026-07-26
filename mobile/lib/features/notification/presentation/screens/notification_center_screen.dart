import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/app_notification.dart';
import '../providers/notification_provider.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifications = ref.watch(notificationProvider);
    final unread = ref.watch(unreadCountProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.notificationsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (unread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: notifier.markAllRead,
                child: Text(
                  l10n.notificationsMarkAllRead,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? _EmptyState(l10n: l10n)
            : _GroupedList(
                notifications: notifications,
                l10n: l10n,
                notifier: notifier,
                onTap: (notif) => _onTap(context, ref, notif),
              ),
      ),
    );
  }

  void _onTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notif,
  ) {
    if (!notif.isRead) {
      ref.read(notificationProvider.notifier).markRead(notif.id);
    }
    if (notif.deepLinkPath != null) {
      context.push(notif.deepLinkPath!);
    }
  }
}

String _typeLabel(NotificationType type, AppLocalizations l10n) =>
    switch (type) {
      NotificationType.reservationCreated => l10n.notifTypeReservationCreated,
      NotificationType.reservationReminder =>
        l10n.notifTypeReservationReminder,
      NotificationType.chargingStarted => l10n.notifTypeChargingStarted,
      NotificationType.chargingCompleted => l10n.notifTypeChargingCompleted,
      NotificationType.paymentProcessed => l10n.notifTypePaymentProcessed,
      NotificationType.walletTopUp => l10n.notifTypeWalletTopUp,
    };

// ── Grouped list ──────────────────────────────────────────────────────────────

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.notifications,
    required this.l10n,
    required this.notifier,
    required this.onTap,
  });

  final List<AppNotification> notifications;
  final AppLocalizations l10n;
  final NotificationNotifier notifier;
  final ValueChanged<AppNotification> onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final today = notifications
        .where((n) => n.timestamp.isAfter(todayStart))
        .toList();
    final yesterday = notifications
        .where((n) =>
            n.timestamp.isAfter(yesterdayStart) &&
            !n.timestamp.isAfter(todayStart))
        .toList();
    final earlier = notifications
        .where((n) => !n.timestamp.isAfter(yesterdayStart))
        .toList();

    final items = <_ListItem>[];
    if (today.isNotEmpty) {
      items.add(_ListItem.header(l10n.notificationsDateToday));
      for (final n in today) {
        items.add(_ListItem.notification(n));
      }
    }
    if (yesterday.isNotEmpty) {
      items.add(_ListItem.header(l10n.notificationsDateYesterday));
      for (final n in yesterday) {
        items.add(_ListItem.notification(n));
      }
    }
    if (earlier.isNotEmpty) {
      items.add(_ListItem.header(l10n.notifGroupEarlier));
      for (final n in earlier) {
        items.add(_ListItem.notification(n));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.s2,
        AppSpacing.screenHorizontal,
        AppSpacing.s7,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        if (item.isHeader) {
          return _GroupHeader(label: item.header!);
        }
        final notif = item.notification!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s2),
          child: Dismissible(
            key: ValueKey(notif.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => notifier.delete(notif.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.statusFaulted.withValues(alpha: 0.85),
                borderRadius: AppRadius.rMd,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 24),
            ),
            child: _NotifTile(
              notif: notif,
              l10n: l10n,
              onTap: () => onTap(notif),
              onMarkRead: notif.isRead
                  ? null
                  : () => notifier.markRead(notif.id),
            ),
          ),
        );
      },
    );
  }
}

class _ListItem {
  const _ListItem._({this.header, this.notification});

  factory _ListItem.header(String label) =>
      _ListItem._(header: label);
  factory _ListItem.notification(AppNotification n) =>
      _ListItem._(notification: n);

  final String? header;
  final AppNotification? notification;

  bool get isHeader => header != null;
}

// ── Group header ──────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textTertiaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.l10n,
    required this.onTap,
    this.onMarkRead,
  });

  final AppNotification notif;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;
    final (typeColor, typeIcon) = _typeStyle(notif.type);
    final title = _typeLabel(notif.type, l10n);

    return Semantics(
      button: true,
      label: '$title. ${notif.body}. '
          '${_formatRelativeTime(notif.timestamp)}.'
          '${isUnread ? ' Unread.' : ''}',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onMarkRead,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.surfaceDark.withValues(alpha: 0.95)
                : AppColors.surfaceDark.withValues(alpha: 0.6),
            borderRadius: AppRadius.rMd,
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.outlineDark.withValues(alpha: 0.3),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Unread left accent bar ────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  decoration: BoxDecoration(
                    color: isUnread ? AppColors.primary : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(AppRadius.md),
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type icon
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(typeIcon,
                                  size: 20, color: typeColor),
                            ),
                            if (isUnread)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.backgroundDark,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: AppSpacing.s3),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: isUnread
                                            ? Colors.white
                                            : AppColors.textSecondaryDark,
                                        fontSize: 14,
                                        fontWeight: isUnread
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatRelativeTime(notif.timestamp),
                                    style: const TextStyle(
                                      color: AppColors.textTertiaryDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                style: const TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.notificationsEmpty,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.notificationsEmptyBody,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

(Color, IconData) _typeStyle(NotificationType type) => switch (type) {
      NotificationType.reservationCreated =>
        (AppColors.tertiary, Icons.event_available_rounded),
      NotificationType.reservationReminder =>
        (AppColors.warning, Icons.alarm_rounded),
      NotificationType.chargingStarted =>
        (AppColors.primary, Icons.bolt_rounded),
      NotificationType.chargingCompleted =>
        (AppColors.secondary, Icons.check_circle_outline_rounded),
      NotificationType.paymentProcessed =>
        (AppColors.tertiary, Icons.payment_rounded),
      NotificationType.walletTopUp =>
        (AppColors.secondary, Icons.add_circle_outline_rounded),
    };

String _formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays == 1) return '1d';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return DateFormat('MMM d').format(dt);
}
