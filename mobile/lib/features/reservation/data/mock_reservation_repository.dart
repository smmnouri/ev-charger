// ── Enums ────────────────────────────────────────────────────────────────────

enum ReservationStatus { upcoming, active, completed, cancelled }

// ── Model ─────────────────────────────────────────────────────────────────────

class MockReservation {
  const MockReservation({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.connectorId,
    required this.connectorTypeLabel,
    required this.powerKw,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    required this.estimatedCostToman,
    required this.distanceFa,
    required this.operatorName,
    required this.pricePerKwhToman,
  });

  final String id;
  final String stationId;
  final String stationName;
  final String connectorId;
  final String connectorTypeLabel;
  final double powerKw;
  final DateTime startTime;
  final int durationMinutes;
  final ReservationStatus status;
  final int estimatedCostToman;
  final String distanceFa;
  final String operatorName;
  final int pricePerKwhToman;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  MockReservation copyWith({ReservationStatus? status}) {
    return MockReservation(
      id: id,
      stationId: stationId,
      stationName: stationName,
      connectorId: connectorId,
      connectorTypeLabel: connectorTypeLabel,
      powerKw: powerKw,
      startTime: startTime,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      estimatedCostToman: estimatedCostToman,
      distanceFa: distanceFa,
      operatorName: operatorName,
      pricePerKwhToman: pricePerKwhToman,
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

abstract final class MockReservationRepository {
  // Computed at call time so relative dates stay accurate.
  static List<MockReservation> get seedReservations {
    final now = DateTime.now();
    DateTime todayAt(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);

    return [
      // ── upcoming ──────────────────────────────────────────────────────────
      MockReservation(
        id: 'r1',
        stationId: 's7',
        stationName: 'ایستگاه شارژ ونک',
        connectorId: 's7c1',
        connectorTypeLabel: 'CCS DC',
        powerKw: 150,
        startTime: now.add(const Duration(hours: 20)),
        durationMinutes: 30,
        status: ReservationStatus.upcoming,
        estimatedCostToman: 21_600,
        distanceFa: '۱٫۸ کیلومتر',
        operatorName: 'گرین‌پاور',
        pricePerKwhToman: 720,
      ),
      MockReservation(
        id: 'r2',
        stationId: 's1',
        stationName: 'ایستگاه شارژ تهران پارک',
        connectorId: 's1c3',
        connectorTypeLabel: 'Type 2 AC',
        powerKw: 22,
        startTime: now.add(const Duration(hours: 2)),
        durationMinutes: 45,
        status: ReservationStatus.upcoming,
        estimatedCostToman: 2_508,
        distanceFa: '۰٫۸ کیلومتر',
        operatorName: 'شارژ ایران',
        pricePerKwhToman: 380,
      ),

      // ── active ────────────────────────────────────────────────────────────
      MockReservation(
        id: 'r3',
        stationId: 's17',
        stationName: 'ایستگاه پرسرعت سعادت‌آباد',
        connectorId: 's17c1',
        connectorTypeLabel: 'CCS DC',
        powerKw: 150,
        startTime: now.subtract(const Duration(minutes: 5)),
        durationMinutes: 30,
        status: ReservationStatus.active,
        estimatedCostToman: 22_500,
        distanceFa: '۲٫۳ کیلومتر',
        operatorName: 'اوجاک چارج',
        pricePerKwhToman: 750,
      ),

      // ── completed ─────────────────────────────────────────────────────────
      MockReservation(
        id: 'r4',
        stationId: 's8',
        stationName: 'شارژخانه اکباتان',
        connectorId: 's8c1',
        connectorTypeLabel: 'CCS DC',
        powerKw: 50,
        startTime: todayAt(14, 0).subtract(const Duration(days: 1)),
        durationMinutes: 30,
        status: ReservationStatus.completed,
        estimatedCostToman: 4_800,
        distanceFa: '۲٫۵ کیلومتر',
        operatorName: 'اوجاک چارج',
        pricePerKwhToman: 480,
      ),
      MockReservation(
        id: 'r5',
        stationId: 's15',
        stationName: 'ایستگاه شارژ پارک لاله',
        connectorId: 's15c1',
        connectorTypeLabel: 'Type 2 AC',
        powerKw: 22,
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
        durationMinutes: 60,
        status: ReservationStatus.completed,
        estimatedCostToman: 3_432,
        distanceFa: '۱٫۵ کیلومتر',
        operatorName: 'برق‌ساز',
        pricePerKwhToman: 390,
      ),

      // ── cancelled ─────────────────────────────────────────────────────────
      MockReservation(
        id: 'r6',
        stationId: 's10',
        stationName: 'ایستگاه شارژ جردن',
        connectorId: 's10c1',
        connectorTypeLabel: 'CHAdeMO',
        powerKw: 62,
        startTime: now.subtract(const Duration(days: 2)),
        durationMinutes: 30,
        status: ReservationStatus.cancelled,
        estimatedCostToman: 6_448,
        distanceFa: '۲٫۰ کیلومتر',
        operatorName: 'برق‌ساز',
        pricePerKwhToman: 520,
      ),
    ];
  }
}
