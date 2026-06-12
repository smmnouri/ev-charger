import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

const _kOtpLength = 6;
const _kResendSeconds = 60;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(_kOtpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_kOtpLength, (_) => FocusNode());

  bool _loading = false;
  String? _errorText;
  int _resendSecondsLeft = _kResendSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _kOtpLength; i++) {
      final index = i;
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _kResendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendSecondsLeft--;
        if (_resendSecondsLeft <= 0) timer.cancel();
      });
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) return;
    if (index < _kOtpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpValue.length == _kOtpLength) {
      _submit();
    }
  }

  Future<void> _submit() async {
    final otp = _otpValue;
    if (otp.length != _kOtpLength || _loading) return;

    setState(() {
      _errorText = null;
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Mock error path: all zeros
    if (otp == '000000') {
      setState(() {
        _loading = false;
        _errorText = AppLocalizations.of(context).otpInvalidCode;
      });
      for (final c in _controllers) { c.clear(); }
      _focusNodes[0].requestFocus();
      return;
    }

    // Mock success — write tokens then let GoRouter redirect to /map
    final storage = ref.read(secureStorageProvider);
    await storage.writeTokens(
      accessToken: 'mock_access_${widget.phone}',
      refreshToken: 'mock_refresh_${widget.phone}',
    );
    if (!mounted) return;
    ref.read(authNotifierProvider.notifier).setAuthenticated();
  }

  void _resend() {
    if (_resendSecondsLeft > 0 || _loading) return;
    for (final c in _controllers) { c.clear(); }
    setState(() => _errorText = null);
    _focusNodes[0].requestFocus();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s6),

              // Phone number always displayed LTR
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  l10n.otpSubtitle(widget.phone),
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s7),

              // 6 OTP digit boxes — always LTR regardless of locale
              Semantics(
                label: l10n.otpSemanticLabel,
                explicitChildNodes: true,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _kOtpLength; i++) ...[
                        _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          hasError: _errorText != null,
                          enabled: !_loading,
                          onChanged: (v) => _onDigitChanged(i, v),
                        ),
                        if (i < _kOtpLength - 1) const SizedBox(width: AppSpacing.s2),
                      ],
                    ],
                  ),
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.s2),
                Text(
                  _errorText!,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppSpacing.s5),

              Center(
                child: _resendSecondsLeft > 0
                    ? Text(
                        l10n.otpResendIn(_resendSecondsLeft.toString()),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : TextButton(
                        onPressed: _loading ? null : _resend,
                        child: Text(l10n.otpResendCode),
                      ),
              ),

              const Spacer(),

              SizedBox(
                height: AppSpacing.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: (_loading || _otpValue.length != _kOtpLength) ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(l10n.confirm),
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

// ── Single OTP digit box ─────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderColor = hasError ? colorScheme.error : colorScheme.outline;
    final focusedBorderColor = hasError ? colorScheme.error : AppColors.primary;

    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: textTheme.headlineSmall,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.rMd,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.rMd,
            borderSide: BorderSide(color: focusedBorderColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.rMd,
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.38),
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
