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

  /// Attribution text required by the tile provider's terms of service.
  String get attribution;

  /// Identifies the app in tile-server request logs (HTTP User-Agent).
  String get userAgentPackageName;
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

/// Standard OpenStreetMap tile layer (light theme).
///
/// Use as a fallback when dark tiles are unavailable, or in test
/// environments where CartoDB DNS resolution fails.
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
}
