import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../charging/data/mock_charging_session.dart';
import '../../../charging/presentation/providers/charging_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(chargingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.historyTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: entries.isEmpty
          ? _EmptyState(l10n: l10n)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.s3,
                AppSpacing.screenHorizontal,
                AppSpacing.s7,
              ),
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.s3),
              itemBuilder: (_, i) => _HistoryCard(entry: entries[i], l10n: l10n),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry, required this.l10n});

  final ChargingHistoryEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${entry.stationName}, ${entry.energyKwh.toStringAsFixed(1)} ${l10n.kwhUnit}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.rMd,
          border: Border.all(
              color: AppColors.outlineDark.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.stationName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.connectorTypeLabel} · ${_formatDate(entry.startTime, Localizations.localeOf(context).languageCode)}',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.chargingCompleted,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s4),
            Divider(
                height: 1,
                color: AppColors.outlineDark.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.s3),

            // ── Stats row ────────────────────────────────────────────────
            Row(
              children: [
                _StatItem(
                  icon: Icons.bolt_rounded,
                  value:
                      '${entry.energyKwh.toStringAsFixed(1)} ${l10n.kwhUnit}',
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.s5),
                _StatItem(
                  icon: Icons.timer_rounded,
                  value: _formatDuration(entry.durationSeconds),
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.s5),
                _StatItem(
                  icon: Icons.payments_outlined,
                  value:
                      '${_formatCost(entry.totalCostToman)} ${l10n.tomansUnit}',
                  color: AppColors.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.secondary, size: 40),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.historyNoSessions,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.historyNoSessionsBody,
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

String _formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

String _formatDate(DateTime dt, String languageCode) {
  return AppDateFormatter.dateTime(dt, languageCode);
}

String _formatCost(int toman) {
  if (toman >= 1000000) {
    return NumberFormat.compact(locale: 'en').format(toman);
  }
  return NumberFormat('#,###', 'en').format(toman);
}
