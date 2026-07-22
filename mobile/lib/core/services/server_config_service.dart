import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_url.dart';

const _kServerBaseUrlKey = 'server_base_url';

/// Startup server connectivity state — drives the initial route and error messaging.
enum ServerConfigStatus {
  /// No URL has ever been saved (first run).
  needsSetup,

  /// A URL is saved but the server could not be reached at startup.
  connectionFailed,

  /// Server is reachable; app proceeds through the normal auth flow.
  connected,
}

/// In-memory runtime server base URL. Seeded from storage in main() before runApp.
/// Empty string means "use the compile-time default".
final serverUrlProvider = StateProvider<String>((ref) => '');

/// Startup connectivity status — read by the router to set initialLocation.
final serverConfigStatusProvider = StateProvider<ServerConfigStatus>(
  (ref) => ServerConfigStatus.needsSetup,
);

Future<String> loadSavedServerUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString(_kServerBaseUrlKey) ?? '';
  final serverRoot = normalizeServerRoot(savedUrl);
  if (serverRoot != savedUrl) {
    await prefs.setString(_kServerBaseUrlKey, serverRoot);
  }
  return serverRoot;
}

Future<void> saveServerUrl(String url) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kServerBaseUrlKey, normalizeServerRoot(url));
}

/// Removes trailing slashes and migrates the previous API-prefixed value.
String normalizeServerRoot(String url) {
  final normalized = url.trim().replaceFirst(RegExp(r'/+$'), '');
  return normalized.endsWith(apiPrefix)
      ? normalized.substring(0, normalized.length - apiPrefix.length)
      : normalized;
}
