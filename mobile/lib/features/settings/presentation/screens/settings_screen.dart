import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          l10n.settingsTitle,
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
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Account ──────────────────────────────────────────────────
              _Section(
                title: l10n.settingsAccount,
                children: [
                  _Tile(
                    icon: Icons.person_outline_rounded,
                    title: l10n.settingsPersonalInfo,
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _Tile(
                    icon: Icons.verified_user_outlined,
                    title: l10n.profileKycNotStarted,
                    onTap: () => context.push('/profile/kyc/status'),
                  ),
                  _Tile(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.profileAccountSecurity,
                    onTap: () => context.push('/profile/security'),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Support ──────────────────────────────────────────────────
              _Section(
                title: l10n.settingsSupportSection,
                children: [
                  _Tile(
                    icon: Icons.help_outline_rounded,
                    title: l10n.settingsFaq,
                    onTap: () {},
                  ),
                  _Tile(
                    icon: Icons.headset_mic_outlined,
                    title: l10n.settingsContactSupport,
                    onTap: () {},
                  ),
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.settingsAboutApp,
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(
                        color: AppColors.textTertiaryDark,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {},
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Logout ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref, l10n),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(l10n.profileSignOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusFaulted,
                    side: BorderSide(
                      color: AppColors.statusFaulted.withValues(alpha: 0.5),
                    ),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: Text(
          l10n.profileSignOutConfirm,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.profileSignOutBody,
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).setUnauthenticated();
            },
            child: Text(
              l10n.profileSignOut,
              style: const TextStyle(color: AppColors.statusFaulted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppRadius.rLg,
              border: Border.all(
                color: AppColors.outlineDark.withValues(alpha: 0.4),
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: onTap != null,
          label: title,
          child: InkWell(
            onTap: onTap,
            borderRadius: isLast
                ? const BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg))
                : BorderRadius.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.textSecondaryDark),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textTertiaryDark,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 50,
            color: AppColors.outlineDark.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}
