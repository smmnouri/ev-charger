import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class EvChargerApp extends ConsumerWidget {
  const EvChargerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final fontFamily = locale.languageCode == 'fa' ? 'Vazirmatn' : 'Inter';

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EV Charger',

      // Theme
      theme: AppTheme.light(fontFamily: fontFamily),
      darkTheme: AppTheme.dark(fontFamily: fontFamily),
      themeMode: themeMode,

      // Localisation
      locale: locale,
      supportedLocales: appSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Navigation
      routerConfig: router,
    );
  }
}
