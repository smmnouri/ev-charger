import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Shell widget with a custom frosted-glass floating bottom navigation bar.
/// Tabs: Home | Reservations | Scan | History | Profile
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final destinations = [
      _NavDestination(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: l10n.tabMap),
      _NavDestination(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded, label: l10n.tabReservations),
      _NavDestination(icon: Icons.qr_code_scanner_rounded, selectedIcon: Icons.qr_code_scanner_rounded, label: l10n.tabScan),
      _NavDestination(icon: Icons.history_rounded, selectedIcon: Icons.history_rounded, label: l10n.tabHistory),
      _NavDestination(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: l10n.tabProfile),
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
              currentIndex: shell.currentIndex,
              onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({required this.icon, required this.selectedIcon, required this.label});
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.outlineDark.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < destinations.length; i++)
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
    final color = isSelected ? AppColors.primary : AppColors.textTertiaryDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 42,
              height: 28,
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              child: Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
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
    );
  }
}
