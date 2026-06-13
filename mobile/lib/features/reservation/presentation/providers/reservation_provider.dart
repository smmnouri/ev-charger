import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_reservation_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ReservationState {
  const ReservationState({required this.reservations});
  final List<MockReservation> reservations;

  ReservationState copyWith({List<MockReservation>? reservations}) =>
      ReservationState(reservations: reservations ?? this.reservations);
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ReservationNotifier extends Notifier<ReservationState> {
  @override
  ReservationState build() =>
      ReservationState(reservations: MockReservationRepository.seedReservations);

  void addReservation(MockReservation reservation) {
    state = state.copyWith(
      reservations: [reservation, ...state.reservations],
    );
  }

  void cancelReservation(String id) {
    state = state.copyWith(
      reservations: state.reservations.map((r) {
        if (r.id != id) return r;
        return r.copyWith(status: ReservationStatus.cancelled);
      }).toList(),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final reservationProvider =
    NotifierProvider<ReservationNotifier, ReservationState>(
  ReservationNotifier.new,
);
