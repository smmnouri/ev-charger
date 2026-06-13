import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_support.dart';
import '../providers/support_provider.dart';

class TicketDetailScreen extends ConsumerWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tickets = ref.watch(ticketProvider);
    final ticket = tickets.where((t) => t.id == ticketId).firstOrNull;

    if (ticket == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            l10n.errorGeneric,
            style: const TextStyle(color: AppColors.textSecondaryDark),
          ),
        ),
      );
    }

    final (statusLabel, statusColor) = _statusStyle(ticket.status, l10n);
    final (catLabel, _) = _categoryStyle(ticket.category, l10n);

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
          l10n.supportTicketDetail,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.s4,
            AppSpacing.screenHorizontal,
            AppSpacing.s8,
          ),
          children: [
            // ── Header card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: AppRadius.rLg,
                border: Border.all(
                    color: AppColors.outlineDark.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(label: statusLabel, color: statusColor),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.rFull,
                          border: Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          catLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: l10n.supportTicketId,
                    value: ticket.id,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    label: l10n.supportTicketCreated,
                    value: DateFormat('MMM d, yyyy · HH:mm')
                        .format(ticket.createdAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s5),

            // ── Conversation ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s3),
              child: Text(
                l10n.supportConversation.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            for (final msg in ticket.messages)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                child: _MessageBubble(message: msg),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final isSupport = message.isSupport;

    return Semantics(
      label: '${isSupport ? 'Support' : 'You'}: ${message.body}',
      child: Column(
        crossAxisAlignment:
            isSupport ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
                isSupport ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isSupport) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      size: 16, color: AppColors.secondary),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                isSupport ? 'Support' : 'You',
                style: TextStyle(
                  color: isSupport
                      ? AppColors.secondary
                      : AppColors.textTertiaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d, HH:mm').format(message.timestamp),
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: isSupport
                  ? AppColors.surfaceDark
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.md),
                topRight: const Radius.circular(AppRadius.md),
                bottomLeft: isSupport
                    ? const Radius.circular(2)
                    : const Radius.circular(AppRadius.md),
                bottomRight: isSupport
                    ? const Radius.circular(AppRadius.md)
                    : const Radius.circular(2),
              ),
              border: Border.all(
                color: isSupport
                    ? AppColors.outlineDark.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              message.body,
              style: TextStyle(
                color: isSupport
                    ? AppColors.textSecondaryDark
                    : Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textTertiaryDark,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.rFull,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
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

(String, Color) _statusStyle(TicketStatus status, AppLocalizations l10n) =>
    switch (status) {
      TicketStatus.open => (l10n.supportStatusOpen, AppColors.primary),
      TicketStatus.inProgress =>
        (l10n.supportStatusInProgress, AppColors.warning),
      TicketStatus.resolved =>
        (l10n.supportStatusResolved, AppColors.statusAvailable),
      TicketStatus.closed =>
        (l10n.supportStatusClosed, AppColors.textTertiaryDark),
    };

(String, IconData) _categoryStyle(
  SupportCategory cat,
  AppLocalizations l10n,
) =>
    switch (cat) {
      SupportCategory.reservations =>
        (l10n.supportCatReservations, Icons.event_available_rounded),
      SupportCategory.charging =>
        (l10n.supportCatCharging, Icons.bolt_rounded),
      SupportCategory.wallet =>
        (l10n.supportCatWallet, Icons.account_balance_wallet_outlined),
      SupportCategory.payments =>
        (l10n.supportCatPayments, Icons.payment_rounded),
      SupportCategory.account =>
        (l10n.supportCatAccount, Icons.person_outline_rounded),
    };
