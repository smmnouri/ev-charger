import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/storage/hive_storage.dart';
import 'core/storage/secure_storage.dart';

// Routes Flutter's Dart HttpClient through a local CONNECT proxy on the host
// machine. Only active in debug builds on Android — never reaches production.
// Start tools/tile_proxy.py on the host before running the emulator.
class _DebugProxyOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    debugPrint('[ProxyOverride] createHttpClient called');
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        debugPrint('[ProxyOverride] findProxy for $uri');
        return 'PROXY 10.0.2.2:8888';
      };
  }
}

Future<void> main() async {
  debugPrint('[main] kDebugMode=$kDebugMode isAndroid=${Platform.isAndroid}');
  if (kDebugMode && Platform.isAndroid) {
    HttpOverrides.global = _DebugProxyOverrides();
    debugPrint('[main] HttpOverrides set');
  }

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar — map screen draws edge-to-edge.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await initHive();

  final container = ProviderContainer();

  // Load persisted settings before first frame.
  await Future.wait([
    container.read(themeNotifierProvider.notifier).loadFromPrefs(),
    container.read(localeNotifierProvider.notifier).loadFromPrefs(),
  ]);

  // Resolve auth state from secure storage — drives the router guard.
  final storage = container.read(secureStorageProvider);
  final hasToken = await storage.hasAccessToken();
  container.read(authNotifierProvider.notifier).resolveFromStorage(
        hasToken: hasToken,
      );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EvChargerApp(),
    ),
  );
}
