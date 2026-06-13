import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/wallet_provider.dart';

const _presets = [100000, 200000, 500000, 1000000];

class TopupScreen extends ConsumerStatefulWidget {
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  int? _selectedPreset;
  final _customCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  int? get _effectiveAmount {
    if (_selectedPreset != null) return _selectedPreset;
    final raw = _customCtrl.text.replaceAll(',', '').trim();
    return int.tryParse(raw);
  }

  bool get _canConfirm {
    final amt = _effectiveAmount;
    return amt != null && amt >= 10000;
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.walletTopUpTitle,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s5),

                // ── Select amount label ──────────────────────────────────
                Text(
                  l10n.walletTopUpSelectAmount,
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: AppSpacing.s3),

                // ── Preset grid ──────────────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.s3,
                  mainAxisSpacing: AppSpacing.s3,
                  childAspectRatio: 2.6,
                  children: _presets
                      .map((amt) => _PresetTile(
                            amount: amt,
                            l10n: l10n,
                            selected: _selectedPreset == amt,
                            onTap: () => setState(() {
                              _selectedPreset = amt;
                              _customCtrl.clear();
                            }),
                          ))
                      .toList(),
                ),

                const SizedBox(height: AppSpacing.s5),

                // ── Custom amount ────────────────────────────────────────
                Text(
                  l10n.walletTopUpCustom,
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: AppSpacing.s3),

                TextFormField(
                  controller: _customCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorFormatter(),
                  ],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.walletTopUpEnterAmount,
                    hintStyle: const TextStyle(
                        color: AppColors.textTertiaryDark, fontSize: 14),
                    suffixText: l10n.tomansUnit,
                    suffixStyle: const TextStyle(
                        color: AppColors.textSecondaryDark, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                          color: AppColors.outlineDark.withValues(alpha: 0.4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                          color: AppColors.outlineDark.withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() => _selectedPreset = null),
                ),

                const Spacer(),

                // ── Confirm button ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: _canConfirm ? () => _confirm(context, l10n) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.surfaceDark.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.textTertiaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      l10n.walletTopUpConfirm,
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
      ),
    );
  }

  void _confirm(BuildContext context, AppLocalizations l10n) {
    final amount = _effectiveAmount;
    if (amount == null) return;

    ref.read(walletProvider.notifier).topUp(amount);

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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.secondary, size: 36),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.walletTopUpSuccess,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.walletTopUpSuccessBody(
                  NumberFormat('#,###', 'en').format(amount)),
              style: const TextStyle(
                  color: AppColors.textSecondaryDark, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
}

// ── Preset tile ───────────────────────────────────────────────────────────────

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.amount,
    required this.l10n,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final AppLocalizations l10n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: '${NumberFormat('#,###', 'en').format(amount)} ${l10n.tomansUnit}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outlineDark.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                NumberFormat('#,###', 'en').format(amount),
                style: TextStyle(
                  color: selected ? AppColors.primary : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.tomansUnit,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : AppColors.textTertiaryDark,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Thousands separator formatter ─────────────────────────────────────────────

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final number = int.tryParse(digits);
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###', 'en').format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
