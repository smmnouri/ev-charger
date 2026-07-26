import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/storage/hive_storage.dart';
import 'core/storage/secure_storage.dart';

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
    container.read(themeProvider.notifier).loadFromPrefs(),
    container.read(localeProvider.notifier).loadFromPrefs(),
  ]);

  // Resolve auth state from secure storage — drives the router guard.
  final storage = container.read(secureStorageProvider);
  final hasToken = await storage.hasAccessToken();
  container.read(authProvider.notifier).resolveFromStorage(
        hasToken: hasToken,
      );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EvChargerApp(),
    ),
  );
}
