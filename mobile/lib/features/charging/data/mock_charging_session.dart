enum ChargingStatus {
  preparing,
  starting,
  charging,
  paused,
  finishing,
  completed,
  failed,
}

class MockChargingSession {
  const MockChargingSession({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.connectorId,
    required this.connectorTypeLabel,
    required this.powerKw,
    required this.pricePerKwhToman,
    required this.startTime,
    required this.status,
    required this.elapsedSeconds,
  });

  final String id;
  final String stationId;
  final String stationName;
  final String connectorId;
  final String connectorTypeLabel;
  final double powerKw;
  final int pricePerKwhToman;
  final DateTime startTime;
  final ChargingStatus status;
  final int elapsedSeconds;

  double get energyKwh => powerKw * 0.88 * elapsedSeconds / 3600;
  int get estimatedCostToman => (energyKwh * pricePerKwhToman).round();

  MockChargingSession copyWith({
    ChargingStatus? status,
    int? elapsedSeconds,
  }) =>
      MockChargingSession(
        id: id,
        stationId: stationId,
        stationName: stationName,
        connectorId: connectorId,
        connectorTypeLabel: connectorTypeLabel,
        powerKw: powerKw,
        pricePerKwhToman: pricePerKwhToman,
        startTime: startTime,
        status: status ?? this.status,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );
}

class ChargingHistoryEntry {
  const ChargingHistoryEntry({
    required this.id,
    required this.stationName,
    required this.connectorTypeLabel,
    required this.startTime,
    required this.durationSeconds,
    required this.energyKwh,
    required this.totalCostToman,
    required this.powerKw,
  });

  final String id;
  final String stationName;
  final String connectorTypeLabel;
  final DateTime startTime;
  final int durationSeconds;
  final double energyKwh;
  final int totalCostToman;
  final double powerKw;
}

abstract final class MockChargingHistory {
  static final seedEntries = <ChargingHistoryEntry>[
    ChargingHistoryEntry(
      id: 'ses-001',
      stationName: 'ایستگاه شارژ تهران پارک',
      connectorTypeLabel: 'CCS DC',
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      durationSeconds: 2700,
      energyKwh: 18.5,
      totalCostToman: 259000,
      powerKw: 50.0,
    ),
    ChargingHistoryEntry(
      id: 'ses-002',
      stationName: 'ایستگاه مال آف ایران',
      connectorTypeLabel: 'Type 2 AC',
      startTime: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      durationSeconds: 3600,
      energyKwh: 9.2,
      totalCostToman: 138000,
      powerKw: 11.0,
    ),
    ChargingHistoryEntry(
      id: 'ses-003',
      stationName: 'ایستگاه سعادت‌آباد',
      connectorTypeLabel: 'CHAdeMO',
      startTime: DateTime.now().subtract(const Duration(days: 7, hours: 10)),
      durationSeconds: 1800,
      energyKwh: 22.0,
      totalCostToman: 330000,
      powerKw: 50.0,
    ),
  ];
}
