import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_brand.dart';
import '../theme/app_colors.dart';

/// Shell widget with a custom frosted-glass floating bottom navigation bar.
/// The center tab (Scan) is rendered as an elevated glowing button above the bar.
/// Tabs: Home | Reservations | [Scan — elevated] | History | Profile
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final currentIndex = shell.currentIndex;

    final destinations = [
      _NavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.tabMap,
      ),
      _NavDestination(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: l10n.tabReservations,
      ),
      _NavDestination(
        icon: Icons.qr_code_scanner_rounded,
        selectedIcon: Icons.qr_code_scanner_rounded,
        label: l10n.tabScan,
      ),
      _NavDestination(
        icon: Icons.history_outlined,
        selectedIcon: Icons.history_rounded,
        label: l10n.tabHistory,
      ),
      _NavDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: l10n.tabProfile,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: shell),
          Positioned(
            bottom: bottomPadding + 12,
            left: 16,
            right: 16,
            child: _FloatingNavBar(
              destinations: destinations,
              currentIndex: currentIndex,
              onTap: (i) =>
                  shell.goBranch(i, initialLocation: i == currentIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Frosted glass nav bar ─────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.outlineDark.withValues(alpha: 0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (int i = 0; i < destinations.length; i++)
                    if (i == 2)
                      // Center slot — empty placeholder; scan button floats above
                      const Expanded(child: SizedBox())
                    else
                      Expanded(
                        child: _NavButton(
                          destination: destinations[i],
                          isSelected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),

        // ── Elevated center Scan button ───────────────────────────────────
        Positioned(
          top: -28,
          child: _ScanCenterButton(
            isSelected: currentIndex == 2,
            label: destinations[2].label,
            onTap: () => onTap(2),
          ),
        ),
      ],
    );
  }
}

class _ScanCenterButton extends StatelessWidget {
  const _ScanCenterButton({
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing gradient circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppBrand.gradient,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGreen.withValues(
                      alpha: isSelected ? 0.60 : 0.35,
                    ),
                    blurRadius: isSelected ? 32 : 20,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppColors.brandCyan.withValues(alpha: 0.15),
                    blurRadius: 44,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF00210D),
                size: 28,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.brandGreen
                    : AppColors.textTertiaryDark,
                letterSpacing: 0,
              ),
              child: Text(label, maxLines: 1, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.brandGreen;
    final color = isSelected ? activeColor : AppColors.textTertiaryDark;

    return Semantics(
      label: destination.label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 46,
                height: 30,
                decoration: isSelected
                    ? BoxDecoration(
                        color: AppColors.brandGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      )
                    : null,
                child: Icon(
                  isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                  letterSpacing: 0,
                ),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
