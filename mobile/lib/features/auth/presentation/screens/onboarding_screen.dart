import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              Center(
                child: Semantics(
                  label: l10n.appName,
                  child: _LogoContainer(size: 96),
                ),
              ),

              const SizedBox(height: AppSpacing.s7),

              Text(
                l10n.welcomeTitle,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.s3),

              Text(
                l10n.welcomeBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              SizedBox(
                height: AppSpacing.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.login),
                  child: Text(l10n.welcomeGetStarted),
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
        child: Icon(Icons.bolt, color: Colors.white, size: 56),
      ),
    );
  }
}
