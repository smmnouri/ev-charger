import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_brand.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                  child: const EvBrandLockup(logoSize: 100, showTagline: true),
                ),
              ),

              const SizedBox(height: AppSpacing.s8),

              Text(
                l10n.welcomeTitle,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.s3),

              Text(
                l10n.welcomeBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Brand gradient CTA button
              Container(
                height: AppSpacing.buttonHeightLarge,
                decoration: BoxDecoration(
                  gradient: AppBrand.gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandGreen.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.push(AppRoutes.login),
                    child: Center(
                      child: Text(
                        l10n.welcomeGetStarted,
                        style: const TextStyle(
                          color: Color(0xFF00210D),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
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
