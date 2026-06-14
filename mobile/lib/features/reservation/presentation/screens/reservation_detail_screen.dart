import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_reservation_repository.dart';
import '../providers/reservation_provider.dart';

class ReservationDetailScreen extends ConsumerWidget {
  const ReservationDetailScreen({super.key, required this.reservationId});
  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reservation = ref
        .watch(reservationProvider)
        .reservations
        .where((r) => r.id == reservationId)
        .firstOrNull;

    if (reservation == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: _buildAppBar(context, l10n),
        body: const Center(
          child: Icon(Icons.error_outline,
              color: AppColors.outlineDark, size: 48),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(context, l10n),
      body: _DetailBody(
        reservation: reservation,
        l10n: l10n,
        onCancel: () => _showCancelSheet(context, ref, reservation, l10n),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n) => AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.reservationIdLabel,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      );

  void _showCancelSheet(
    BuildContext context,
    WidgetRef ref,
    MockReservation reservation,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CancelSheet(
        l10n: l10n,
        onConfirm: () {
          Navigator.of(ctx).pop();
          ref
              .read(reservationProvider.notifier)
              .cancelReservation(reservation.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reservationCancelSuccess),
              backgroundColor: AppColors.statusFaulted,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onKeep: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

// ── Detail body ───────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.reservation,
    required this.l10n,
    required this.onCancel,
  });

  final MockReservation reservation;
  final AppLocalizations l10n;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'fa');
    final timeFormat = DateFormat('HH:mm', 'fa');

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status badge
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _StatusBadge(status: reservation.status),
                  ),
                  const SizedBox(height: 20),
                  // Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColors.outlineDark.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        _Row(
                          label: l10n.reservationIdLabel,
                          value: reservation.id,
                          bold: true,
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationStationLabel,
                          value: reservation.stationName,
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationConnectorLabel,
                          value: reservation.connectorTypeLabel,
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationPowerLabel,
                          value: '${reservation.powerKw.toInt()} kW',
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationStartTime,
                          value:
                              '${dateFormat.format(reservation.startTime)}  ${timeFormat.format(reservation.startTime)}',
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationDuration,
                          value:
                              '${reservation.durationMinutes} ${l10n.minuteUnit}',
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationEstCost,
                          value:
                              '${reservation.estimatedCostToman} ${l10n.tomansUnit}',
                          highlight: true,
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationOperatorLabel,
                          value: reservation.operatorName,
                        ),
                        const _Divider(),
                        _Row(
                          label: l10n.reservationDistanceLabel,
                          value: reservation.distanceFa,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (reservation.status == ReservationStatus.upcoming)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusFaulted,
                  side: BorderSide(
                      color: AppColors.statusFaulted.withValues(alpha: 0.5)),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.reservationCancelTitle),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });
  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondaryDark),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highlight
                      ? AppColors.primary
                      : bold
                          ? Colors.white
                          : Colors.white70,
                  fontWeight: bold || highlight ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.outlineDark.withValues(alpha: 0.3), height: 1);
}

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Cancel bottom sheet ───────────────────────────────────────────────────────

class _CancelSheet extends StatelessWidget {
  const _CancelSheet({
    required this.l10n,
    required this.onConfirm,
    required this.onKeep,
  });

  final AppLocalizations l10n;
  final VoidCallback onConfirm;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.reservationCancelTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.reservationCancelBody,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.statusFaulted,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.reservationCancelConfirmBtn),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onKeep,
              child: Text(
                l10n.close,
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
