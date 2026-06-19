import 'package:flutter/widgets.dart';

/// Tile source configuration contract.
///
/// Implement this class to add a new tile provider (Neshan, Balad,
/// self-hosted server, offline tiles) without touching any UI code.
/// Swap the active implementation in [OsmMapService] or override the
/// [mapServiceProvider] in tests.
abstract class TileProviderConfig {
  const TileProviderConfig();

  /// flutter_map urlTemplate — supports {z}, {x}, {y}, {s} placeholders.
  String get urlTemplate;

  /// Subdomains rotated into the {s} placeholder. Empty list disables rotation.
  List<String> get subdomains;

  /// Additional URL templates tried in order when [urlTemplate] fails.
  /// Used by [CachedFallbackTileProvider] to build the fetch chain.
  List<String> get fallbackUrlTemplates => const [];

  /// Attribution text required by the tile provider's terms of service.
  String get attribution;

  /// Identifies the app in tile-server request logs (HTTP User-Agent).
  String get userAgentPackageName;

  /// Optional ColorFilter applied to the TileLayer to achieve a dark map
  /// from a light-themed tile source (grayscale-invert matrix).
  /// Null means tiles already have a dark theme (e.g. CartoDB DarkMatter).
  ColorFilter? get darkFilter => null;
}

// ─────────────────────────────────────────────────────────────────────────────
// OpenStreetMap-based implementations
// ─────────────────────────────────────────────────────────────────────────────

/// CartoDB DarkMatter — OpenStreetMap data with dark city styling.
///
/// Free tier; no API key required for reasonable traffic.
/// ODbL (OpenStreetMap) + CARTO attribution required by usage policy.
class OsmDarkTileConfig extends TileProviderConfig {
  const OsmDarkTileConfig();

  @override
  String get urlTemplate =>
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

  @override
  List<String> get subdomains => const ['a', 'b', 'c'];

  @override
  String get attribution => '© OpenStreetMap contributors © CARTO';

  @override
  String get userAgentPackageName => 'ir.evcharger.app';
}

/// Standard OpenStreetMap tile layer with a dark filter applied.
///
/// Kept as a reference implementation; the default map service uses
/// [IranResidentDarkTileConfig] which has native dark tiles and a CDN
/// more reliably accessible from Iran.
class OsmStandardTileConfig extends TileProviderConfig {
  const OsmStandardTileConfig();

  @override
  String get urlTemplate =>
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  List<String> get subdomains => const [];

  @override
  String get attribution => '© OpenStreetMap contributors';

  @override
  String get userAgentPackageName => 'ir.evcharger.app';

  // Grayscale-invert: converts luma to dark-map appearance.
  @override
  ColorFilter? get darkFilter => const ColorFilter.matrix([
    -0.299, -0.587, -0.114, 0, 255,
    -0.299, -0.587, -0.114, 0, 255,
    -0.299, -0.587, -0.114, 0, 255,
         0,      0,      0, 1,   0,
  ]);
}

/// Production tile config for devices in Iran.
///
/// Primary: CartoDB DarkMatter via Cloudflare CDN.  Cloudflare resumed
/// service to Iran in March 2023, making basemaps.cartocdn.com accessible
/// without a proxy on physical Android devices.
///
/// Fallback chain (used by [CachedFallbackTileProvider] when the primary
/// URL fails):
///   1. tile.openstreetmap.de — OSM Germany mirror (separate IP range)
///   2. tile.openstreetmap.org — OSM primary (Fastly CDN)
///
/// Tiles are natively dark — no [darkFilter] needed.
/// After the first successful fetch, all tiles are served from disk cache
/// and the map loads instantly without any network access.
class IranResidentDarkTileConfig extends TileProviderConfig {
  const IranResidentDarkTileConfig();

  @override
  String get urlTemplate =>
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

  @override
  List<String> get subdomains => const ['a', 'b', 'c'];

  @override
  List<String> get fallbackUrlTemplates => const [
        'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      ];

  @override
  String get attribution => '© OpenStreetMap contributors © CARTO';

  @override
  String get userAgentPackageName => 'ir.evcharger.app';

  @override
  ColorFilter? get darkFilter => null; // native dark tiles
}
