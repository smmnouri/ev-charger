import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

// ── Mock data ────────────────────────────────────────────────────────────────

enum _StationStatus { available, busy, offline }

class _Station {
  const _Station({
    required this.name,
    required this.distance,
    required this.totalChargers,
    required this.availableChargers,
    required this.status,
    required this.connectorType,
    required this.pricePerKwh,
    required this.pinX,
    required this.pinY,
  });

  final String name;
  final String distance;
  final int totalChargers;
  final int availableChargers;
  final _StationStatus status;
  final String connectorType;
  final String pricePerKwh;
  final double pinX; // fraction of screen width
  final double pinY; // fraction of screen height
}

const _kStations = [
  _Station(
    name: 'ایستگاه شارژ تهران پارک',
    distance: '۰.۸ کیلومتر',
    totalChargers: 6,
    availableChargers: 4,
    status: _StationStatus.available,
    connectorType: 'CCS',
    pricePerKwh: '۴۵۰ تومان/کیلووات‌ساعت',
    pinX: 0.28,
    pinY: 0.34,
  ),
  _Station(
    name: 'مرکز شارژ آزادی',
    distance: '۱.۲ کیلومتر',
    totalChargers: 8,
    availableChargers: 0,
    status: _StationStatus.busy,
    connectorType: 'Type 2',
    pricePerKwh: '۳۸۰ تومان/کیلووات‌ساعت',
    pinX: 0.68,
    pinY: 0.42,
  ),
  _Station(
    name: 'ایستگاه شارژ مدرن',
    distance: '۲.۱ کیلومتر',
    totalChargers: 4,
    availableChargers: 3,
    status: _StationStatus.available,
    connectorType: 'CHAdeMO',
    pricePerKwh: '۵۲۰ تومان/کیلووات‌ساعت',
    pinX: 0.52,
    pinY: 0.25,
  ),
  _Station(
    name: 'ایستگاه قدیمی مرکز',
    distance: '۳.۵ کیلومتر',
    totalChargers: 3,
    availableChargers: 0,
    status: _StationStatus.offline,
    connectorType: 'GB/T',
    pricePerKwh: '—',
    pinX: 0.16,
    pinY: 0.50,
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    // Reserve space for floating nav (64dp) + 12dp margin + 12dp gap above nav
    const navBarHeight = 64.0 + 12.0 + 12.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBody: true,
      body: Stack(
        children: [
          // ── Layer 0: Full-screen mock map ─────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/mock_map.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, e) => Container(color: AppColors.backgroundDark),
            ),
          ),

          // ── Layer 1: Top gradient scrim ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0.92),
                    AppColors.backgroundDark.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 2: Bottom gradient scrim ────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0.95),
                    AppColors.backgroundDark.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 3: Station pins ─────────────────────────────────────────
          for (int i = 0; i < _kStations.length; i++)
            _buildPin(context, i, size),

          // ── Layer 4: Top UI overlay ───────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GreetingRow(onNotificationTap: () {}),
                const SizedBox(height: 12),
                _SearchBar(),
              ],
            ),
          ),

          // ── Layer 5: Location FAB ─────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: size.height * 0.35 + 12,
            child: _LocationFab(),
          ),

          // ── Layer 6: Station preview sheet ────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.14,
            maxChildSize: 0.68,
            snap: true,
            snapSizes: const [0.14, 0.30, 0.68],
            builder: (ctx, controller) => _StationSheet(
              controller: controller,
              stations: _kStations,
              selectedIndex: _selectedIndex,
              navBarHeight: navBarHeight,
              onStationTap: (i) => setState(() => _selectedIndex = i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPin(BuildContext context, int index, Size size) {
    final station = _kStations[index];
    final color = _statusColor(station.status);
    final isSelected = index == _selectedIndex;
    final pinSize = isSelected ? 42.0 : 36.0;
    final left = station.pinX * size.width - pinSize / 2;
    final top = station.pinY * size.height - pinSize / 2 - 8;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _StationPin(color: color, size: pinSize, isSelected: isSelected),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Color _statusColor(_StationStatus status) => switch (status) {
      _StationStatus.available => AppColors.statusAvailable,
      _StationStatus.busy => AppColors.statusOccupied,
      _StationStatus.offline => AppColors.statusUnavailable,
    };

String _statusLabel(_StationStatus status, AppLocalizations l10n) => switch (status) {
      _StationStatus.available => l10n.stationAvailable,
      _StationStatus.busy => l10n.stationOccupied,
      _StationStatus.offline => l10n.stationUnavailable,
    };

// ── Station Pin ───────────────────────────────────────────────────────────────

class _StationPin extends StatelessWidget {
  const _StationPin({required this.color, required this.size, required this.isSelected});

  final Color color;
  final double size;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.33),
            border: Border.all(color: Colors.white, width: isSelected ? 2 : 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4)),
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14, spreadRadius: -2),
            ],
          ),
          child: Icon(Icons.bolt_rounded, color: Colors.white, size: size * 0.52),
        ),
        CustomPaint(
          size: Size(10, 7),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ── Greeting row ─────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سلام!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'کجا می‌خواهید شارژ کنید؟',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.6)),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimaryDark, size: 20),
          ),
        ),
      ],
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.9),
        borderRadius: AppRadius.rFull,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search_rounded, color: AppColors.textTertiaryDark, size: 20),
          ),
          Expanded(
            child: Text(
              l10n.homeSearchHint,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiaryDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 17),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Location FAB ─────────────────────────────────────────────────────────────

class _LocationFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
    );
  }
}

// ── Station sheet ─────────────────────────────────────────────────────────────

class _StationSheet extends StatelessWidget {
  const _StationSheet({
    required this.controller,
    required this.stations,
    required this.selectedIndex,
    required this.navBarHeight,
    required this.onStationTap,
  });

  final ScrollController controller;
  final List<_Station> stations;
  final int selectedIndex;
  final double navBarHeight;
  final ValueChanged<int> onStationTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 32, offset: const Offset(0, -8))],
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineDark,
                  borderRadius: AppRadius.rFull,
                ),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: 10),
            child: Row(
              children: [
                Text(
                  l10n.homeNearby,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                _FilterChip(label: l10n.homeFilter),
              ],
            ),
          ),

          // Station list
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: EdgeInsets.only(
                top: 4,
                bottom: navBarHeight + 8,
                left: AppSpacing.screenHorizontal,
                right: AppSpacing.screenHorizontal,
              ),
              itemCount: stations.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StationCard(
                  station: stations[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onStationTap(i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: AppRadius.rFull,
        border: Border.all(color: AppColors.outlineDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_rounded, size: 14, color: AppColors.textSecondaryDark),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}

// ── Station card ──────────────────────────────────────────────────────────────

class _StationCard extends StatelessWidget {
  const _StationCard({required this.station, required this.isSelected, required this.onTap});

  final _Station station;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(station.status);
    final label = _statusLabel(station.status, l10n);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceVariantDark : AppColors.surfaceDark,
          borderRadius: AppRadius.rLg,
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineDark.withValues(alpha: 0.4),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Icon
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 22),
                ),
              ),

              // Station info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        station.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimaryDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiaryDark),
                          const SizedBox(width: 2),
                          Text(
                            station.distance,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.electric_bolt, size: 12, color: AppColors.textTertiaryDark),
                          const SizedBox(width: 2),
                          Text(
                            '${station.availableChargers}/${station.totalChargers}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Status badge + reserve button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: AppRadius.rFull,
                      ),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor),
                      ),
                    ),
                    if (station.status == _StationStatus.available) ...[
                      const SizedBox(height: 7),
                      SizedBox(
                        height: 28,
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          child: Text(l10n.homeReserve),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
