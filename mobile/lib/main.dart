import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/map_style_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/network/api_url.dart';
import 'core/services/server_config_service.dart';
import 'core/storage/hive_storage.dart';
import 'core/storage/secure_storage.dart';

Future<bool> _testServerConnection(String url) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  try {
    final response = await dio.get('${buildApiBaseUrl(url)}/health/ready');
    return response.statusCode == 200;
  } catch (_) {
    return false;
  } finally {
    dio.close();
  }
}

Future<void> main() async {
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
<<<<<<< HEAD
    container.read(themeProvider.notifier).loadFromPrefs(),
    container.read(localeProvider.notifier).loadFromPrefs(),
=======
    container.read(themeNotifierProvider.notifier).loadFromPrefs(),
    container.read(localeNotifierProvider.notifier).loadFromPrefs(),
    container.read(mapStyleProvider.notifier).loadFromPrefs(),
>>>>>>> 81c7eb062ad20014d195399c281fe1da9979553a
  ]);

  // Load saved server URL and test connectivity before first frame.
  final savedUrl = await loadSavedServerUrl();
  if (savedUrl.isEmpty) {
    container.read(serverConfigStatusProvider.notifier).state =
        ServerConfigStatus.needsSetup;
  } else {
    container.read(serverUrlProvider.notifier).state = savedUrl;
    final reachable = await _testServerConnection(savedUrl);
    container.read(serverConfigStatusProvider.notifier).state = reachable
        ? ServerConfigStatus.connected
        : ServerConfigStatus.connectionFailed;
  }

  // Resolve auth state from secure storage — drives the router guard.
  final storage = container.read(secureStorageProvider);
  final hasToken = await storage.hasAccessToken();
<<<<<<< HEAD
  container.read(authProvider.notifier).resolveFromStorage(
        hasToken: hasToken,
      );
=======
  container
      .read(authNotifierProvider.notifier)
      .resolveFromStorage(hasToken: hasToken);
>>>>>>> 81c7eb062ad20014d195399c281fe1da9979553a

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EvChargerApp(),
    ),
  );
}
