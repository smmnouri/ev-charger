import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final kycStatus = ref.watch(kycStatusProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    final themeName = switch (themeMode) {
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.system => l10n.themeSystem,
    };

    final langName = locale.languageCode == 'fa'
        ? l10n.languagePersian
        : l10n.languageEnglish;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── User Card ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _UserCard(
                  user: kMockUser,
                  kycStatus: kycStatus,
                  locale: locale.languageCode,
                  l10n: l10n,
                ),
              ),

              const SizedBox(height: 24),

              // ── Account ────────────────────────────────────────────────────
              _Section(
                title: l10n.settingsAccount,
                children: [
                  _Tile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.walletTitle,
                    onTap: () => context.push('/wallet'),
                  ),
                  _Tile(
                    icon: Icons.person_outline_rounded,
                    title: l10n.settingsPersonalInfo,
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _Tile(
                    icon: Icons.verified_user_outlined,
                    title: l10n.profileKycNotStarted,
                    trailing: _KycChip(status: kycStatus, l10n: l10n),
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

              // ── Preferences ────────────────────────────────────────────────
              _Section(
                title: l10n.settingsPreferences,
                children: [
                  _Tile(
                    icon: Icons.language_rounded,
                    title: l10n.settingsLanguage,
                    trailing: Text(
                      langName,
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => context.push('/settings/language'),
                  ),
                  _Tile(
                    icon: Icons.palette_outlined,
                    title: l10n.settingsAppearance,
                    trailing: Text(
                      themeName,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => context.push('/settings/appearance'),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Notifications ──────────────────────────────────────────────
              _Section(
                title: l10n.settingsNotifications,
                children: [
                  _Tile(
                    icon: Icons.notifications_outlined,
                    title: l10n.settingsNotifications,
                    onTap: () => context.push('/settings/notifications'),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Support ────────────────────────────────────────────────────
              _Section(
                title: l10n.settingsSupportSection,
                children: [
                  _Tile(
                    icon: Icons.help_outline_rounded,
                    title: l10n.settingsFaq,
                    onTap: () => context.push('/support/faq'),
                  ),
                  _Tile(
                    icon: Icons.headset_mic_outlined,
                    title: l10n.settingsContactSupport,
                    onTap: () => context.push('/support'),
                  ),
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.settingsAboutApp,
                    trailing: Text(
                      '1.0.0',
                      style: const TextStyle(
                        color: AppColors.textTertiaryDark,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => _showAbout(context, l10n),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Logout ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Semantics(
                  button: true,
                  label: l10n.profileSignOut,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showLogoutDialog(context, ref, l10n),
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

  void _showAbout(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: Text(
          l10n.settingsAboutApp,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.settingsAppVersion}: 1.0.0',
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.kycStatus,
    required this.locale,
    required this.l10n,
  });

  final MockUser user;
  final KycStatus kycStatus;
  final String locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Avatar
          Semantics(
            label: user.name(locale),
            child: Container(
              width: AppSpacing.avatarSize,
              height: AppSpacing.avatarSize,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.tertiary],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name, phone, KYC
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name(locale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.phone,
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _KycChip(status: kycStatus, l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── KYC status chip ───────────────────────────────────────────────────────────

class _KycChip extends StatelessWidget {
  const _KycChip({required this.status, required this.l10n});

  final KycStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      KycStatus.approved => (
          l10n.profileKycVerified,
          AppColors.statusAvailable,
          Icons.check_circle_rounded,
        ),
      KycStatus.pending => (
          l10n.profileKycPending,
          AppColors.warning,
          Icons.hourglass_empty_rounded,
        ),
      KycStatus.rejected => (
          l10n.profileKycRejected,
          AppColors.statusFaulted,
          Icons.cancel_rounded,
        ),
      KycStatus.notStarted => (
          l10n.profileKycNotStarted,
          AppColors.textSecondaryDark,
          Icons.shield_outlined,
        ),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.rFull,
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings section container ────────────────────────────────────────────────

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

// ── Settings tile ─────────────────────────────────────────────────────────────

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
                ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg))
                : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.textSecondaryDark),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
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
