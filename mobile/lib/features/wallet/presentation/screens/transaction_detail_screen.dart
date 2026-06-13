import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_wallet.dart';
import '../providers/wallet_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final txn = ref
        .watch(walletProvider)
        .transactions
        .where((t) => t.id == transactionId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.txnTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: txn == null
          ? const Center(
              child: Icon(Icons.receipt_long_rounded,
                  color: AppColors.textTertiaryDark, size: 48))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.s7),

                    // ── Amount medallion ─────────────────────────────────
                    _AmountMedallion(txn: txn, l10n: l10n),

                    const SizedBox(height: AppSpacing.s7),

                    // ── Detail rows ──────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: AppRadius.rLg,
                        border: Border.all(
                          color: AppColors.outlineDark.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: l10n.txnId,
                            value: txn.id,
                          ),
                          _DetailRow(
                            label: l10n.txnDate,
                            value: DateFormat('MMM d, yyyy · HH:mm')
                                .format(txn.timestamp),
                          ),
                          _DetailRow(
                            label: l10n.txnType,
                            value: _typeLabel(txn.type, l10n),
                          ),
                          _DetailRow(
                            label: l10n.txnStatus,
                            valueWidget: _StatusBadge(
                                status: txn.status, l10n: l10n),
                          ),
                          _DetailRow(
                            label: l10n.txnAmount,
                            value:
                                '${txn.amountToman > 0 ? '+' : ''}${_formatAmount(txn.amountToman)} ${l10n.tomansUnit}',
                            valueColor: txn.isCredit
                                ? AppColors.secondary
                                : AppColors.statusFaulted,
                          ),
                          _DetailRow(
                            label: l10n.txnBalanceBefore,
                            value:
                                '${_formatAmount(txn.balanceBeforeToman)} ${l10n.tomansUnit}',
                          ),
                          _DetailRow(
                            label: l10n.txnBalanceAfter,
                            value:
                                '${_formatAmount(txn.balanceAfterToman)} ${l10n.tomansUnit}',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    if (txn.description != null) ...[
                      const SizedBox(height: AppSpacing.s4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: AppRadius.rMd,
                          border: Border.all(
                            color:
                                AppColors.outlineDark.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          txn.description!,
                          style: const TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Amount medallion ──────────────────────────────────────────────────────────

class _AmountMedallion extends StatelessWidget {
  const _AmountMedallion({required this.txn, required this.l10n});

  final WalletTransaction txn;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final color =
        isCredit ? AppColors.secondary : AppColors.statusFaulted;
    final icon = switch (txn.type) {
      TransactionType.topUp => Icons.add_circle_outline_rounded,
      TransactionType.chargingPayment => Icons.bolt_rounded,
      TransactionType.refund => Icons.undo_rounded,
      TransactionType.adjustment => Icons.tune_rounded,
    };

    return Column(
      children: [
        Container(
          width: AppSpacing.summaryMedallionSize,
          height: AppSpacing.summaryMedallionSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border:
                Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Icon(icon, color: color, size: 40),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          '${txn.amountToman > 0 ? '+' : ''}${_formatAmount(txn.amountToman)}',
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          l10n.tomansUnit,
          style: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    this.isLast = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
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
              if (valueWidget != null)
                valueWidget!
              else
                Flexible(
                  child: Text(
                    value ?? '',
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
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

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.l10n});

  final TransactionStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransactionStatus.completed =>
        (l10n.txnStatusCompleted, AppColors.secondary),
      TransactionStatus.pending =>
        (l10n.txnStatusPending, AppColors.warning),
      TransactionStatus.failed =>
        (l10n.txnStatusFailed, AppColors.statusFaulted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _typeLabel(TransactionType type, AppLocalizations l10n) =>
    switch (type) {
      TransactionType.topUp => l10n.txnTypeTopUp,
      TransactionType.chargingPayment => l10n.txnTypeChargingPayment,
      TransactionType.refund => l10n.txnTypeRefund,
      TransactionType.adjustment => l10n.txnTypeAdjustment,
    };

String _formatAmount(int toman) {
  final abs = toman.abs();
  return NumberFormat('#,###', 'en').format(abs);
}
