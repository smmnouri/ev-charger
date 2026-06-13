enum TransactionType { topUp, chargingPayment, refund, adjustment }

enum TransactionStatus { completed, pending, failed }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amountToman,
    required this.balanceBeforeToman,
    required this.balanceAfterToman,
    required this.timestamp,
    this.description,
    this.sessionId,
  });

  final String id;
  final TransactionType type;
  final TransactionStatus status;

  /// Positive = credit (top-up, refund). Negative = debit (payment).
  final int amountToman;
  final int balanceBeforeToman;
  final int balanceAfterToman;
  final DateTime timestamp;
  final String? description;
  final String? sessionId;

  bool get isCredit => amountToman > 0;
}

abstract final class MockWalletSeed {
  /// Seed transactions, newest-first.
  static final transactions = <WalletTransaction>[
    WalletTransaction(
      id: 'txn-006',
      type: TransactionType.chargingPayment,
      status: TransactionStatus.completed,
      amountToman: -259000,
      balanceBeforeToman: 1532000,
      balanceAfterToman: 1273000,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      description: 'ایستگاه شارژ تهران پارک – CCS DC',
      sessionId: 'ses-001',
    ),
    WalletTransaction(
      id: 'txn-005',
      type: TransactionType.topUp,
      status: TransactionStatus.completed,
      amountToman: 500000,
      balanceBeforeToman: 1032000,
      balanceAfterToman: 1532000,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
    WalletTransaction(
      id: 'txn-004',
      type: TransactionType.chargingPayment,
      status: TransactionStatus.completed,
      amountToman: -138000,
      balanceBeforeToman: 1170000,
      balanceAfterToman: 1032000,
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      description: 'ایستگاه مال آف ایران – Type 2 AC',
      sessionId: 'ses-002',
    ),
    WalletTransaction(
      id: 'txn-003',
      type: TransactionType.topUp,
      status: TransactionStatus.completed,
      amountToman: 1000000,
      balanceBeforeToman: 170000,
      balanceAfterToman: 1170000,
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
    ),
    WalletTransaction(
      id: 'txn-002',
      type: TransactionType.chargingPayment,
      status: TransactionStatus.completed,
      amountToman: -330000,
      balanceBeforeToman: 500000,
      balanceAfterToman: 170000,
      timestamp: DateTime.now().subtract(const Duration(days: 7, hours: 10)),
      description: 'ایستگاه سعادت‌آباد – CHAdeMO',
      sessionId: 'ses-003',
    ),
    WalletTransaction(
      id: 'txn-001',
      type: TransactionType.topUp,
      status: TransactionStatus.completed,
      amountToman: 500000,
      balanceBeforeToman: 0,
      balanceAfterToman: 500000,
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  static const int initialAvailableToman = 1273000;
  static const int initialHeldToman = 50000;
}
