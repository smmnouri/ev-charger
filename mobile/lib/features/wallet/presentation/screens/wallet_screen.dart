import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_wallet.dart';
import '../providers/wallet_provider.dart';

enum _Filter { all, credits, debits }

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallet = ref.watch(walletProvider);

    final filtered = wallet.transactions.where((t) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.credits => t.isCredit,
        _Filter.debits => !t.isCredit,
      };
    }).toList();

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
          l10n.walletTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Balance card ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.s3,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: _BalanceCard(wallet: wallet, l10n: l10n),
            ),

            const SizedBox(height: AppSpacing.s5),

            // ── Filter chips ───────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                children: [
                  _FilterChip(
                    label: l10n.walletAllFilter,
                    selected: _filter == _Filter.all,
                    onTap: () => setState(() => _filter = _Filter.all),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  _FilterChip(
                    label: l10n.walletCreditsFilter,
                    selected: _filter == _Filter.credits,
                    onTap: () => setState(() => _filter = _Filter.credits),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  _FilterChip(
                    label: l10n.walletDebitsFilter,
                    selected: _filter == _Filter.debits,
                    onTap: () => setState(() => _filter = _Filter.debits),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s4),

            // ── Transaction list ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.walletTransactionHistory,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${filtered.length}',
                    style: const TextStyle(
                      color: AppColors.textTertiaryDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s3),

            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(l10n: l10n)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.s7,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.s2),
                      itemBuilder: (_, i) => _TransactionTile(
                        txn: filtered[i],
                        l10n: l10n,
                        onTap: () => context.push(
                          AppRoutes.walletTransactionDetailPath(filtered[i].id),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet, required this.l10n});

  final WalletState wallet;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF0F5EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.rXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Balance rows ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  label: l10n.walletAvailableBalance,
                  amount: wallet.availableToman,
                  l10n: l10n,
                  highlight: true,
                ),
              ),
              Expanded(
                child: _BalanceItem(
                  label: l10n.walletHeldBalance,
                  amount: wallet.heldToman,
                  l10n: l10n,
                  highlight: false,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s4),

          Divider(
              height: 1, color: Colors.white.withValues(alpha: 0.2)),

          const SizedBox(height: AppSpacing.s4),

          // ── Total + Top Up ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.walletTotalBalance,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatAmount(wallet.totalToman)} ${l10n.tomansUnit}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: l10n.walletTopUp,
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.walletTopup),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          l10n.walletTopUp,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.l10n,
    required this.highlight,
    this.align = CrossAxisAlignment.start,
  });

  final String label;
  final int amount;
  final AppLocalizations l10n;
  final bool highlight;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            color: highlight ? Colors.white : Colors.white70,
            fontSize: highlight ? 26 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          l10n.tomansUnit,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outlineDark.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondaryDark,
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.txn,
    required this.l10n,
    required this.onTap,
  });

  final WalletTransaction txn;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final amountColor =
        isCredit ? AppColors.secondary : AppColors.statusFaulted;
    final typeLabel = _typeLabel(txn.type, l10n);
    final timeLabel = _formatRelativeTime(txn.timestamp);

    return Semantics(
      button: true,
      label: '$typeLabel, ${txn.amountToman > 0 ? '+' : ''}${_formatAmount(txn.amountToman)} ${l10n.tomansUnit}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: AppRadius.rMd,
            border: Border.all(
                color: AppColors.outlineDark.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              _TxnIcon(type: txn.type, isCredit: isCredit),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (txn.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        txn.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        color: AppColors.textTertiaryDark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${txn.amountToman > 0 ? '+' : ''}${_formatAmount(txn.amountToman)}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.tomansUnit,
                    style: const TextStyle(
                      color: AppColors.textTertiaryDark,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.s2),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.textTertiaryDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnIcon extends StatelessWidget {
  const _TxnIcon({required this.type, required this.isCredit});

  final TransactionType type;
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      TransactionType.topUp =>
        (Icons.add_circle_outline_rounded, AppColors.secondary),
      TransactionType.chargingPayment =>
        (Icons.bolt_rounded, AppColors.primary),
      TransactionType.refund =>
        (Icons.undo_rounded, AppColors.tertiary),
      TransactionType.adjustment =>
        (Icons.tune_rounded, AppColors.warning),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
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
              child: const Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.walletNoTransactions,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.walletAddFundsToStart,
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

String _formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(dt);
}
