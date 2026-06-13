import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_support.dart';

// ── FAQ search ────────────────────────────────────────────────────────────────

class FaqSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
  void clear() => state = '';
}

final faqSearchProvider =
    NotifierProvider<FaqSearchNotifier, String>(FaqSearchNotifier.new);

final filteredFaqProvider = Provider<List<FaqCategory>>((ref) {
  final query = ref.watch(faqSearchProvider).toLowerCase().trim();
  if (query.isEmpty) return MockSupportData.faqCategories;
  return MockSupportData.faqCategories
      .map(
        (cat) => FaqCategory(
          category: cat.category,
          items: cat.items
              .where(
                (item) =>
                    item.question.toLowerCase().contains(query) ||
                    item.answer.toLowerCase().contains(query),
              )
              .toList(),
        ),
      )
      .where((cat) => cat.items.isNotEmpty)
      .toList();
});

// ── Tickets ───────────────────────────────────────────────────────────────────

class TicketNotifier extends Notifier<List<SupportTicket>> {
  @override
  List<SupportTicket> build() => List.of(MockSupportData.tickets);

  void createTicket({
    required String subject,
    required SupportCategory category,
    required String description,
  }) {
    final id = 'tkt-${(state.length + 1).toString().padLeft(3, '0')}';
    final now = DateTime.now();
    final ticket = SupportTicket(
      id: id,
      subject: subject,
      category: category,
      status: TicketStatus.open,
      createdAt: now,
      messages: [
        TicketMessage(
          id: 'msg-$id-1',
          body: description,
          timestamp: now,
          isSupport: false,
        ),
      ],
    );
    state = [ticket, ...state];
  }
}

final ticketProvider =
    NotifierProvider<TicketNotifier, List<SupportTicket>>(TicketNotifier.new);
