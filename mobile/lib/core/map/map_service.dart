import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'tile_provider_config.dart';

/// Map provider contract.
///
/// Implement to support Neshan, Balad, or a self-hosted tile server:
/// 1. Create a [TileProviderConfig] subclass with the new URL template.
/// 2. Create a [MapService] subclass returning the new config.
/// 3. Override [mapServiceProvider] (e.g. via Riverpod scope override in
///    main.dart) to return the new service — zero UI code changes.
abstract class MapService {
  const MapService();

  /// Active tile layer configuration.
  TileProviderConfig get tileProvider;

  /// Default map centre shown on first launch (degrees).
  LatLng get defaultCenter;

  /// Default zoom level on first launch.
  double get defaultZoom;

  /// Minimum zoom level the user can reach.
  double get minZoom;

  /// Maximum zoom level the user can reach.
  double get maxZoom;
}

// ─────────────────────────────────────────────────────────────────────────────
// Default implementation
// ─────────────────────────────────────────────────────────────────────────────

/// Default map service — CartoDB DarkMatter tiles, Tehran default center.
class OsmMapService extends MapService {
  const OsmMapService();

  @override
  TileProviderConfig get tileProvider => const IranResidentDarkTileConfig();

  @override
  LatLng get defaultCenter => const LatLng(35.7219, 51.3884); // Tehran

  @override
  double get defaultZoom => 13.0;

  @override
  double get minZoom => 10.0;

  @override
  double get maxZoom => 18.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the active [MapService]. Override in tests or feature flags
/// to swap to a different tile provider without changing UI code.
final mapServiceProvider = Provider<MapService>((ref) => const OsmMapService());
