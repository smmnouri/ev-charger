import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider);

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
          l10n.settingsLanguage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppRadius.rLg,
              border: Border.all(
                color: AppColors.outlineDark.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangTile(
                  title: l10n.languagePersian,
                  native: 'فارسی',
                  selected: current.languageCode == 'fa',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('fa')),
                ),
                Divider(
                  height: 1,
                  color: AppColors.outlineDark.withValues(alpha: 0.4),
                ),
                _LangTile(
                  title: l10n.languageEnglish,
                  native: 'English',
                  selected: current.languageCode == 'en',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en')),
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.title,
    required this.native,
    required this.selected,
    required this.onTap,
    this.isLast = false,
  });

  final String title;
  final String native;
  final bool selected;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: '$title — $native',
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      native,
                      style: TextStyle(
                        color: selected ? AppColors.primary : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded,
                    size: 20, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
