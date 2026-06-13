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

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tickets = ref.watch(ticketProvider);

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
          l10n.supportTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.s4,
            AppSpacing.screenHorizontal,
            AppSpacing.s8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── FAQ shortcut ─────────────────────────────────────────────
              _FaqCard(l10n: l10n),

              const SizedBox(height: AppSpacing.s5),

              // ── My tickets ───────────────────────────────────────────────
              _SectionHeader(
                title: l10n.supportMyTickets,
                action: TextButton.icon(
                  onPressed: () => context.push('/support/tickets/new'),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(l10n.supportNewTicket),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s2),

              tickets.isEmpty
                  ? _EmptyTickets(l10n: l10n)
                  : _TicketList(tickets: tickets, l10n: l10n),

              const SizedBox(height: AppSpacing.s5),

              // ── Contact ──────────────────────────────────────────────────
              _SectionHeader(title: l10n.supportContactTitle),
              const SizedBox(height: AppSpacing.s2),
              _ContactSection(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAQ shortcut card ─────────────────────────────────────────────────────────

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.supportFaq,
      child: GestureDetector(
        onTap: () => context.push('/support/faq'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F3460), Color(0xFF1A4A8A)],
            ),
            borderRadius: AppRadius.rLg,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supportFaqTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.supportFaqSubtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryDark,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textTertiaryDark,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        ?action,
      ],
    );
  }
}

// ── Ticket list ───────────────────────────────────────────────────────────────

class _TicketList extends StatelessWidget {
  const _TicketList({required this.tickets, required this.l10n});

  final List<SupportTicket> tickets;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tickets.length; i++) ...[
            _TicketTile(
              ticket: tickets[i],
              l10n: l10n,
              isLast: i == tickets.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({
    required this.ticket,
    required this.l10n,
    required this.isLast,
  });

  final SupportTicket ticket;
  final AppLocalizations l10n;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusStyle(ticket.status, l10n);

    return Column(
      children: [
        Semantics(
          button: true,
          label: '${ticket.subject}. $statusLabel',
          child: InkWell(
            onTap: () => context.push('/support/tickets/${ticket.id}'),
            borderRadius: isLast
                ? const BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg))
                : BorderRadius.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ticket.id}  ·  ${DateFormat('MMM d').format(ticket.createdAt)}',
                          style: const TextStyle(
                            color: AppColors.textTertiaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(label: statusLabel, color: statusColor),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            color: AppColors.outlineDark.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}

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

// ── Empty tickets ─────────────────────────────────────────────────────────────

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.supportNoTickets,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            l10n.supportNoTicketsBody,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Contact section ───────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _ContactTile(
            icon: Icons.email_outlined,
            label: l10n.supportContactEmail,
            value: MockSupportData.contactEmail,
            color: AppColors.tertiary,
          ),
          Divider(
            height: 1,
            indent: 16,
            color: AppColors.outlineDark.withValues(alpha: 0.4),
          ),
          _ContactTile(
            icon: Icons.phone_outlined,
            label: l10n.supportContactPhone,
            value: MockSupportData.contactPhone,
            color: AppColors.secondary,
          ),
          Divider(
            height: 1,
            indent: 16,
            color: AppColors.outlineDark.withValues(alpha: 0.4),
          ),
          _ContactTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: l10n.supportContactWhatsApp,
            value: MockSupportData.contactWhatsApp,
            color: const Color(0xFF25D366),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $value',
      child: InkWell(
        onTap: () {},
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.lg))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textTertiaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textTertiaryDark,
              ),
            ],
          ),
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
