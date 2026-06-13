import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_station_repository.dart';
import '../providers/map_screen_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final DraggableScrollableController _sheetController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;

  bool _isLoadingSheet = false;

  static const _kPeekSize = 0.30;
  static const _kExpandedSize = 0.65;
  static const _kDismissThreshold = 0.05;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    if (!_sheetController.isAttached) return;
    if (_sheetController.size < _kDismissThreshold) {
      final notifier = ref.read(mapScreenProvider.notifier);
      if (ref.read(mapScreenProvider).selectedStationId != null) {
        notifier.selectStation(null);
      }
    }
  }

  void _selectStation(String id) {
    ref.read(mapScreenProvider.notifier).selectStation(id);
    setState(() => _isLoadingSheet = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          _kPeekSize,
          duration: const Duration(milliseconds: 280),
          curve: const Cubic(0.4, 0, 0.2, 1),
        );
      }
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _isLoadingSheet = false);
    });
  }

  void _expandSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        _kExpandedSize,
        duration: const Duration(milliseconds: 280),
        curve: const Cubic(0.4, 0, 0.2, 1),
      );
    }
  }

  void _dismissSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: const Cubic(0.0, 0, 0.2, 1),
      );
    }
    ref.read(mapScreenProvider.notifier).selectStation(null);
  }

  void _onSearchTap() {
    ref.read(mapScreenProvider.notifier).setSearchActive(true);
    _searchFocus.requestFocus();
  }

  void _dismissSearch() {
    ref.read(mapScreenProvider.notifier).setSearchActive(false);
    _searchController.clear();
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapScreenProvider);
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    const navBarHeight = 64.0 + 12.0 + 12.0;

    final allStations = MockStationRepository.stations;
    final selectedStation = MockStationRepository.findById(mapState.selectedStationId);

    final searchResults = mapState.isSearchActive
        ? allStations.where((s) => s.matchesSearch(mapState.searchQuery)).toList()
        : const <MockStation>[];

    final allFiltered = mapState.activeFilters.isNotEmpty &&
        allStations.every((s) => !s.matchesFilter(mapState.activeFilters));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBody: true,
      body: Stack(
        children: [
          // ── Layer 0: Mock map ───────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/mock_map.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, e) => Container(color: AppColors.backgroundDark),
            ),
          ),

          // ── Layer 1: Top gradient ───────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0.95),
                    AppColors.backgroundDark.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 2: Bottom gradient ────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0, height: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0.95),
                    AppColors.backgroundDark.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 3: Station pins ───────────────────────────────────────────
          for (final station in allStations)
            _buildPin(station, mapState, size),

          // ── Layer 4: Empty state (all filtered out) ─────────────────────────
          if (allFiltered && !mapState.isSearchActive)
            Positioned(
              top: size.height * 0.44,
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.97),
                    borderRadius: AppRadius.rFull,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeNoStationsArea,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => ref.read(mapScreenProvider.notifier).clearFilters(),
                        child: Text(
                          l10n.homeClearFilters,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Layer 5: Search scrim ───────────────────────────────────────────
          if (mapState.isSearchActive)
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissSearch,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),

          // ── Layer 6: Top overlay ────────────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            child: _TopOverlay(
              mapState: mapState,
              searchController: _searchController,
              searchFocus: _searchFocus,
              onSearchTap: _onSearchTap,
              onSearchChanged: (q) => ref.read(mapScreenProvider.notifier).setSearchQuery(q),
              onSearchClear: _dismissSearch,
              onFilterToggle: (f) => ref.read(mapScreenProvider.notifier).toggleFilter(f),
              onClearFilters: () => ref.read(mapScreenProvider.notifier).clearFilters(),
            ),
          ),

          // ── Layer 7: Search results panel ───────────────────────────────────
          if (mapState.isSearchActive)
            Positioned(
              top: topPadding + 8 + 52 + 12,
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              child: _SearchResultsPanel(
                query: mapState.searchQuery,
                results: searchResults,
                allStations: allStations,
                onStationTap: (s) {
                  _dismissSearch();
                  _selectStation(s.id);
                },
              ),
            ),

          // ── Layer 8: Location FAB ───────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: size.height * 0.38 + 8,
            child: _LocationFab(),
          ),

          // ── Layer 9: Station bottom sheet ───────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0,
            minChildSize: 0,
            maxChildSize: _kExpandedSize,
            snap: true,
            snapSizes: const [0.0, _kPeekSize, _kExpandedSize],
            builder: (ctx, scrollController) {
              if (selectedStation == null) return const SizedBox.shrink();
              return _StationBottomSheet(
                station: selectedStation,
                scrollController: scrollController,
                sheetController: _sheetController,
                navBarHeight: navBarHeight,
                isLoading: _isLoadingSheet,
                onExpand: _expandSheet,
                onDismiss: _dismissSheet,
                onReserve: (connectorId) => context.push(
                  '/reservations/create/${selectedStation.id}?connectorId=$connectorId',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPin(MockStation station, MapScreenState state, Size size) {
    final isSelected = station.id == state.selectedStationId;
    final isFilteredOut = state.activeFilters.isNotEmpty && !station.matchesFilter(state.activeFilters);
    final isDeemphasized = state.selectedStationId != null && !isSelected;

    double opacity;
    if (isFilteredOut) {
      opacity = 0.2;
    } else if (isDeemphasized) {
      opacity = 0.55;
    } else {
      opacity = 1.0;
    }

    final pinBodySize = isSelected ? 44.0 : 36.0;
    final left = station.pinX * size.width - pinBodySize / 2;
    final top = station.pinY * size.height - pinBodySize - 8.0;

    return Positioned(
      left: left,
      top: top,
      child: Semantics(
        label: '${station.name}. ${station.availableCount} از ${station.totalCount} پریز آزاد. ${station.distanceFa}.',
        hint: 'دوبار ضربه بزنید برای مشاهده جزئیات',
        button: true,
        enabled: !isFilteredOut,
        child: GestureDetector(
          onTap: isFilteredOut ? null : () => _selectStation(station.id),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: opacity,
            child: _StationPin(
              color: station.pinColor,
              bodySize: pinBodySize,
              isSelected: isSelected,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Station pin
// ─────────────────────────────────────────────────────────────────────────────

class _StationPin extends StatelessWidget {
  const _StationPin({required this.color, required this.bodySize, required this.isSelected});

  final Color color;
  final double bodySize;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final borderWidth = isSelected ? 2.0 : 1.5;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: bodySize,
          height: bodySize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(bodySize * 0.30),
            border: Border.all(color: Colors.white, width: borderWidth),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4)),
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 14, spreadRadius: -3),
            ],
          ),
          child: Icon(Icons.bolt_rounded, color: Colors.white, size: bodySize * 0.50),
        ),
        CustomPaint(
          size: const Size(10, 7),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Top overlay: greeting + search + filters
// ─────────────────────────────────────────────────────────────────────────────

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({
    required this.mapState,
    required this.searchController,
    required this.searchFocus,
    required this.onSearchTap,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onFilterToggle,
    required this.onClearFilters,
  });

  final MapScreenState mapState;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final VoidCallback onSearchTap;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<StationFilterType> onFilterToggle;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final isSearching = mapState.isSearchActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: isSearching ? const SizedBox.shrink() : _GreetingRow(),
        ),
        if (!isSearching) const SizedBox(height: 10),
        _SearchBarWidget(
          controller: searchController,
          focusNode: searchFocus,
          isActive: isSearching,
          onTap: onSearchTap,
          onChanged: onSearchChanged,
          onClear: onSearchClear,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: isSearching
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _FilterChipsRow(
                    activeFilters: mapState.activeFilters,
                    onToggle: onFilterToggle,
                    onClearAll: onClearFilters,
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting row
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('سلام!', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('کجا می‌خواهید شارژ کنید؟', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark)),
            ],
          ),
        ),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.6)),
          ),
          child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimaryDark, size: 20),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBarWidget extends StatelessWidget {
  const _SearchBarWidget({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onTap,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.homeSearchHint,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.92),
          borderRadius: AppRadius.rFull,
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.outlineDark.withValues(alpha: 0.5),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.search_rounded,
                color: isActive ? AppColors.primary : AppColors.textTertiaryDark,
                size: 20,
              ),
            ),
            Expanded(
              child: isActive
                  ? TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimaryDark),
                      cursorColor: AppColors.primary,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.homeSearchHint,
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiaryDark),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : GestureDetector(
                      onTap: onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        l10n.homeSearchHint,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiaryDark),
                      ),
                    ),
            ),
            if (isActive)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(Icons.close_rounded, color: AppColors.textSecondaryDark, size: 18),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 17),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chips row
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({required this.activeFilters, required this.onToggle, required this.onClearAll});

  final Set<StationFilterType> activeFilters;
  final ValueChanged<StationFilterType> onToggle;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = [
      (StationFilterType.nearby, l10n.homeFilterNearby),
      (StationFilterType.available, l10n.homeFilterAvailable),
      (StationFilterType.type2, l10n.homeFilterType2),
      (StationFilterType.ccs, l10n.homeFilterCCS),
      (StationFilterType.chademo, l10n.homeFilterCHAdeMO),
      (StationFilterType.gbt, l10n.homeFilterGBT),
      (StationFilterType.dc, l10n.homeFilterDC),
      (StationFilterType.ac, l10n.homeFilterAC),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: activeFilters.isNotEmpty ? chips.length + 1 : chips.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          if (activeFilters.isNotEmpty && i == chips.length) {
            return _ClearFilterChip(count: activeFilters.length, onTap: onClearAll);
          }
          final (type, label) = chips[i];
          return _FilterChipItem(
            label: label,
            isActive: activeFilters.contains(type),
            onTap: () => onToggle(type),
          );
        },
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label فیلتر',
      selected: isActive,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withValues(alpha: 0.18) : AppColors.surfaceDark.withValues(alpha: 0.9),
            borderRadius: AppRadius.rFull,
            border: Border.all(
              color: isActive ? AppColors.primary.withValues(alpha: 0.7) : AppColors.outlineDark.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearFilterChip extends StatelessWidget {
  const _ClearFilterChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.rFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.homeActiveFiltersCount(count),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close_rounded, size: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search results panel
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultsPanel extends StatelessWidget {
  const _SearchResultsPanel({
    required this.query,
    required this.results,
    required this.allStations,
    required this.onStationTap,
  });

  final String query;
  final List<MockStation> results;
  final List<MockStation> allStations;
  final ValueChanged<MockStation> onStationTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showRecent = query.isEmpty;
    final items = showRecent ? allStations.take(5).toList() : results;
    final sectionLabel = showRecent ? l10n.homeSearchNearby : null;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 340),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.rLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sectionLabel != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Text(sectionLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiaryDark)),
                ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_outlined, size: 36, color: AppColors.textTertiaryDark.withValues(alpha: 0.5)),
                      const SizedBox(height: 10),
                      Text(
                        l10n.homeNoStationsFilter,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiaryDark),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, i) => Divider(height: 1, color: AppColors.outlineDark.withValues(alpha: 0.4)),
                    itemBuilder: (ctx, i) => _SearchResultItem(station: items[i], onTap: () => onStationTap(items[i])),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.station, required this.onTap});

  final MockStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: station.pinColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt_rounded, color: station.pinColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(station.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(station.address, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(station.distanceFa, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location FAB
// ─────────────────────────────────────────────────────────────────────────────

class _LocationFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'موقعیت من',
      button: true,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Station bottom sheet (peek ↔ expanded)
// ─────────────────────────────────────────────────────────────────────────────

class _StationBottomSheet extends StatelessWidget {
  const _StationBottomSheet({
    required this.station,
    required this.scrollController,
    required this.sheetController,
    required this.navBarHeight,
    required this.isLoading,
    required this.onExpand,
    required this.onDismiss,
    required this.onReserve,
  });

  final MockStation station;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final double navBarHeight;
  final bool isLoading;
  final VoidCallback onExpand;
  final VoidCallback onDismiss;
  final ValueChanged<String> onReserve;

  static const _expandThreshold = 0.45;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sheetController,
      builder: (ctx, _) {
        final currentSize = sheetController.isAttached ? sheetController.size : 0.0;
        final isExpanded = currentSize > _expandThreshold;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 32, offset: const Offset(0, -8))],
          ),
          child: Column(
            children: [
              // Handle
              GestureDetector(
                onTap: isExpanded ? onDismiss : onExpand,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(color: AppColors.outlineDark, borderRadius: AppRadius.rFull),
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: (isLoading && !isExpanded)
                      ? const _SkeletonPeekContent(key: ValueKey('skeleton'))
                      : isExpanded
                          ? _ExpandedContent(
                              key: const ValueKey('expanded'),
                              station: station,
                              scrollController: scrollController,
                              navBarHeight: navBarHeight,
                              onDismiss: onDismiss,
                              onReserve: onReserve,
                            )
                          : _PeekContent(
                              key: const ValueKey('peek'),
                              station: station,
                              onViewStation: onExpand,
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton loader (peek state)
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonPeekContent extends StatelessWidget {
  const _SkeletonPeekContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _ShimmerBox(width: 180, height: 18),
              const Spacer(),
              const _ShimmerBox(width: 70, height: 14),
            ],
          ),
          const SizedBox(height: 10),
          const _ShimmerBox(width: 130, height: 14),
          const SizedBox(height: 12),
          Row(
            children: const [
              _ShimmerBox(width: 64, height: 26, radius: 13),
              SizedBox(width: 8),
              _ShimmerBox(width: 56, height: 26, radius: 13),
              SizedBox(width: 8),
              _ShimmerBox(width: 72, height: 26, radius: 13),
            ],
          ),
          const SizedBox(height: 16),
          const _ShimmerBox(width: double.infinity, height: 48, radius: 12),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({required this.width, required this.height, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.18, end: 0.45).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: widget.width == double.infinity ? null : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.outlineDark.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Peek content
// ─────────────────────────────────────────────────────────────────────────────

class _PeekContent extends StatelessWidget {
  const _PeekContent({super.key, required this.station, required this.onViewStation});

  final MockStation station;
  final VoidCallback onViewStation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = station.availableCount;
    final total = station.totalCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: name + distance
          Row(
            children: [
              Expanded(
                child: Text(
                  station.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textTertiaryDark),
                  const SizedBox(width: 3),
                  Text(station.distanceFa, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondaryDark)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: availability summary
          Row(
            children: [
              Icon(
                Icons.electric_bolt_rounded,
                size: 14,
                color: station.overallStatus == ConnectorStatus.available ? AppColors.statusAvailable : AppColors.statusOccupied,
              ),
              const SizedBox(width: 4),
              Text(
                available == 0
                    ? l10n.homeAllBusy
                    : '$available از $total پریز آزاد',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: available == 0 ? AppColors.statusOccupied : AppColors.textSecondaryDark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: connector chips + price
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final c in _uniqueConnectorChips(station))
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _ConnectorTypeChip(connector: c),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'از ${_formatPrice(station.minPricePerKwh)} تومان',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiaryDark),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // CTA
          FilledButton(
            onPressed: onViewStation,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(l10n.homeViewStation),
          ),
        ],
      ),
    );
  }

  List<MockConnector> _uniqueConnectorChips(MockStation s) {
    final seen = <ConnectorType>{};
    final result = <MockConnector>[];
    for (final c in s.connectors.where((c) => c.status == ConnectorStatus.available)) {
      if (seen.add(c.type)) result.add(c);
    }
    for (final c in s.connectors.where((c) => c.status != ConnectorStatus.available)) {
      if (seen.add(c.type)) result.add(c);
    }
    return result;
  }
}

class _ConnectorTypeChip extends StatelessWidget {
  const _ConnectorTypeChip({required this.connector});
  final MockConnector connector;

  @override
  Widget build(BuildContext context) {
    final color = connector.statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.rFull,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.electric_bolt_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(connector.typeLabelShort, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expanded content
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    super.key,
    required this.station,
    required this.scrollController,
    required this.navBarHeight,
    required this.onDismiss,
    required this.onReserve,
  });

  final MockStation station;
  final ScrollController scrollController;
  final double navBarHeight;
  final VoidCallback onDismiss;
  final ValueChanged<String> onReserve;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: navBarHeight + 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name + navigate
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconButton(icon: Icons.directions_rounded, label: station.distanceFa, onTap: () {}),
                ],
              ),
              const SizedBox(height: 4),
              // Operator + category
              Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.electric_bolt_rounded, size: 11, color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Text(station.operatorName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark)),
                  const SizedBox(width: 6),
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.outlineDark, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('عمومی', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark)),
                ],
              ),
              const SizedBox(height: 14),

              // Availability summary card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.statusAvailable, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('${station.availableCount} آزاد', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondaryDark)),
                    const SizedBox(width: 20),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.statusOccupied, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('${station.connectors.where((c) => c.status == ConnectorStatus.occupied || c.status == ConnectorStatus.reserved).length} اشغال', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondaryDark)),
                    const SizedBox(width: 12),
                    Text('${station.maxPowerKw.toInt()} kW max', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiaryDark)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Connectors section header
              _SectionHeader(label: l10n.homeConnectors),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Connector cards
        for (int i = 0; i < station.connectors.length; i++) ...[
          if (i > 0)
            Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.outlineDark.withValues(alpha: 0.4)),
          _ConnectorCard(
            connector: station.connectors[i],
            onReserve: () => onReserve(station.connectors[i].id),
          ),
        ],

        const SizedBox(height: 20),

        // Amenities section
        if (station.amenities.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(label: l10n.homeAmenities),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [for (final a in station.amenities) _AmenityChip(amenity: a)],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],

        // Hours section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(label: l10n.homeHours),
              const SizedBox(height: 8),
              Text(
                station.hours == '۲۴ ساعته' ? l10n.homeHours24 : station.hours,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                '${station.updatedMinutesAgo} دقیقه پیش به‌روز شد',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: station.updatedMinutesAgo > 10 ? AppColors.warning : AppColors.textTertiaryDark,
                    ),
              ),
              const SizedBox(height: 20),

              // Navigate CTA
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: Text(l10n.homeNavigate),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.textPrimaryDark,
                  side: BorderSide(color: AppColors.outlineDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiaryDark,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ConnectorCard extends StatelessWidget {
  const _ConnectorCard({required this.connector, this.onReserve});
  final MockConnector connector;
  final VoidCallback? onReserve;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = connector.statusColor;

    return Semantics(
      label: '${connector.typeLabel}, ${connector.powerKw.toInt()} کیلووات. ${_statusLabel(connector.status, l10n)}.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: Icon(Icons.electric_bolt_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(connector.typeLabel, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 2),
                  Text('${connector.powerKw.toInt()} kW', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryDark)),
                  if (connector.status == ConnectorStatus.available && connector.pricePerKwhToman > 0)
                    Text('از ${_formatPrice(connector.pricePerKwhToman)} تومان', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark)),
                  if (connector.status == ConnectorStatus.occupied && connector.estimatedFreeFa != null)
                    Text('تخمین آزاد: ${connector.estimatedFreeFa}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark)),
                  if (connector.status == ConnectorStatus.faulted)
                    Text('خرابی گزارش شد', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.statusFaulted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(status: connector.status),
                if (connector.status == ConnectorStatus.available) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 30,
                    child: FilledButton(
                      onPressed: onReserve,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: Text(l10n.homeReserve),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ConnectorStatus status, AppLocalizations l10n) => switch (status) {
        ConnectorStatus.available => l10n.stationAvailable,
        ConnectorStatus.occupied => l10n.stationOccupied,
        ConnectorStatus.reserved => l10n.stationReserved,
        ConnectorStatus.unavailable => l10n.stationUnavailable,
        ConnectorStatus.faulted => l10n.stationFaulted,
      };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ConnectorStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      ConnectorStatus.available => (l10n.stationAvailable, AppColors.statusAvailable),
      ConnectorStatus.occupied => (l10n.stationOccupied, AppColors.statusOccupied),
      ConnectorStatus.reserved => (l10n.stationReserved, AppColors.statusReserved),
      ConnectorStatus.unavailable => (l10n.stationUnavailable, AppColors.statusUnavailable),
      ConnectorStatus.faulted => (l10n.stationFaulted, AppColors.statusFaulted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.rFull,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity});
  final AmenityType amenity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, label) = switch (amenity) {
      AmenityType.parking => (Icons.local_parking_rounded, l10n.homeAmenityParking),
      AmenityType.coffee => (Icons.coffee_rounded, l10n.homeAmenityCoffee),
      AmenityType.restroom => (Icons.wc_rounded, l10n.homeAmenityRestroom),
      AmenityType.wifi => (Icons.wifi_rounded, l10n.homeAmenityWifi),
      AmenityType.shopping => (Icons.shopping_bag_outlined, 'Shopping'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: AppRadius.rFull,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondaryDark),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondaryDark)),
          const SizedBox(width: 4),
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _formatPrice(int price) {
  if (price == 0) return '—';
  final s = price.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
