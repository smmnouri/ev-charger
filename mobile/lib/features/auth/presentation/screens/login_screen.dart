import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

// ── Country data ────────────────────────────────────────────────────────────

class _Country {
  const _Country({
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.maxDigits,
  });

  final String code;
  final String dialCode;
  final String flag;
  final int maxDigits;
}

const _kCountries = [
  _Country(code: 'IR', dialCode: '+98', flag: '🇮🇷', maxDigits: 10),
  _Country(code: 'DE', dialCode: '+49', flag: '🇩🇪', maxDigits: 12),
];

// ── Screen ──────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _Country _country = _kCountries[0]; // Iran default — primary market
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  String? _validate(AppLocalizations l10n) {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return l10n.loginInvalidPhone;
    if (_country.code == 'IR' && digits.length != 10) return l10n.loginInvalidPhone;
    if (_country.code == 'DE' && (digits.length < 10 || digits.length > 12)) {
      return l10n.loginInvalidPhone;
    }
    return null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit(AppLocalizations l10n) async {
    final error = _validate(l10n);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    setState(() {
      _errorText = null;
      _loading = true;
    });

    // Mock: simulate network round-trip
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    // Mock error: all zeros triggers failure (test path)
    if (digits == '0' * _country.maxDigits) {
      setState(() {
        _loading = false;
        _errorText = l10n.errorGeneric;
      });
      return;
    }

    setState(() => _loading = false);

    final phone = '${_country.dialCode}$digits';
    if (!mounted) return;
    context.push('${AppRoutes.onboardingVerify}?phone=${Uri.encodeComponent(phone)}');
  }

  // ── Country picker ─────────────────────────────────────────────────────────

  void _openCountryPicker(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => _CountryPicker(
        selected: _country,
        onSelect: (country) {
          setState(() {
            _country = country;
            _phoneController.clear();
            _errorText = null;
          });
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s6),

              Text(
                l10n.loginSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.s6),

              // Phone input row — forced LTR: phone numbers are never RTL
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CountryCodeButton(
                      country: _country,
                      enabled: !_loading,
                      hasError: _errorText != null,
                      onTap: () => _openCountryPicker(l10n),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        enabled: !_loading,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_country.maxDigits),
                        ],
                        decoration: InputDecoration(
                          hintText: l10n.loginPhoneHint,
                          errorText: _errorText,
                        ),
                        onChanged: (_) {
                          if (_errorText != null) setState(() => _errorText = null);
                        },
                        onFieldSubmitted: (_) => _submit(l10n),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue button — keeps primary style during loading
              SizedBox(
                height: AppSpacing.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _loading ? () {} : () => _submit(l10n),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(l10n.continue_),
                ),
              ),

              const SizedBox(height: AppSpacing.s7),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Country code button ──────────────────────────────────────────────────────

class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({
    required this.country,
    required this.enabled,
    required this.hasError,
    required this.onTap,
  });

  final _Country country;
  final bool enabled;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Mirror InputDecorationTheme: outline → error color when invalid
    final borderColor = hasError ? AppColors.error : colorScheme.outline;
    final borderWidth = hasError ? 1.0 : 1.0;
    final contentColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    return Semantics(
      label: '${country.flag} ${country.dialCode}',
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppRadius.rMd,
        child: Container(
          // Match InputDecoration contentPadding vertical:14 + bodyLarge height
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rMd,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Text(country.flag, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                country.dialCode,
                style: textTheme.bodyLarge?.copyWith(color: contentColor),
              ),
              const SizedBox(width: AppSpacing.s1),
              Icon(Icons.expand_more, size: AppSpacing.iconSize, color: contentColor),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Country picker bottom sheet ──────────────────────────────────────────────

class _CountryPicker extends StatelessWidget {
  const _CountryPicker({required this.selected, required this.onSelect});

  final _Country selected;
  final ValueChanged<_Country> onSelect;

  String _name(_Country c, AppLocalizations l10n) => switch (c.code) {
        'IR' => l10n.loginCountryIran,
        'DE' => l10n.loginCountryGermany,
        _ => c.code,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s2, // drag handle above provides visual top space
              AppSpacing.s4,
              AppSpacing.s2,
            ),
            child: Text(l10n.loginSelectCountry, style: textTheme.titleMedium),
          ),
          const Divider(height: 1),
          for (final country in _kCountries)
            ListTile(
              leading: ExcludeSemantics(
                child: Text(country.flag, style: const TextStyle(fontSize: 24)),
              ),
              title: Text(_name(country, l10n)),
              subtitle: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(country.dialCode),
              ),
              trailing: country.code == selected.code
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                onSelect(country);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: AppSpacing.s2),
        ],
      ),
    );
  }
}
