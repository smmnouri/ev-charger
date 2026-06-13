import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../map/data/mock_station_repository.dart';
import '../../data/mock_reservation_repository.dart';
import '../providers/reservation_provider.dart';

// ── Step & option enums ───────────────────────────────────────────────────────

enum _CreateStep { connector, time, summary, success }

enum _StartTimeOption { now, min15, min30, hour1, hour2 }

extension _StartTimeExt on _StartTimeOption {
  int get offsetMinutes => switch (this) {
        _StartTimeOption.now => 0,
        _StartTimeOption.min15 => 15,
        _StartTimeOption.min30 => 30,
        _StartTimeOption.hour1 => 60,
        _StartTimeOption.hour2 => 120,
      };

  String label(AppLocalizations l10n) => switch (this) {
        _StartTimeOption.now => l10n.reservationNowLabel,
        _StartTimeOption.min15 => l10n.reservationIn15,
        _StartTimeOption.min30 => l10n.reservationIn30,
        _StartTimeOption.hour1 => l10n.reservationIn1h,
        _StartTimeOption.hour2 => l10n.reservationIn2h,
      };
}

enum _DurationOption { min15, min30, min45, hour1, hour2 }

extension _DurationExt on _DurationOption {
  int get minutes => switch (this) {
        _DurationOption.min15 => 15,
        _DurationOption.min30 => 30,
        _DurationOption.min45 => 45,
        _DurationOption.hour1 => 60,
        _DurationOption.hour2 => 120,
      };

  String label(AppLocalizations l10n) => switch (this) {
        _DurationOption.min15 => l10n.reservationDur15,
        _DurationOption.min30 => l10n.reservationDur30,
        _DurationOption.min45 => l10n.reservationDur45,
        _DurationOption.hour1 => l10n.reservationDur1h,
        _DurationOption.hour2 => l10n.reservationDur2h,
      };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ReservationCreateScreen extends ConsumerStatefulWidget {
  const ReservationCreateScreen({
    super.key,
    required this.stationId,
    this.preselectedConnectorId,
  });

  final String stationId;
  final String? preselectedConnectorId;

  @override
  ConsumerState<ReservationCreateScreen> createState() =>
      _ReservationCreateScreenState();
}

class _ReservationCreateScreenState
    extends ConsumerState<ReservationCreateScreen> {
  _CreateStep _step = _CreateStep.connector;
  MockConnector? _selectedConnector;
  _StartTimeOption _startTime = _StartTimeOption.now;
  _DurationOption _duration = _DurationOption.min30;

  // Success step state
  String? _confirmedId;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Pre-select connector if provided
    final station = MockStationRepository.findById(widget.stationId);
    if (widget.preselectedConnectorId != null && station != null) {
      final match = station.connectors
          .where((c) => c.id == widget.preselectedConnectorId)
          .firstOrNull;
      if (match != null && match.status == ConnectorStatus.available) {
        _selectedConnector = match;
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  MockStation? get _station => MockStationRepository.findById(widget.stationId);

  int get _estimatedCost {
    final c = _selectedConnector;
    if (c == null) return 0;
    return (c.powerKw * 0.4 * _duration.minutes / 60 * c.pricePerKwhToman)
        .round();
  }

  String get _estimatedKwh {
    final c = _selectedConnector;
    if (c == null) return '0';
    final kwh = c.powerKw * 0.4 * _duration.minutes / 60;
    return kwh.toStringAsFixed(1);
  }

  DateTime get _startDateTime =>
      DateTime.now().add(Duration(minutes: _startTime.offsetMinutes));

  void _confirmReservation() {
    final c = _selectedConnector;
    final station = _station;
    if (c == null || station == null) return;

    final id = 'RES-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final reservation = MockReservation(
      id: id,
      stationId: station.id,
      stationName: station.name,
      connectorId: c.id,
      connectorTypeLabel: c.typeLabel,
      powerKw: c.powerKw,
      startTime: _startDateTime,
      durationMinutes: _duration.minutes,
      status: ReservationStatus.upcoming,
      estimatedCostToman: _estimatedCost,
      distanceFa: station.distanceFa,
      operatorName: station.operatorName,
      pricePerKwhToman: c.pricePerKwhToman,
    );

    ref.read(reservationProvider.notifier).addReservation(reservation);

    final secs = _startTime.offsetMinutes * 60;
    setState(() {
      _confirmedId = id;
      _countdown = secs;
      _step = _CreateStep.success;
    });

    if (secs > 0) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            t.cancel();
          }
        });
      });
    }
  }

  void _advance() {
    setState(() {
      _step = switch (_step) {
        _CreateStep.connector => _CreateStep.time,
        _CreateStep.time => _CreateStep.summary,
        _CreateStep.summary => _CreateStep.success,
        _CreateStep.success => _CreateStep.success,
      };
    });
  }

  void _back() {
    if (_step == _CreateStep.connector) {
      context.pop();
      return;
    }
    setState(() {
      _step = switch (_step) {
        _CreateStep.time => _CreateStep.connector,
        _CreateStep.summary => _CreateStep.time,
        _ => _CreateStep.connector,
      };
    });
  }

  int get _stepNumber => switch (_step) {
        _CreateStep.connector => 1,
        _CreateStep.time => 2,
        _CreateStep.summary => 3,
        _CreateStep.success => 3,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSuccess = _step == _CreateStep.success;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: isSuccess
          ? null
          : AppBar(
              backgroundColor: AppColors.backgroundDark,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: Colors.white),
                onPressed: _back,
              ),
              title: Text(
                l10n.reservationNewTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      l10n.reservationStepOf(_stepNumber, 3),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                  ),
                ),
              ],
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: switch (_step) {
          _CreateStep.connector => _ConnectorStep(
              key: const ValueKey('connector'),
              station: _station,
              selected: _selectedConnector,
              onSelect: (c) => setState(() => _selectedConnector = c),
              onNext: _selectedConnector != null ? _advance : null,
              l10n: l10n,
            ),
          _CreateStep.time => _TimeStep(
              key: const ValueKey('time'),
              startTime: _startTime,
              duration: _duration,
              onStartChanged: (v) => setState(() => _startTime = v),
              onDurationChanged: (v) => setState(() => _duration = v),
              onNext: _advance,
              l10n: l10n,
            ),
          _CreateStep.summary => _SummaryStep(
              key: const ValueKey('summary'),
              station: _station,
              connector: _selectedConnector,
              startDateTime: _startDateTime,
              duration: _duration,
              estimatedCost: _estimatedCost,
              estimatedKwh: _estimatedKwh,
              onConfirm: _confirmReservation,
              l10n: l10n,
            ),
          _CreateStep.success => _SuccessStep(
              key: const ValueKey('success'),
              reservationId: _confirmedId ?? '',
              countdown: _countdown,
              onViewDetails: () {
                context.pop();
                context.push('/reservations/$_confirmedId');
              },
              onClose: () => context.pop(),
              l10n: l10n,
            ),
        },
      ),
    );
  }
}

// ── Step 1: Connector selection ───────────────────────────────────────────────

class _ConnectorStep extends StatelessWidget {
  const _ConnectorStep({
    super.key,
    required this.station,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.l10n,
  });

  final MockStation? station;
  final MockConnector? selected;
  final ValueChanged<MockConnector> onSelect;
  final VoidCallback? onNext;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final connectors = station?.connectors ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            l10n.reservationSelectConnector,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.reservationSelectConnectorHint,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondaryDark),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: connectors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = connectors[i];
              final isAvailable = c.status == ConnectorStatus.available;
              final isSelected = selected?.id == c.id;
              return Semantics(
                label:
                    '${c.typeLabel}, ${c.powerKw.toInt()} kW, ${isAvailable ? l10n.stationAvailable : l10n.stationUnavailable}',
                button: isAvailable,
                selected: isSelected,
                child: GestureDetector(
                  onTap: isAvailable ? () => onSelect(c) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineDark.withValues(alpha: 0.4),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.statusColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              c.isDc
                                  ? Icons.bolt_rounded
                                  : Icons.electrical_services_rounded,
                              color: c.statusColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.typeLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isAvailable
                                          ? Colors.white
                                          : AppColors.textTertiaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c.powerKw.toInt()} kW · ${c.pricePerKwhToman} ${l10n.tomansUnit}/kWh',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: AppColors.textSecondaryDark),
                              ),
                            ],
                          ),
                        ),
                        if (!isAvailable)
                          Text(
                            c.estimatedFreeFa ?? l10n.stationOccupied,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.textTertiaryDark),
                          )
                        else if (isSelected)
                          Text(
                            l10n.reservationConnectorSelected,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.outlineDark,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(l10n.continue_),
          ),
        ),
      ],
    );
  }
}

// ── Step 2: Time & duration ───────────────────────────────────────────────────

class _TimeStep extends StatelessWidget {
  const _TimeStep({
    super.key,
    required this.startTime,
    required this.duration,
    required this.onStartChanged,
    required this.onDurationChanged,
    required this.onNext,
    required this.l10n,
  });

  final _StartTimeOption startTime;
  final _DurationOption duration;
  final ValueChanged<_StartTimeOption> onStartChanged;
  final ValueChanged<_DurationOption> onDurationChanged;
  final VoidCallback onNext;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            l10n.reservationTimeAndDuration,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.reservationStartTime,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.textSecondaryDark),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _StartTimeOption.values.map((opt) {
              final sel = opt == startTime;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  selected: sel,
                  button: true,
                  label: opt.label(l10n),
                  child: GestureDetector(
                    onTap: () => onStartChanged(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : AppColors.outlineDark.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          opt.label(l10n),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: sel
                                    ? Colors.white
                                    : AppColors.textSecondaryDark,
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.reservationDuration,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.textSecondaryDark),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _DurationOption.values.map((opt) {
              final sel = opt == duration;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  selected: sel,
                  button: true,
                  label: opt.label(l10n),
                  child: GestureDetector(
                    onTap: () => onDurationChanged(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : AppColors.outlineDark.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          opt.label(l10n),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: sel
                                    ? Colors.white
                                    : AppColors.textSecondaryDark,
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(l10n.continue_),
          ),
        ),
      ],
    );
  }
}

// ── Step 3: Summary ───────────────────────────────────────────────────────────

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    super.key,
    required this.station,
    required this.connector,
    required this.startDateTime,
    required this.duration,
    required this.estimatedCost,
    required this.estimatedKwh,
    required this.onConfirm,
    required this.l10n,
  });

  final MockStation? station;
  final MockConnector? connector;
  final DateTime startDateTime;
  final _DurationOption duration;
  final int estimatedCost;
  final String estimatedKwh;
  final VoidCallback onConfirm;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            l10n.reservationSummaryStep,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.outlineDark.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: l10n.reservationStationLabel,
                    value: station?.name ?? '',
                  ),
                  const _Divider(),
                  _SummaryRow(
                    label: l10n.reservationConnectorLabel,
                    value: connector?.typeLabel ?? '',
                  ),
                  const _Divider(),
                  _SummaryRow(
                    label: l10n.reservationStartTime,
                    value: _formatTime(startDateTime),
                  ),
                  const _Divider(),
                  _SummaryRow(
                    label: l10n.reservationDuration,
                    value: duration.label(l10n),
                  ),
                  const _Divider(),
                  _SummaryRow(
                    label: l10n.reservationEstCost,
                    value:
                        '$estimatedCost ${l10n.tomansUnit}',
                    highlight: true,
                  ),
                  const _Divider(),
                  _SummaryRow(
                    label: l10n.reservationEstEnergy,
                    value: l10n.reservationEstKwh(estimatedKwh),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(l10n.reservationConfirmCta),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highlight ? AppColors.primary : Colors.white,
                  fontWeight:
                      highlight ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.outlineDark.withValues(alpha: 0.3), height: 1);
}

// ── Step 4: Success ───────────────────────────────────────────────────────────

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({
    super.key,
    required this.reservationId,
    required this.countdown,
    required this.onViewDetails,
    required this.onClose,
    required this.l10n,
  });

  final String reservationId;
  final int countdown;
  final VoidCallback onViewDetails;
  final VoidCallback onClose;
  final AppLocalizations l10n;

  String get _countdownLabel {
    if (countdown <= 0) return l10n.reservationStartsNow;
    final m = countdown ~/ 60;
    final s = countdown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.statusAvailable.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.statusAvailable.withValues(alpha: 0.4),
                    width: 1.5),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.statusAvailable, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.reservationSuccessTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reservationSuccessSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.outlineDark.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.reservationIdLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservationId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.reservationCountdown,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _countdownLabel,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onViewDetails,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.reservationViewDetails),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: AppColors.outlineDark.withValues(alpha: 0.6)),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}
