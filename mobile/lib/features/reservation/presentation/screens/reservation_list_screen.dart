import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_reservation_repository.dart';
import '../providers/reservation_provider.dart';

class ReservationListScreen extends ConsumerWidget {
  const ReservationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reservations = ref.watch(reservationProvider).reservations;

    final upcoming = reservations
        .where((r) => r.status == ReservationStatus.upcoming)
        .toList();
    final active =
        reservations.where((r) => r.status == ReservationStatus.active).toList();
    final completed = reservations
        .where((r) => r.status == ReservationStatus.completed)
        .toList();
    final cancelled = reservations
        .where((r) => r.status == ReservationStatus.cancelled)
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          title: Text(
            l10n.reservationsTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          bottom: TabBar(
            isScrollable: false,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryDark,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: l10n.reservationUpcomingTab),
              Tab(text: l10n.reservationActiveTab),
              Tab(text: l10n.reservationCompletedTab),
              Tab(text: l10n.reservationCancelledTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReservationTab(
              reservations: upcoming,
              emptyMessage: l10n.reservationNoUpcoming,
            ),
            _ReservationTab(
              reservations: active,
              emptyMessage: l10n.reservationNoActive,
            ),
            _ReservationTab(
              reservations: completed,
              emptyMessage: l10n.reservationNoCompleted,
            ),
            _ReservationTab(
              reservations: cancelled,
              emptyMessage: l10n.reservationNoCancelled,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab list ──────────────────────────────────────────────────────────────────

class _ReservationTab extends StatelessWidget {
  const _ReservationTab({
    required this.reservations,
    required this.emptyMessage,
  });

  final List<MockReservation> reservations;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return _EmptyState(message: emptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: reservations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _ReservationCard(reservation: reservations[i]),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});
  final MockReservation reservation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final startFormatted =
        '${AppDateFormatter.shortDate(reservation.startTime, lang)}  ${AppDateFormatter.time(reservation.startTime, lang)}';

    return Semantics(
      label:
          '${reservation.stationName}، ${reservation.connectorTypeLabel}، $startFormatted',
      button: true,
      child: GestureDetector(
        onTap: () => context.push('/reservations/${reservation.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.outlineDark.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.stationName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: reservation.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                reservation.connectorTypeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: AppColors.textTertiaryDark),
                  const SizedBox(width: 4),
                  Text(
                    startFormatted,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${reservation.durationMinutes} ${l10n.minuteUnit}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      ReservationStatus.upcoming => (l10n.reservationUpcomingTab, AppColors.primary),
      ReservationStatus.active => (l10n.reservationActiveTab, AppColors.statusAvailable),
      ReservationStatus.completed => (l10n.reservationCompletedTab, AppColors.textSecondaryDark),
      ReservationStatus.cancelled => (l10n.reservationCancelledTab, AppColors.statusFaulted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 48, color: AppColors.outlineDark),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
