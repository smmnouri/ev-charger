import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Hive box names used across the app.
abstract final class HiveBoxes {
  static const String sessions = 'charging_sessions';
  static const String reservations = 'reservations';
  static const String walletTransactions = 'wallet_transactions';
  static const String notifications = 'notifications';
  static const String stationCache = 'station_cache';
  static const String userProfile = 'user_profile';
}

/// Initialises Hive and opens all application boxes.
/// Called once during app startup in [main.dart].
Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  // Register adapters here as domain models are implemented.
  // e.g. Hive.registerAdapter(ChargingSessionAdapter());

  await Future.wait([
    Hive.openBox<dynamic>(HiveBoxes.sessions),
    Hive.openBox<dynamic>(HiveBoxes.reservations),
    Hive.openBox<dynamic>(HiveBoxes.walletTransactions),
    Hive.openBox<dynamic>(HiveBoxes.notifications),
    Hive.openBox<dynamic>(HiveBoxes.stationCache),
    Hive.openBox<dynamic>(HiveBoxes.userProfile),
  ]);
}
