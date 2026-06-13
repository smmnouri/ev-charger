import 'package:flutter/material.dart' show Color;

import '../../../core/theme/app_colors.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum ConnectorType { type2, ccs, chademo, gbt }

enum ConnectorStatus { available, occupied, reserved, unavailable, faulted }

enum AmenityType { parking, coffee, restroom, wifi, shopping }

enum StationFilterType { type2, ccs, chademo, gbt, ac, dc, available }

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
    // Connector type filters (OR within type group)
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
    MockStation(
      id: 's1',
      name: 'ایستگاه شارژ تهران پارک',
      address: 'تهران، خیابان ولیعصر، پلاک ۱۴۲',
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
    MockStation(
      id: 's2',
      name: 'مرکز شارژ مجتمع آزادی',
      address: 'تهران، میدان آزادی، برج آزادی',
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
    MockStation(
      id: 's3',
      name: 'ایستگاه شارژ هوشمند مدرن',
      address: 'تهران، شهرک غرب، بلوار دادمان',
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
    MockStation(
      id: 's4',
      name: 'ایستگاه شارژ قدیمی مرکز',
      address: 'تهران، خیابان انقلاب، کوچه بهار',
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
    MockStation(
      id: 's5',
      name: 'ایستگاه پرسرعت شمال تهران',
      address: 'تهران، نیاوران، بلوار باهنر',
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
    MockStation(
      id: 's6',
      name: 'شارژ رزیدانس مرزداران',
      address: 'تهران، مرزداران، برج رزیدانس',
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
  ];

  static MockStation? findById(String? id) {
    if (id == null) return null;
    for (final s in stations) {
      if (s.id == id) return s;
    }
    return null;
  }
}
