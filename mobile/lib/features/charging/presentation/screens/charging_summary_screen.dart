import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/charging_provider.dart';

class ChargingSummaryScreen extends ConsumerWidget {
  const ChargingSummaryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(chargingHistoryProvider);
    final entry = history.where((e) => e.id == sessionId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.summaryTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s8),

              // ── Success medallion ──────────────────────────────────────
              Semantics(
                label: l10n.chargingCompleted,
                child: Container(
                  width: AppSpacing.summaryMedallionSize,
                  height: AppSpacing.summaryMedallionSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.secondary,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s4),

              Text(
                l10n.chargingCompleted,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.s7),

              // ── Session details ────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: AppRadius.rLg,
                  border: Border.all(
                    color: AppColors.outlineDark.withValues(alpha: 0.4),
                  ),
                ),
                child: entry == null
                    ? _SummaryRow(
                        label: l10n.summarySessionId,
                        value: sessionId,
                        isLast: true,
                      )
                    : Column(
                        children: [
                          _SummaryRow(
                            label: l10n.summarySessionId,
                            value: entry.id,
                          ),
                          _SummaryRow(
                            label: l10n.summaryTotalDuration,
                            value: _formatDuration(entry.durationSeconds),
                          ),
                          _SummaryRow(
                            label: l10n.summaryTotalEnergy,
                            value:
                                '${entry.energyKwh.toStringAsFixed(2)} ${l10n.kwhUnit}',
                          ),
                          _SummaryRow(
                            label: l10n.summaryTotalCost,
                            value:
                                '${_formatCost(entry.totalCostToman)} ${l10n.tomansUnit}',
                            isLast: true,
                          ),
                        ],
                      ),
              ),

              const Spacer(),

              // ── Back to Home ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.map),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    l10n.summaryBackHome,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.outlineDark.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
  return '${m}m ${s.toString().padLeft(2, '0')}s';
}

String _formatCost(int toman) {
  if (toman >= 1000000) {
    return NumberFormat.compact(locale: 'en').format(toman);
  }
  return NumberFormat('#,###', 'en').format(toman);
}
