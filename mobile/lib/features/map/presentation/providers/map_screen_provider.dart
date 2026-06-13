import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_station_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MapScreenState {
  const MapScreenState({
    this.selectedStationId,
    this.activeFilters = const {},
    this.isSearchActive = false,
    this.searchQuery = '',
  });

  final String? selectedStationId;
  final Set<StationFilterType> activeFilters;
  final bool isSearchActive;
  final String searchQuery;

  MapScreenState copyWith({
    Object? selectedStationId = _sentinel,
    Set<StationFilterType>? activeFilters,
    bool? isSearchActive,
    String? searchQuery,
  }) {
    return MapScreenState(
      selectedStationId: selectedStationId == _sentinel ? this.selectedStationId : selectedStationId as String?,
      activeFilters: activeFilters ?? this.activeFilters,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Sentinel for copyWith nullable fields
const _sentinel = Object();

// ── Notifier ──────────────────────────────────────────────────────────────────

class MapScreenNotifier extends Notifier<MapScreenState> {
  @override
  MapScreenState build() => const MapScreenState();

  void selectStation(String? id) {
    state = state.copyWith(selectedStationId: id);
  }

  void toggleFilter(StationFilterType filter) {
    final updated = Set<StationFilterType>.from(state.activeFilters);
    if (updated.contains(filter)) {
      updated.remove(filter);
    } else {
      updated.add(filter);
    }
    state = state.copyWith(activeFilters: updated);
  }

  void clearFilters() {
    state = state.copyWith(activeFilters: const {});
  }

  void setSearchActive(bool active) {
    state = state.copyWith(
      isSearchActive: active,
      searchQuery: active ? state.searchQuery : '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final mapScreenProvider = NotifierProvider<MapScreenNotifier, MapScreenState>(
  MapScreenNotifier.new,
);
