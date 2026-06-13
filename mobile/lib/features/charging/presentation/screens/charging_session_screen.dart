import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_charging_session.dart';
import '../providers/charging_provider.dart';

class ChargingSessionScreen extends ConsumerStatefulWidget {
  const ChargingSessionScreen({
    super.key,
    required this.sessionId,
    required this.stationId,
    required this.connectorId,
  });

  final String sessionId;
  final String stationId;
  final String connectorId;

  @override
  ConsumerState<ChargingSessionScreen> createState() =>
      _ChargingSessionScreenState();
}

class _ChargingSessionScreenState extends ConsumerState<ChargingSessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chargingSessionProvider.notifier).startSession(
            sessionId: widget.sessionId,
            stationId: widget.stationId,
            connectorId: widget.connectorId,
          );
    });
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen<ChargingSessionState>(chargingSessionProvider, (_, next) {
      final status = next.session?.status;
      final isSpinning = status == ChargingStatus.preparing ||
          status == ChargingStatus.starting ||
          status == ChargingStatus.charging ||
          status == ChargingStatus.finishing;

      if (isSpinning && !_rotCtrl.isAnimating) {
        _rotCtrl.repeat();
      } else if (!isSpinning && _rotCtrl.isAnimating) {
        _rotCtrl.stop();
      }

      if (status == ChargingStatus.completed && !_navigating) {
        _navigating = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacement(
                AppRoutes.chargingSummaryPath(widget.sessionId));
            ref.read(chargingSessionProvider.notifier).clearSession();
          }
        });
      }
    });

    final sessionState = ref.watch(chargingSessionProvider);
    final session = sessionState.session;

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
        title: Text(
          session?.stationName ?? l10n.chargingTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _StatusChip(status: session.status, l10n: l10n),
            ),
        ],
      ),
      body: SafeArea(
        child: session == null
            ? _EmptyState(l10n: l10n)
            : _SessionBody(
                session: session,
                rotCtrl: _rotCtrl,
                l10n: l10n,
                onStop: () => _confirmStop(context, l10n),
                onEmergencyStop: () => _emergencyStop(context, l10n),
                onDismissError: () {
                  ref.read(chargingSessionProvider.notifier).clearSession();
                  context.pop();
                },
              ),
      ),
    );
  }

  void _confirmStop(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: Text(
          l10n.chargingStopConfirm,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.chargingStopBody,
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(chargingSessionProvider.notifier).stopCharging();
            },
            child: Text(
              l10n.chargingStopConfirmCta,
              style: const TextStyle(color: AppColors.statusFaulted),
            ),
          ),
        ],
      ),
    );
  }

  void _emergencyStop(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: Text(
          l10n.chargingEmergencyStop,
          style: const TextStyle(
              color: AppColors.statusFaulted, fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.chargingStopBody,
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(chargingSessionProvider.notifier).emergencyStop();
            },
            child: Text(
              l10n.chargingEmergencyStop,
              style: const TextStyle(color: AppColors.statusFaulted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Session body ──────────────────────────────────────────────────────────────

class _SessionBody extends StatelessWidget {
  const _SessionBody({
    required this.session,
    required this.rotCtrl,
    required this.l10n,
    required this.onStop,
    required this.onEmergencyStop,
    required this.onDismissError,
  });

  final MockChargingSession session;
  final AnimationController rotCtrl;
  final AppLocalizations l10n;
  final VoidCallback onStop;
  final VoidCallback onEmergencyStop;
  final VoidCallback onDismissError;

  @override
  Widget build(BuildContext context) {
    final isFailed = session.status == ChargingStatus.failed;
    final isFinishing = session.status == ChargingStatus.finishing;
    final isTerminal = isFailed ||
        session.status == ChargingStatus.completed ||
        isFinishing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.s7),

          // ── Animated ring ────────────────────────────────────────────────
          Center(
            child: SizedBox(
              width: AppSpacing.sessionRingSize,
              height: AppSpacing.sessionRingSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: rotCtrl,
                    child: CircularProgressIndicator(
                      value: isFailed ? 0.15 : 0.72,
                      strokeWidth: AppSpacing.sessionRingStroke,
                      backgroundColor:
                          AppColors.surfaceDark.withValues(alpha: 0.6),
                      color: _ringColor(session.status),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  _RingCenter(session: session, l10n: l10n),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s5),

          // ── Status label ─────────────────────────────────────────────────
          Text(
            _statusLabel(session.status, l10n),
            style: TextStyle(
              color: _ringColor(session.status),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: AppSpacing.s7),

          // ── Stat cards ───────────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                label: l10n.chargingEnergyDelivered,
                value: session.energyKwh.toStringAsFixed(2),
                unit: l10n.kwhUnit,
                icon: Icons.bolt_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.s3),
              _StatCard(
                label: l10n.chargingDuration,
                value: _formatDuration(session.elapsedSeconds),
                unit: '',
                icon: Icons.timer_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.s3),
              _StatCard(
                label: l10n.reservationEstCost,
                value: _formatCost(session.estimatedCostToman),
                unit: l10n.tomansUnit,
                icon: Icons.payments_outlined,
                color: AppColors.tertiary,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s4),

          // ── Info card ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppRadius.rMd,
              border: Border.all(
                  color: AppColors.outlineDark.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: l10n.chargingConnector,
                    value: session.connectorTypeLabel,
                    icon: Icons.ev_station_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.outlineDark.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: _InfoItem(
                    label: l10n.chargingCurrentPower,
                    value: '${session.powerKw.toStringAsFixed(0)} kW',
                    icon: Icons.flash_on_rounded,
                    align: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Controls ─────────────────────────────────────────────────────
          if (isFailed)
            _ErrorControls(l10n: l10n, onDismiss: onDismissError)
          else if (isFinishing)
            const _FinishingIndicator()
          else if (!isTerminal) ...[
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeightLarge,
              child: ElevatedButton.icon(
                onPressed: onStop,
                icon: const Icon(Icons.stop_circle_outlined, size: 20),
                label: Text(l10n.chargingStop),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: onEmergencyStop,
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: Text(l10n.chargingEmergencyStop),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusFaulted,
                  side: BorderSide(
                    color: AppColors.statusFaulted.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }

  Color _ringColor(ChargingStatus status) => switch (status) {
        ChargingStatus.completed => AppColors.secondary,
        ChargingStatus.failed => AppColors.statusFaulted,
        ChargingStatus.paused => AppColors.textSecondaryDark,
        ChargingStatus.charging => AppColors.secondary,
        _ => AppColors.primary,
      };

  String _statusLabel(ChargingStatus status, AppLocalizations l10n) =>
      switch (status) {
        ChargingStatus.preparing => l10n.chargingPreparing,
        ChargingStatus.starting => l10n.chargingStarting,
        ChargingStatus.charging => l10n.chargingActive,
        ChargingStatus.paused => l10n.chargingPaused,
        ChargingStatus.finishing => l10n.chargingFinishing,
        ChargingStatus.completed => l10n.chargingCompleted,
        ChargingStatus.failed => l10n.chargingFailed,
      };
}

// ── Ring center content ───────────────────────────────────────────────────────

class _RingCenter extends StatelessWidget {
  const _RingCenter({required this.session, required this.l10n});

  final MockChargingSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return switch (session.status) {
      ChargingStatus.failed => const Icon(
          Icons.error_outline_rounded,
          size: 52,
          color: AppColors.statusFaulted,
        ),
      ChargingStatus.completed => const Icon(
          Icons.check_circle_outline_rounded,
          size: 52,
          color: AppColors.secondary,
        ),
      ChargingStatus.paused => const Icon(
          Icons.pause_circle_outline_rounded,
          size: 52,
          color: AppColors.textSecondaryDark,
        ),
      ChargingStatus.finishing => const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
      ChargingStatus.charging => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(session.elapsedSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              '${session.energyKwh.toStringAsFixed(2)} ${l10n.kwhUnit}',
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      _ => const Icon(
          Icons.bolt_rounded,
          size: 52,
          color: AppColors.primary,
        ),
    };
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s2, vertical: AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.rMd,
          border: Border.all(
              color: AppColors.outlineDark.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: AppSpacing.s1),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 10,
                ),
              ),
            const SizedBox(height: AppSpacing.s1),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info item ─────────────────────────────────────────────────────────────────

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.align = TextAlign.left,
  });

  final String label;
  final String value;
  final IconData icon;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final isRight = align == TextAlign.right;
    return Padding(
      padding: EdgeInsets.only(
        left: isRight ? AppSpacing.s4 : 0,
        right: isRight ? 0 : AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isRight) ...[
                Icon(icon, size: 14, color: AppColors.textTertiaryDark),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 11,
                ),
              ),
              if (isRight) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 14, color: AppColors.textTertiaryDark),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: align,
          ),
        ],
      ),
    );
  }
}

// ── Error controls ────────────────────────────────────────────────────────────

class _ErrorControls extends StatelessWidget {
  const _ErrorControls({required this.l10n, required this.onDismiss});

  final AppLocalizations l10n;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.statusFaulted, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.chargingFailed,
              style: const TextStyle(
                color: AppColors.statusFaulted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: OutlinedButton(
            onPressed: onDismiss,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppColors.outlineDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(l10n.back),
          ),
        ),
      ],
    );
  }
}

// ── Finishing indicator ───────────────────────────────────────────────────────

class _FinishingIndicator extends StatelessWidget {
  const _FinishingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: CircularProgressIndicator(color: AppColors.primary),
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
              child: const Icon(Icons.ev_station_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.chargingNoSession,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.chargingNoSessionBody,
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

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final ChargingStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ChargingStatus.charging => AppColors.secondary,
      ChargingStatus.failed => AppColors.statusFaulted,
      ChargingStatus.completed => AppColors.secondary,
      ChargingStatus.paused => AppColors.textSecondaryDark,
      _ => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        switch (status) {
          ChargingStatus.preparing => l10n.chargingPreparing,
          ChargingStatus.starting => l10n.chargingStarting,
          ChargingStatus.charging => l10n.chargingActive,
          ChargingStatus.paused => l10n.chargingPaused,
          ChargingStatus.finishing => l10n.chargingFinishing,
          ChargingStatus.completed => l10n.chargingCompleted,
          ChargingStatus.failed => l10n.chargingFailed,
        },
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _formatCost(int toman) {
  if (toman >= 1000000) {
    return NumberFormat.compact(locale: 'en').format(toman);
  }
  return NumberFormat('#,###', 'en').format(toman);
}
