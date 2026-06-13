import 'package:flutter/material.dart' show Color;

import '../../../core/theme/app_colors.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum ConnectorType { type2, ccs, chademo, gbt }

enum ConnectorStatus { available, occupied, reserved, unavailable, faulted }

enum AmenityType { parking, coffee, restroom, wifi, shopping }

enum StationFilterType { type2, ccs, chademo, gbt, ac, dc, available, nearby }

// ── Connector ─────────────────────────────────────────────────────────────────

class MockConnector {
  const MockConnector({
    required this.id,
    required this.type,
    required this.powerKw,
    required this.status,
    required this.pricePerKwhToman,
    this.estimatedFreeFa,
  });

  final String id;
  final ConnectorType type;
  final double powerKw;
  final ConnectorStatus status;
  final int pricePerKwhToman;
  final String? estimatedFreeFa;

  bool get isDc => type == ConnectorType.ccs || type == ConnectorType.chademo || type == ConnectorType.gbt;
  bool get isAc => type == ConnectorType.type2;

  String get typeLabel => switch (type) {
        ConnectorType.type2 => 'Type 2 AC',
        ConnectorType.ccs => 'CCS DC',
        ConnectorType.chademo => 'CHAdeMO',
        ConnectorType.gbt => 'GB/T',
      };

  String get typeLabelShort => switch (type) {
        ConnectorType.type2 => 'Type 2',
        ConnectorType.ccs => 'CCS',
        ConnectorType.chademo => 'CHAdeMO',
        ConnectorType.gbt => 'GB/T',
      };

  Color get statusColor => switch (status) {
        ConnectorStatus.available => AppColors.statusAvailable,
        ConnectorStatus.occupied => AppColors.statusOccupied,
        ConnectorStatus.reserved => AppColors.statusReserved,
        ConnectorStatus.unavailable => AppColors.statusUnavailable,
        ConnectorStatus.faulted => AppColors.statusFaulted,
      };
}

// ── Station ───────────────────────────────────────────────────────────────────

class MockStation {
  const MockStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.distanceFa,
    required this.operatorName,
    required this.connectors,
    required this.amenities,
    required this.hours,
    required this.updatedMinutesAgo,
    required this.pinX,
    required this.pinY,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String distanceFa;
  final String operatorName;
  final List<MockConnector> connectors;
  final List<AmenityType> amenities;
  final String hours;
  final int updatedMinutesAgo;
  final double pinX;
  final double pinY;

  // ── Computed ─────────────────────────────────────────────────────────────

  int get availableCount => connectors.where((c) => c.status == ConnectorStatus.available).length;
  int get totalCount => connectors.length;
  double get maxPowerKw => connectors.map((c) => c.powerKw).reduce((a, b) => a > b ? a : b);

  ConnectorStatus get overallStatus {
    if (connectors.any((c) => c.status == ConnectorStatus.available)) return ConnectorStatus.available;
    if (connectors.any((c) => c.status == ConnectorStatus.occupied)) return ConnectorStatus.occupied;
    if (connectors.any((c) => c.status == ConnectorStatus.faulted)) return ConnectorStatus.faulted;
    return ConnectorStatus.unavailable;
  }

  Color get pinColor => switch (overallStatus) {
        ConnectorStatus.available => AppColors.statusAvailable,
        ConnectorStatus.occupied => AppColors.statusOccupied,
        ConnectorStatus.reserved => AppColors.statusReserved,
        ConnectorStatus.faulted => AppColors.statusFaulted,
        ConnectorStatus.unavailable => AppColors.statusUnavailable,
      };

  int get minPricePerKwh {
    final avail = connectors.where((c) => c.status == ConnectorStatus.available);
    if (avail.isEmpty) return connectors.map((c) => c.pricePerKwhToman).reduce((a, b) => a < b ? a : b);
    return avail.map((c) => c.pricePerKwhToman).reduce((a, b) => a < b ? a : b);
  }

  bool matchesFilter(Set<StationFilterType> filters) {
    if (filters.isEmpty) return true;
    final typeFilters = filters.where((f) => const {
      StationFilterType.type2,
      StationFilterType.ccs,
      StationFilterType.chademo,
      StationFilterType.gbt,
    }.contains(f));
    if (typeFilters.isNotEmpty) {
      final hasMatchingType = typeFilters.any((f) => switch (f) {
            StationFilterType.type2 => connectors.any((c) => c.type == ConnectorType.type2),
            StationFilterType.ccs => connectors.any((c) => c.type == ConnectorType.ccs),
            StationFilterType.chademo => connectors.any((c) => c.type == ConnectorType.chademo),
            StationFilterType.gbt => connectors.any((c) => c.type == ConnectorType.gbt),
            _ => false,
          });
      if (!hasMatchingType) return false;
    }
    if (filters.contains(StationFilterType.ac)) {
      if (!connectors.any((c) => c.isAc)) return false;
    }
    if (filters.contains(StationFilterType.dc)) {
      if (!connectors.any((c) => c.isDc)) return false;
    }
    if (filters.contains(StationFilterType.available)) {
      if (availableCount == 0) return false;
    }
    if (filters.contains(StationFilterType.nearby)) {
      if (distanceKm > 3.0) return false;
    }
    return true;
  }

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) || address.toLowerCase().contains(q);
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

abstract final class MockStationRepository {
  static const stations = <MockStation>[
    // ── s1 ── ولیعصر ─────────────────────────────────────────────────────────
    MockStation(
      id: 's1',
      name: 'ایستگاه شارژ تهران پارک',
      address: 'تهران، خیابان ولیعصر، پلاک ۱۴۲',
      latitude: 35.7210,
      longitude: 51.4190,
      distanceKm: 0.8,
      distanceFa: '۰٫۸ کیلومتر',
      operatorName: 'شارژ ایران',
      connectors: [
        MockConnector(id: 's1c1', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 450),
        MockConnector(id: 's1c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.occupied, pricePerKwhToman: 450, estimatedFreeFa: '۲۰ دقیقه'),
        MockConnector(id: 's1c3', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
        MockConnector(id: 's1c4', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
      ],
      amenities: [AmenityType.parking, AmenityType.restroom, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 2,
      pinX: 0.28,
      pinY: 0.34,
    ),
    // ── s2 ── آزادی ──────────────────────────────────────────────────────────
    MockStation(
      id: 's2',
      name: 'مرکز شارژ مجتمع آزادی',
      address: 'تهران، میدان آزادی، برج آزادی',
      latitude: 35.6998,
      longitude: 51.3368,
      distanceKm: 1.2,
      distanceFa: '۱٫۲ کیلومتر',
      operatorName: 'اوجاک چارج',
      connectors: [
        MockConnector(id: 's2c1', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.occupied, pricePerKwhToman: 620, estimatedFreeFa: '۱۵ دقیقه'),
        MockConnector(id: 's2c2', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.occupied, pricePerKwhToman: 620, estimatedFreeFa: '۳۵ دقیقه'),
        MockConnector(id: 's2c3', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.reserved, pricePerKwhToman: 620),
        MockConnector(id: 's2c4', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 400, estimatedFreeFa: '۱۰ دقیقه'),
      ],
      amenities: [AmenityType.parking, AmenityType.coffee, AmenityType.shopping],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 1,
      pinX: 0.68,
      pinY: 0.42,
    ),
    // ── s3 ── شهرک غرب ───────────────────────────────────────────────────────
    MockStation(
      id: 's3',
      name: 'ایستگاه شارژ هوشمند مدرن',
      address: 'تهران، شهرک غرب، بلوار دادمان',
      latitude: 35.7358,
      longitude: 51.3770,
      distanceKm: 2.1,
      distanceFa: '۲٫۱ کیلومتر',
      operatorName: 'برق‌ساز',
      connectors: [
        MockConnector(id: 's3c1', type: ConnectorType.chademo, powerKw: 62, status: ConnectorStatus.available, pricePerKwhToman: 520),
        MockConnector(id: 's3c2', type: ConnectorType.chademo, powerKw: 62, status: ConnectorStatus.available, pricePerKwhToman: 520),
        MockConnector(id: 's3c3', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 520),
      ],
      amenities: [AmenityType.parking, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 5,
      pinX: 0.52,
      pinY: 0.25,
    ),
    // ── s4 ── انقلاب (خارج از سرویس) ────────────────────────────────────────
    MockStation(
      id: 's4',
      name: 'ایستگاه شارژ قدیمی مرکز',
      address: 'تهران، خیابان انقلاب، کوچه بهار',
      latitude: 35.6979,
      longitude: 51.4032,
      distanceKm: 3.5,
      distanceFa: '۳٫۵ کیلومتر',
      operatorName: 'شارژ قدیم',
      connectors: [
        MockConnector(id: 's4c1', type: ConnectorType.gbt, powerKw: 40, status: ConnectorStatus.unavailable, pricePerKwhToman: 0),
        MockConnector(id: 's4c2', type: ConnectorType.gbt, powerKw: 40, status: ConnectorStatus.faulted, pricePerKwhToman: 0),
      ],
      amenities: [],
      hours: '۸ تا ۲۲',
      updatedMinutesAgo: 42,
      pinX: 0.16,
      pinY: 0.50,
    ),
    // ── s5 ── نیاوران / باهنر ────────────────────────────────────────────────
    MockStation(
      id: 's5',
      name: 'ایستگاه پرسرعت شمال تهران',
      address: 'تهران، نیاوران، بلوار باهنر',
      latitude: 35.8129,
      longitude: 51.4634,
      distanceKm: 4.8,
      distanceFa: '۴٫۸ کیلومتر',
      operatorName: 'شارژ ایران',
      connectors: [
        MockConnector(id: 's5c1', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 680),
        MockConnector(id: 's5c2', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 680),
        MockConnector(id: 's5c3', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.occupied, pricePerKwhToman: 520, estimatedFreeFa: '۸ دقیقه'),
        MockConnector(id: 's5c4', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
      ],
      amenities: [AmenityType.parking, AmenityType.restroom, AmenityType.coffee, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 3,
      pinX: 0.75,
      pinY: 0.62,
    ),
    // ── s6 ── مرزداران ────────────────────────────────────────────────────────
    MockStation(
      id: 's6',
      name: 'شارژ رزیدانس مرزداران',
      address: 'تهران، مرزداران، برج رزیدانس',
      latitude: 35.7355,
      longitude: 51.3592,
      distanceKm: 6.0,
      distanceFa: '۶٫۰ کیلومتر',
      operatorName: 'اوجاک چارج',
      connectors: [
        MockConnector(id: 's6c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 400, estimatedFreeFa: '۴۰ دقیقه'),
        MockConnector(id: 's6c2', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 400, estimatedFreeFa: '۵۵ دقیقه'),
      ],
      amenities: [AmenityType.parking],
      hours: '۶ تا ۲۳',
      updatedMinutesAgo: 8,
      pinX: 0.38,
      pinY: 0.60,
    ),
    // ── s7 ── ونک ────────────────────────────────────────────────────────────
    MockStation(
      id: 's7',
      name: 'ایستگاه شارژ ونک',
      address: 'تهران، خیابان ونک، مجتمع تجاری ونک',
      latitude: 35.7566,
      longitude: 51.4030,
      distanceKm: 1.8,
      distanceFa: '۱٫۸ کیلومتر',
      operatorName: 'گرین‌پاور',
      connectors: [
        MockConnector(id: 's7c1', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 720),
        MockConnector(id: 's7c2', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 720),
        MockConnector(id: 's7c3', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.occupied, pricePerKwhToman: 550, estimatedFreeFa: '۱۲ دقیقه'),
      ],
      amenities: [AmenityType.parking, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 4,
      pinX: 0.45,
      pinY: 0.18,
    ),
    // ── s8 ── اکباتان ────────────────────────────────────────────────────────
    MockStation(
      id: 's8',
      name: 'شارژخانه اکباتان',
      address: 'تهران، اکباتان، فاز سه',
      latitude: 35.7176,
      longitude: 51.3301,
      distanceKm: 2.5,
      distanceFa: '۲٫۵ کیلومتر',
      operatorName: 'اوجاک چارج',
      connectors: [
        MockConnector(id: 's8c1', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 480),
        MockConnector(id: 's8c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 480),
        MockConnector(id: 's8c3', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
      ],
      amenities: [AmenityType.parking],
      hours: '۷ تا ۲۳',
      updatedMinutesAgo: 2,
      pinX: 0.22,
      pinY: 0.38,
    ),
    // ── s9 ── ایران‌مال ──────────────────────────────────────────────────────
    MockStation(
      id: 's9',
      name: 'ایستگاه شارژ ایران‌مال',
      address: 'تهران، باغ فیض، ایران‌مال',
      latitude: 35.7480,
      longitude: 51.3012,
      distanceKm: 5.1,
      distanceFa: '۵٫۱ کیلومتر',
      operatorName: 'ایران‌چارج',
      connectors: [
        MockConnector(id: 's9c1', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 700),
        MockConnector(id: 's9c2', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.occupied, pricePerKwhToman: 700, estimatedFreeFa: '۲۵ دقیقه'),
        MockConnector(id: 's9c3', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
        MockConnector(id: 's9c4', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
      ],
      amenities: [AmenityType.parking, AmenityType.coffee, AmenityType.shopping, AmenityType.wifi, AmenityType.restroom],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 1,
      pinX: 0.10,
      pinY: 0.28,
    ),
    // ── s10 ── جردن ─────────────────────────────────────────────────────────
    MockStation(
      id: 's10',
      name: 'ایستگاه شارژ جردن',
      address: 'تهران، جردن، بلوار آرش',
      latitude: 35.7608,
      longitude: 51.4155,
      distanceKm: 2.0,
      distanceFa: '۲٫۰ کیلومتر',
      operatorName: 'برق‌ساز',
      connectors: [
        MockConnector(id: 's10c1', type: ConnectorType.chademo, powerKw: 62, status: ConnectorStatus.available, pricePerKwhToman: 520),
        MockConnector(id: 's10c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 500),
        MockConnector(id: 's10c3', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 380, estimatedFreeFa: '۳۰ دقیقه'),
      ],
      amenities: [AmenityType.parking, AmenityType.wifi],
      hours: '۸ تا ۲۲',
      updatedMinutesAgo: 6,
      pinX: 0.58,
      pinY: 0.20,
    ),
    // ── s11 ── صادقیه ────────────────────────────────────────────────────────
    MockStation(
      id: 's11',
      name: 'مرکز شارژ صادقیه',
      address: 'تهران، صادقیه، بلوار فردوس',
      latitude: 35.7213,
      longitude: 51.3654,
      distanceKm: 2.8,
      distanceFa: '۲٫۸ کیلومتر',
      operatorName: 'اوجاک چارج',
      connectors: [
        MockConnector(id: 's11c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 380, estimatedFreeFa: '۴۵ دقیقه'),
        MockConnector(id: 's11c2', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 380, estimatedFreeFa: '۵۰ دقیقه'),
        MockConnector(id: 's11c3', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 380, estimatedFreeFa: '۱۵ دقیقه'),
      ],
      amenities: [AmenityType.parking],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 3,
      pinX: 0.32,
      pinY: 0.44,
    ),
    // ── s12 ── پونک (خارج از سرویس) ─────────────────────────────────────────
    MockStation(
      id: 's12',
      name: 'ایستگاه شارژ پونک',
      address: 'تهران، پونک، خیابان ستاری',
      latitude: 35.7278,
      longitude: 51.3538,
      distanceKm: 3.4,
      distanceFa: '۳٫۴ کیلومتر',
      operatorName: 'شارژ ایران',
      connectors: [
        MockConnector(id: 's12c1', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.faulted, pricePerKwhToman: 0),
        MockConnector(id: 's12c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.unavailable, pricePerKwhToman: 0),
      ],
      amenities: [],
      hours: '۸ تا ۲۲',
      updatedMinutesAgo: 120,
      pinX: 0.24,
      pinY: 0.30,
    ),
    // ── s13 ── تجریش ─────────────────────────────────────────────────────────
    MockStation(
      id: 's13',
      name: 'ایستگاه شارژ تجریش',
      address: 'تهران، تجریش، میدان تجریش',
      latitude: 35.7979,
      longitude: 51.4311,
      distanceKm: 5.5,
      distanceFa: '۵٫۵ کیلومتر',
      operatorName: 'گرین‌پاور',
      connectors: [
        MockConnector(id: 's13c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
        MockConnector(id: 's13c2', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
        MockConnector(id: 's13c3', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 520),
      ],
      amenities: [AmenityType.parking, AmenityType.coffee, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 9,
      pinX: 0.65,
      pinY: 0.68,
    ),
    // ── s14 ── فرمانیه ───────────────────────────────────────────────────────
    MockStation(
      id: 's14',
      name: 'شارژ رزیدانس فرمانیه',
      address: 'تهران، فرمانیه، خیابان ولنجک',
      latitude: 35.7802,
      longitude: 51.4538,
      distanceKm: 6.2,
      distanceFa: '۶٫۲ کیلومتر',
      operatorName: 'ایران‌چارج',
      connectors: [
        MockConnector(id: 's14c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 400, estimatedFreeFa: '۳۵ دقیقه'),
        MockConnector(id: 's14c2', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 400, estimatedFreeFa: '۱۸ دقیقه'),
      ],
      amenities: [AmenityType.parking],
      hours: '۰۷ تا ۲۳',
      updatedMinutesAgo: 15,
      pinX: 0.82,
      pinY: 0.65,
    ),
    // ── s15 ── پارک لاله ─────────────────────────────────────────────────────
    MockStation(
      id: 's15',
      name: 'ایستگاه شارژ پارک لاله',
      address: 'تهران، خیابان کارگر، پارک لاله',
      latitude: 35.7188,
      longitude: 51.4078,
      distanceKm: 1.5,
      distanceFa: '۱٫۵ کیلومتر',
      operatorName: 'برق‌ساز',
      connectors: [
        MockConnector(id: 's15c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 390),
        MockConnector(id: 's15c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 510),
        MockConnector(id: 's15c3', type: ConnectorType.chademo, powerKw: 62, status: ConnectorStatus.reserved, pricePerKwhToman: 530),
      ],
      amenities: [AmenityType.parking, AmenityType.restroom, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 2,
      pinX: 0.50,
      pinY: 0.48,
    ),
    // ── s16 ── دانشگاه تهران ────────────────────────────────────────────────
    MockStation(
      id: 's16',
      name: 'مرکز شارژ دانشگاه تهران',
      address: 'تهران، خیابان انقلاب، دانشگاه تهران',
      latitude: 35.7024,
      longitude: 51.3937,
      distanceKm: 1.1,
      distanceFa: '۱٫۱ کیلومتر',
      operatorName: 'شارژ ایران',
      connectors: [
        MockConnector(id: 's16c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 380, estimatedFreeFa: '۵ دقیقه'),
        MockConnector(id: 's16c2', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
      ],
      amenities: [],
      hours: '۰۸ تا ۲۰',
      updatedMinutesAgo: 5,
      pinX: 0.44,
      pinY: 0.38,
    ),
    // ── s17 ── سعادت‌آباد ────────────────────────────────────────────────────
    MockStation(
      id: 's17',
      name: 'ایستگاه پرسرعت سعادت‌آباد',
      address: 'تهران، سعادت‌آباد، بلوار دریا',
      latitude: 35.7622,
      longitude: 51.3765,
      distanceKm: 2.3,
      distanceFa: '۲٫۳ کیلومتر',
      operatorName: 'اوجاک چارج',
      connectors: [
        MockConnector(id: 's17c1', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 750),
        MockConnector(id: 's17c2', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 750),
        MockConnector(id: 's17c3', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 560),
      ],
      amenities: [AmenityType.parking, AmenityType.coffee, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 1,
      pinX: 0.40,
      pinY: 0.15,
    ),
    // ── s18 ── دروس ──────────────────────────────────────────────────────────
    MockStation(
      id: 's18',
      name: 'ایستگاه شارژ دروس',
      address: 'تهران، دروس، بلوار تهران‌نو',
      latitude: 35.7718,
      longitude: 51.4439,
      distanceKm: 7.0,
      distanceFa: '۷٫۰ کیلومتر',
      operatorName: 'ایران‌چارج',
      connectors: [
        MockConnector(id: 's18c1', type: ConnectorType.gbt, powerKw: 40, status: ConnectorStatus.available, pricePerKwhToman: 460),
        MockConnector(id: 's18c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.available, pricePerKwhToman: 510),
      ],
      amenities: [AmenityType.parking, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 3,
      pinX: 0.72,
      pinY: 0.78,
    ),
    // ── s19 ── شهران ─────────────────────────────────────────────────────────
    MockStation(
      id: 's19',
      name: 'مرکز شارژ شهران',
      address: 'تهران، شهران، بلوار ایران‌زمین',
      latitude: 35.7421,
      longitude: 51.3427,
      distanceKm: 4.3,
      distanceFa: '۴٫۳ کیلومتر',
      operatorName: 'برق‌ساز',
      connectors: [
        MockConnector(id: 's19c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.occupied, pricePerKwhToman: 400, estimatedFreeFa: '۲۰ دقیقه'),
        MockConnector(id: 's19c2', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.occupied, pricePerKwhToman: 530, estimatedFreeFa: '۱۰ دقیقه'),
      ],
      amenities: [AmenityType.parking],
      hours: '۰۶ تا ۲۴',
      updatedMinutesAgo: 18,
      pinX: 0.18,
      pinY: 0.62,
    ),
    // ── s20 ── پاسداران ───────────────────────────────────────────────────────
    MockStation(
      id: 's20',
      name: 'ایستگاه پرسرعت پاسداران',
      address: 'تهران، پاسداران، بلوار شریعتی',
      latitude: 35.7689,
      longitude: 51.4563,
      distanceKm: 7.8,
      distanceFa: '۷٫۸ کیلومتر',
      operatorName: 'گرین‌پاور',
      connectors: [
        MockConnector(id: 's20c1', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 680),
        MockConnector(id: 's20c2', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.available, pricePerKwhToman: 680),
        MockConnector(id: 's20c3', type: ConnectorType.ccs, powerKw: 150, status: ConnectorStatus.occupied, pricePerKwhToman: 680, estimatedFreeFa: '۷ دقیقه'),
      ],
      amenities: [AmenityType.parking, AmenityType.coffee, AmenityType.restroom, AmenityType.wifi],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 4,
      pinX: 0.86,
      pinY: 0.48,
    ),
    // ── s21 ── نیاوران شمال ──────────────────────────────────────────────────
    MockStation(
      id: 's21',
      name: 'ایستگاه شارژ نیاوران',
      address: 'تهران، نیاوران، بلوار شهید رئیسی',
      latitude: 35.8008,
      longitude: 51.4504,
      distanceKm: 7.5,
      distanceFa: '۷٫۵ کیلومتر',
      operatorName: 'شارژ ایران',
      connectors: [
        MockConnector(id: 's21c1', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
        MockConnector(id: 's21c2', type: ConnectorType.type2, powerKw: 22, status: ConnectorStatus.available, pricePerKwhToman: 380),
        MockConnector(id: 's21c3', type: ConnectorType.ccs, powerKw: 50, status: ConnectorStatus.occupied, pricePerKwhToman: 520, estimatedFreeFa: '۲۲ دقیقه'),
      ],
      amenities: [AmenityType.parking, AmenityType.coffee, AmenityType.restroom],
      hours: '۲۴ ساعته',
      updatedMinutesAgo: 7,
      pinX: 0.78,
      pinY: 0.58,
    ),
  ];

  static MockStation? findById(String? id) {
    if (id == null) return null;
    for (final s in stations) {
      if (s.id == id) return s;
    }
    return null;
  }
}
