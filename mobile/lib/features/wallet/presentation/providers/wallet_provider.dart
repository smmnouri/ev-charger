import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_wallet.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class WalletState {
  const WalletState({
    required this.availableToman,
    required this.heldToman,
    required this.transactions,
  });

  final int availableToman;
  final int heldToman;
  final List<WalletTransaction> transactions;

  int get totalToman => availableToman + heldToman;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => WalletState(
        availableToman: MockWalletSeed.initialAvailableToman,
        heldToman: MockWalletSeed.initialHeldToman,
        transactions: List.of(MockWalletSeed.transactions),
      );

  void topUp(int amountToman) {
    final before = state.availableToman;
    final after = before + amountToman;
    final txn = WalletTransaction(
      id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.topUp,
      status: TransactionStatus.completed,
      amountToman: amountToman,
      balanceBeforeToman: before,
      balanceAfterToman: after,
      timestamp: DateTime.now(),
    );
    state = WalletState(
      availableToman: after,
      heldToman: state.heldToman,
      transactions: [txn, ...state.transactions],
    );
  }

  void recordChargingDebit({
    required String sessionId,
    required int amountToman,
    required String description,
  }) {
    final before = state.availableToman;
    final after = (before - amountToman).clamp(0, before);
    final txn = WalletTransaction(
      id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.chargingPayment,
      status: TransactionStatus.completed,
      amountToman: -amountToman,
      balanceBeforeToman: before,
      balanceAfterToman: after,
      timestamp: DateTime.now(),
      description: description,
      sessionId: sessionId,
    );
    state = WalletState(
      availableToman: after,
      heldToman: state.heldToman,
      transactions: [txn, ...state.transactions],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
