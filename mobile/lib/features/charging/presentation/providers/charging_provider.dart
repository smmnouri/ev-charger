import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_charging_session.dart';
import '../../../../features/map/data/mock_station_repository.dart';

// ── Session state ─────────────────────────────────────────────────────────────

class ChargingSessionState {
  const ChargingSessionState({this.session});
  final MockChargingSession? session;

  bool get hasSession => session != null;
}

// ── Session notifier ──────────────────────────────────────────────────────────

class ChargingSessionNotifier extends Notifier<ChargingSessionState> {
  Timer? _timer;
  int _transitionTicks = 0;

  @override
  ChargingSessionState build() {
    ref.onDispose(() => _timer?.cancel());
    return const ChargingSessionState();
  }

  void startSession({
    required String sessionId,
    required String stationId,
    required String connectorId,
  }) {
    if (state.session?.id == sessionId) return;

    final station = MockStationRepository.findById(stationId);
    final connector =
        station?.connectors.where((c) => c.id == connectorId).firstOrNull;

    state = ChargingSessionState(
      session: MockChargingSession(
        id: sessionId,
        stationId: stationId,
        stationName: station?.name ?? stationId,
        connectorId: connectorId,
        connectorTypeLabel: connector?.typeLabel ?? 'CCS DC',
        powerKw: connector?.powerKw ?? 50.0,
        pricePerKwhToman: connector?.pricePerKwhToman ?? 15000,
        startTime: DateTime.now(),
        status: ChargingStatus.preparing,
        elapsedSeconds: 0,
      ),
    );

    _transitionTicks = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer _) {
    final session = state.session;
    if (session == null) return;

    switch (session.status) {
      case ChargingStatus.preparing:
        _transitionTicks++;
        if (_transitionTicks >= 2) {
          _transitionTicks = 0;
          state = ChargingSessionState(
            session: session.copyWith(status: ChargingStatus.starting),
          );
        }
      case ChargingStatus.starting:
        _transitionTicks++;
        if (_transitionTicks >= 3) {
          _transitionTicks = 0;
          state = ChargingSessionState(
            session: session.copyWith(status: ChargingStatus.charging),
          );
        }
      case ChargingStatus.charging:
        state = ChargingSessionState(
          session: session.copyWith(
            elapsedSeconds: session.elapsedSeconds + 1,
          ),
        );
      default:
        break;
    }
  }

  void stopCharging() {
    final session = state.session;
    if (session == null) return;
    _timer?.cancel();
    state = ChargingSessionState(
      session: session.copyWith(status: ChargingStatus.finishing),
    );
    Timer(const Duration(seconds: 2), () {
      final current = state.session;
      if (current == null) return;
      final entry = ChargingHistoryEntry(
        id: current.id,
        stationName: current.stationName,
        connectorTypeLabel: current.connectorTypeLabel,
        startTime: current.startTime,
        durationSeconds: current.elapsedSeconds,
        energyKwh: current.energyKwh,
        totalCostToman: current.estimatedCostToman,
        powerKw: current.powerKw,
      );
      ref.read(chargingHistoryProvider.notifier).add(entry);
      state = ChargingSessionState(
        session: current.copyWith(status: ChargingStatus.completed),
      );
    });
  }

  void emergencyStop() {
    _timer?.cancel();
    final session = state.session;
    if (session == null) return;
    state = ChargingSessionState(
      session: session.copyWith(status: ChargingStatus.failed),
    );
  }

  void clearSession() {
    _timer?.cancel();
    state = const ChargingSessionState();
  }
}

final chargingSessionProvider =
    NotifierProvider<ChargingSessionNotifier, ChargingSessionState>(
  ChargingSessionNotifier.new,
);

// ── History notifier ──────────────────────────────────────────────────────────

class ChargingHistoryNotifier extends Notifier<List<ChargingHistoryEntry>> {
  @override
  List<ChargingHistoryEntry> build() =>
      List.of(MockChargingHistory.seedEntries);

  void add(ChargingHistoryEntry entry) {
    state = [entry, ...state];
  }
}

final chargingHistoryProvider =
    NotifierProvider<ChargingHistoryNotifier, List<ChargingHistoryEntry>>(
  ChargingHistoryNotifier.new,
);
