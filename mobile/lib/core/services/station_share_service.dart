import 'package:share_plus/share_plus.dart';

import '../../features/map/data/mock_station_repository.dart';

// Future-ready: add deep links, EVCharge web links, QR sharing here.
abstract final class StationShareService {
  // ── Link generators ───────────────────────────────────────────────────────

  static String osmLink(double lat, double lon) =>
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lon&zoom=17';

  static String googleMapsLink(double lat, double lon) =>
      'https://maps.google.com/?q=$lat,$lon';

  static String geoUri(double lat, double lon) => 'geo:$lat,$lon';

  // ── Text builder ──────────────────────────────────────────────────────────

  static String buildShareText(MockStation station) {
    final types =
        station.connectors.map((c) => c.typeLabelShort).toSet().join('، ');
    final avail = station.availableCount;
    final total = station.totalCount;
    final statusText =
        avail > 0 ? '$avail از $total پریز آزاد' : 'همه پریزها اشغال';
    final lat = station.latitude;
    final lon = station.longitude;

    return '⚡ ${station.name}\n'
        '📍 ${station.address}\n'
        '🔌 نوع شارژ: $types\n'
        '✅ وضعیت: $statusText\n'
        '\n'
        '🗺 OpenStreetMap:\n'
        '${osmLink(lat, lon)}\n'
        '\n'
        '📎 Google Maps:\n'
        '${googleMapsLink(lat, lon)}\n'
        '\n'
        '📡 مختصات: $lat, $lon';
  }

  // ── Main entry point ──────────────────────────────────────────────────────

  static Future<void> shareStation(MockStation station) =>
      Share.share(buildShareText(station), subject: station.name);
}
