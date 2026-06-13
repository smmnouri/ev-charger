import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_support.dart';
import '../providers/support_provider.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    ref.read(faqSearchProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(faqSearchProvider);
    final categories = ref.watch(filteredFaqProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.supportFaqTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.s2,
                AppSpacing.screenHorizontal,
                AppSpacing.s3,
              ),
              child: Semantics(
                label: l10n.supportFaqSearch,
                textField: true,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      ref.read(faqSearchProvider.notifier).setQuery(v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.supportFaqSearch,
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiaryDark,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textTertiaryDark, size: 20),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textTertiaryDark),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(faqSearchProvider.notifier).clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.rMd,
                      borderSide: BorderSide(
                          color: AppColors.outlineDark.withValues(alpha: 0.4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.rMd,
                      borderSide: BorderSide(
                          color: AppColors.outlineDark.withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.rMd,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),

            // ── Results ────────────────────────────────────────────────────
            Expanded(
              child: categories.isEmpty
                  ? _EmptySearch(query: query, l10n: l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.s8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                        child: _CategoryCard(
                          faqCategory: categories[i],
                          l10n: l10n,
                          expandAll: query.isNotEmpty,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category card (expandable) ────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.faqCategory,
    required this.l10n,
    required this.expandAll,
  });

  final FaqCategory faqCategory;
  final AppLocalizations l10n;
  final bool expandAll;

  @override
  Widget build(BuildContext context) {
    final (catLabel, catIcon) = _categoryStyle(faqCategory.category, l10n);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: expandAll,
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(catIcon, size: 18, color: AppColors.primary),
          ),
          title: Text(
            catLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${faqCategory.items.length}',
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded,
                  color: AppColors.textTertiaryDark, size: 20),
            ],
          ),
          children: [
            Divider(
              height: 1,
              color: AppColors.outlineDark.withValues(alpha: 0.4),
            ),
            for (var i = 0; i < faqCategory.items.length; i++)
              _FaqItemTile(
                item: faqCategory.items[i],
                isLast: i == faqCategory.items.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ item tile (expandable answer) ─────────────────────────────────────────

class _FaqItemTile extends StatelessWidget {
  const _FaqItemTile({required this.item, required this.isLast});

  final FaqItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(
              item.question,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.add_rounded,
              color: AppColors.textTertiaryDark,
              size: 18,
            ),
            children: [
              Text(
                item.answer,
                style: const TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            color: AppColors.outlineDark.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

// ── Empty search result ───────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query, required this.l10n});

  final String query;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.supportFaqEmpty(query),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

(String, IconData) _categoryStyle(
  SupportCategory cat,
  AppLocalizations l10n,
) =>
    switch (cat) {
      SupportCategory.reservations =>
        (l10n.supportCatReservations, Icons.event_available_rounded),
      SupportCategory.charging =>
        (l10n.supportCatCharging, Icons.bolt_rounded),
      SupportCategory.wallet =>
        (l10n.supportCatWallet, Icons.account_balance_wallet_outlined),
      SupportCategory.payments =>
        (l10n.supportCatPayments, Icons.payment_rounded),
      SupportCategory.account =>
        (l10n.supportCatAccount, Icons.person_outline_rounded),
    };
