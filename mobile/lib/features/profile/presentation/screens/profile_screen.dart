import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_brand.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/persian_number.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../data/mock_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
<<<<<<< HEAD
    final kycStatus = ref.watch(kycStatusProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
=======
    final kycStatus = ref.watch(kycStatusNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final wallet = ref.watch(walletProvider);
>>>>>>> 81c7eb062ad20014d195399c281fe1da9979553a

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Gradient hero user card ────────────────────────────────────
            _HeroUserCard(
              user: kMockUser,
              kycStatus: kycStatus,
              locale: locale.languageCode,
              walletToman: wallet.availableToman,
              l10n: l10n,
            ),

            const SizedBox(height: 20),

            // ── Vehicle card ───────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _VehicleCard(),
            ),

            const SizedBox(height: 20),

            // ── Account ────────────────────────────────────────────────────
            _Section(
              title: l10n.settingsAccount,
              children: [
                _Tile(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.brandGreen,
                  title: l10n.walletTitle,
                  trailing: Text(
                    '${formatToman(wallet.availableToman)} ${l10n.tomansUnit}',
                    style: const TextStyle(
                      color: AppColors.brandGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    style: const TextStyle(
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
                    '۱٫۰٫۰',
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
            ),
          ],
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EvLogo(size: 44),
            const SizedBox(height: 12),
            const Text(
              'EVcharge',
              style: TextStyle(
                color: AppColors.brandGreen,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.settingsAppVersion}: ۱٫۰٫۰',
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

// ── Gradient hero user card ───────────────────────────────────────────────────

class _HeroUserCard extends StatelessWidget {
  const _HeroUserCard({
    required this.user,
    required this.kycStatus,
    required this.locale,
    required this.walletToman,
    required this.l10n,
  });

  final MockUser user;
  final KycStatus kycStatus;
  final String locale;
  final int walletToman;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: Stack(
        children: [
          // Gradient background
          Container(
            height: 200 + topPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandGreen.withValues(alpha: 0.18),
                  AppColors.brandCyan.withValues(alpha: 0.08),
                  AppColors.backgroundDark,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 64, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with gradient border
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        gradient: AppBrand.gradient,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceDark,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: AppColors.brandGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name(locale),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phone,
                            style: const TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _KycChip(status: kycStatus, l10n: l10n),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Wallet balance card
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed('/wallet')
                      .catchError((_) => null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandGreen.withValues(alpha: 0.15),
                          AppColors.brandCyan.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.brandGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppBrand.gradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Color(0xFF00210D),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.walletTitle,
                              style: const TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${formatToman(walletToman)} ${l10n.tomansUnit}',
                              style: const TextStyle(
                                color: AppColors.brandGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.brandGreen.withValues(alpha: 0.7),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vehicle card ──────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard();

  @override
  Widget build(BuildContext context) {
    const batteryPct = 78;
    const batteryColor = AppColors.brandGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppBrand.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.electric_car_rounded,
                  color: Color(0xFF00210D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسلا مدل ۳',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Tesla Model 3 Long Range',
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Battery percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: batteryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: batteryColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.battery_charging_full_rounded,
                        size: 14, color: batteryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${persianInt(batteryPct)}٪',
                      style: TextStyle(
                        color: batteryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Battery progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: batteryPct / 100,
              backgroundColor: AppColors.outlineDark.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(batteryColor),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _VehicleStat(
                icon: Icons.route_rounded,
                label: 'برد تخمینی',
                value: '${persianInt(382)} کیلومتر',
              ),
              const SizedBox(width: 16),
              _VehicleStat(
                icon: Icons.electric_bolt_rounded,
                label: 'کانکتور',
                value: 'Type 2 / CCS',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleStat extends StatelessWidget {
  const _VehicleStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiaryDark),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
          AppColors.brandGreen,
          Icons.verified_rounded,
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
            padding: const EdgeInsetsDirectional.only(
              bottom: 8,
              start: 4,
              end: 4,
            ),
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
    this.iconColor,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final Color? iconColor;
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
                    bottom: Radius.circular(AppRadius.lg),
                  )
                : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? AppColors.textSecondaryDark,
                  ),
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
