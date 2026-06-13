import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              const Spacer(),
              Semantics(
                label: l10n.appName,
                child: _LogoContainer(size: 88),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                l10n.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s7),
                child: Semantics(
                  label: l10n.loading,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoContainer extends StatelessWidget {
  const _LogoContainer({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.tertiary],
        ),
        borderRadius: AppRadius.rXl,
      ),
      child: const ExcludeSemantics(
        child: Icon(Icons.bolt, color: Colors.white, size: 48),
      ),
    );
  }
}
