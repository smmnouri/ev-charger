import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_support.dart';
import '../providers/support_provider.dart';

class TicketCreateScreen extends ConsumerStatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  ConsumerState<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends ConsumerState<TicketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  SupportCategory _category = SupportCategory.charging;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;
    ref.read(ticketProvider.notifier).createTicket(
          subject: _subjectCtrl.text.trim(),
          category: _category,
          description: _descCtrl.text.trim(),
        );
    _showSuccess(l10n);
  }

  void _showSuccess(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.statusAvailable.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.statusAvailable, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.supportTicketSuccess,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.supportTicketSuccessBody,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          l10n.supportNewTicket,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                // ── Subject ────────────────────────────────────────────────
                _FieldLabel(l10n.supportTicketSubject),
                const SizedBox(height: AppSpacing.s2),
                _styledField(
                  controller: _subjectCtrl,
                  hint: l10n.supportTicketSubject,
                  maxLines: 1,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? ' ' : null,
                ),

                const SizedBox(height: AppSpacing.s4),

                // ── Category ───────────────────────────────────────────────
                _FieldLabel(l10n.supportTicketCategory),
                const SizedBox(height: AppSpacing.s2),
                _CategoryPicker(
                  selected: _category,
                  l10n: l10n,
                  onChanged: (c) => setState(() => _category = c),
                ),

                const SizedBox(height: AppSpacing.s4),

                // ── Description ────────────────────────────────────────────
                _FieldLabel(l10n.supportTicketDescription),
                const SizedBox(height: AppSpacing.s2),
                _styledField(
                  controller: _descCtrl,
                  hint: l10n.supportTicketDescHint,
                  maxLines: 6,
                  validator: (v) =>
                      (v == null || v.trim().length < 10) ? ' ' : null,
                ),

                const SizedBox(height: AppSpacing.s6),

                // ── Submit ─────────────────────────────────────────────────
                Semantics(
                  button: true,
                  label: l10n.supportTicketSubmit,
                  child: FilledButton(
                    onPressed: () => _submit(l10n),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      l10n.supportTicketSubmit,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textTertiaryDark,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide:
              BorderSide(color: AppColors.outlineDark.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide:
              BorderSide(color: AppColors.outlineDark.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(
              color: AppColors.statusFaulted.withValues(alpha: 0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: const BorderSide(color: AppColors.statusFaulted),
        ),
        errorStyle: const TextStyle(height: 0),
      ),
    );
  }
}

// ── Category picker ───────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.l10n,
    required this.onChanged,
  });

  final SupportCategory selected;
  final AppLocalizations l10n;
  final ValueChanged<SupportCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s2,
      runSpacing: AppSpacing.s2,
      children: SupportCategory.values.map((cat) {
        final isSelected = cat == selected;
        final label = _catLabel(cat, l10n);
        return Semantics(
          button: true,
          selected: isSelected,
          label: label,
          child: GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceDark,
                borderRadius: AppRadius.rFull,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineDark.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _catLabel(SupportCategory cat, AppLocalizations l10n) => switch (cat) {
        SupportCategory.reservations => l10n.supportCatReservations,
        SupportCategory.charging => l10n.supportCatCharging,
        SupportCategory.wallet => l10n.supportCatWallet,
        SupportCategory.payments => l10n.supportCatPayments,
        SupportCategory.account => l10n.supportCatAccount,
      };
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
