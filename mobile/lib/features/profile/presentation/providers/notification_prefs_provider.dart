import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotifPrefsState {
  const NotifPrefsState({
    this.reservations = true,
    this.charging = true,
    this.payments = true,
  });

  final bool reservations;
  final bool charging;
  final bool payments;

  NotifPrefsState copyWith({
    bool? reservations,
    bool? charging,
    bool? payments,
  }) =>
      NotifPrefsState(
        reservations: reservations ?? this.reservations,
        charging: charging ?? this.charging,
        payments: payments ?? this.payments,
      );
}

class NotifPrefsNotifier extends Notifier<NotifPrefsState> {
  @override
  NotifPrefsState build() => const NotifPrefsState();

  void toggleReservations() =>
      state = state.copyWith(reservations: !state.reservations);
  void toggleCharging() =>
      state = state.copyWith(charging: !state.charging);
  void togglePayments() =>
      state = state.copyWith(payments: !state.payments);
}

final notifPrefsProvider =
    NotifierProvider<NotifPrefsNotifier, NotifPrefsState>(
  NotifPrefsNotifier.new,
);
