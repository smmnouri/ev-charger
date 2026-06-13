enum SupportCategory {
  reservations,
  charging,
  wallet,
  payments,
  account,
}

enum TicketStatus { open, inProgress, resolved, closed }

// ── FAQ ───────────────────────────────────────────────────────────────────────

class FaqItem {
  const FaqItem({required this.id, required this.question, required this.answer});

  final String id;
  final String question;
  final String answer;
}

class FaqCategory {
  const FaqCategory({required this.category, required this.items});

  final SupportCategory category;
  final List<FaqItem> items;
}

// ── Tickets ───────────────────────────────────────────────────────────────────

class TicketMessage {
  const TicketMessage({
    required this.id,
    required this.body,
    required this.timestamp,
    required this.isSupport,
  });

  final String id;
  final String body;
  final DateTime timestamp;
  final bool isSupport;
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.messages,
  });

  final String id;
  final String subject;
  final SupportCategory category;
  final TicketStatus status;
  final DateTime createdAt;
  final List<TicketMessage> messages;
}

// ── Seed data ─────────────────────────────────────────────────────────────────

abstract final class MockSupportData {
  static const contactEmail = 'support@evcharger.ir';
  static const contactPhone = '+98 21 1234 5678';
  static const contactWhatsApp = '+98 912 345 6789';

  static final faqCategories = <FaqCategory>[
    FaqCategory(
      category: SupportCategory.reservations,
      items: [
        const FaqItem(
          id: 'faq-r1',
          question: 'How far in advance can I make a reservation?',
          answer:
              'You can make a reservation up to 7 days in advance. Same-day bookings are also available, subject to connector availability.',
        ),
        const FaqItem(
          id: 'faq-r2',
          question: 'Can I cancel a reservation?',
          answer:
              'Yes. You can cancel a reservation up to 15 minutes before its start time with no penalty. Cancellations within 15 minutes may still hold a small fee.',
        ),
        const FaqItem(
          id: 'faq-r3',
          question: 'What happens if I arrive late?',
          answer:
              'Your reserved connector is held for 10 minutes after the scheduled start. After that the slot may be released to other users.',
        ),
        const FaqItem(
          id: 'faq-r4',
          question: 'How long can I reserve a connector?',
          answer:
              'Reservation durations range from 15 minutes to 2 hours. You can extend an active session if the connector is still available.',
        ),
      ],
    ),
    FaqCategory(
      category: SupportCategory.charging,
      items: [
        const FaqItem(
          id: 'faq-c1',
          question: 'How do I start a charging session?',
          answer:
              'Find a station on the map, tap a connector, and either make a reservation or scan the QR code on the charger. Then tap "Start Charging" in the app.',
        ),
        const FaqItem(
          id: 'faq-c2',
          question: 'Which connector types are supported?',
          answer:
              'The app supports CCS, CHAdeMO, Type 2 (AC), and GB/T connectors. Availability depends on the individual station.',
        ),
        const FaqItem(
          id: 'faq-c3',
          question: 'Why does the energy reading differ from my car?',
          answer:
              'An 88% efficiency factor is applied to account for cable and converter losses. This matches typical real-world AC-to-battery conversion.',
        ),
        const FaqItem(
          id: 'faq-c4',
          question: 'Can I pause my charging session?',
          answer:
              'Pausing is initiated by your vehicle or the charger automatically (e.g. battery full). You cannot manually pause from the app, but you can stop the session at any time.',
        ),
      ],
    ),
    FaqCategory(
      category: SupportCategory.wallet,
      items: [
        const FaqItem(
          id: 'faq-w1',
          question: 'How do I add funds to my wallet?',
          answer:
              'Go to Profile → Wallet → Top Up. Select a preset amount (100K, 200K, 500K, 1M tomans) or enter a custom amount. The minimum top-up is 10,000 tomans.',
        ),
        const FaqItem(
          id: 'faq-w2',
          question: 'What is the held balance?',
          answer:
              'Held balance is an amount temporarily reserved when an active charging session starts. It is released and the actual cost deducted when the session ends.',
        ),
        const FaqItem(
          id: 'faq-w3',
          question: 'When is the charging cost deducted?',
          answer:
              'The exact cost is deducted automatically from your available balance as soon as your charging session completes.',
        ),
      ],
    ),
    FaqCategory(
      category: SupportCategory.payments,
      items: [
        const FaqItem(
          id: 'faq-p1',
          question: 'What payment methods are accepted?',
          answer:
              'All charges are paid from your in-app wallet. You can top up your wallet using the supported payment methods within the app.',
        ),
        const FaqItem(
          id: 'faq-p2',
          question: 'Can I get a refund?',
          answer:
              'Refunds for cancelled reservations are processed automatically. For other disputes, please submit a support ticket and our team will review your case within 3 business days.',
        ),
        const FaqItem(
          id: 'faq-p3',
          question: 'Where can I see my payment history?',
          answer:
              'All transactions are visible under Profile → Wallet. You can filter by credits, debits, or view all transactions.',
        ),
      ],
    ),
    FaqCategory(
      category: SupportCategory.account,
      items: [
        const FaqItem(
          id: 'faq-a1',
          question: 'How do I verify my identity?',
          answer:
              'Go to Profile and tap "Verify Your Identity". You will be guided through uploading your national ID and a selfie. Verification usually takes 2–5 minutes.',
        ),
        const FaqItem(
          id: 'faq-a2',
          question: 'How do I change my phone number?',
          answer:
              'For security reasons, phone number changes require identity verification. Please submit a support ticket and our team will assist you.',
        ),
        const FaqItem(
          id: 'faq-a3',
          question: 'How do I delete my account?',
          answer:
              'Submit a support ticket under the Account category requesting account deletion. We will process the request within 7 business days after confirming your identity.',
        ),
      ],
    ),
  ];

  static final tickets = <SupportTicket>[
    SupportTicket(
      id: 'tkt-004',
      subject: 'Reservation disappeared from the list',
      category: SupportCategory.reservations,
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      messages: [
        TicketMessage(
          id: 'msg-004-1',
          body:
              'I made a reservation at Azadi Station for this afternoon but it no longer appears in my Reservations tab. Please help.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isSupport: false,
        ),
      ],
    ),
    SupportTicket(
      id: 'tkt-003',
      subject: 'Charging session not starting at Tehran Park',
      category: SupportCategory.charging,
      status: TicketStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      messages: [
        TicketMessage(
          id: 'msg-003-1',
          body:
              'When I tap "Start Charging" the app shows "Preparing" for a few seconds and then goes back to the map with no error message.',
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          isSupport: false,
        ),
        TicketMessage(
          id: 'msg-003-2',
          body:
              'Thank you for reaching out. We are checking the connector status at Tehran Park Station and will update you shortly. Could you let us know which connector ID you were using?',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
          isSupport: true,
        ),
        TicketMessage(
          id: 'msg-003-3',
          body: 'It was connector C-02 (CCS). Let me know if you need anything else.',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          isSupport: false,
        ),
      ],
    ),
    SupportTicket(
      id: 'tkt-002',
      subject: 'Wallet top-up not credited',
      category: SupportCategory.payments,
      status: TicketStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      messages: [
        TicketMessage(
          id: 'msg-002-1',
          body: 'I topped up 500,000 tomans two days ago but the balance still shows the old amount.',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          isSupport: false,
        ),
        TicketMessage(
          id: 'msg-002-2',
          body:
              'We have located your transaction. There was a processing delay on our end. The funds have now been manually credited to your wallet. Sorry for the inconvenience.',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          isSupport: true,
        ),
        TicketMessage(
          id: 'msg-002-3',
          body: 'Balance is now showing correctly. Thank you!',
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 20)),
          isSupport: false,
        ),
        TicketMessage(
          id: 'msg-002-4',
          body:
              'Glad to hear that. We have marked this ticket as resolved. Please reach out if you have any other questions.',
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 18)),
          isSupport: true,
        ),
      ],
    ),
    SupportTicket(
      id: 'tkt-001',
      subject: 'App crashes when I tap the Scan tab',
      category: SupportCategory.account,
      status: TicketStatus.closed,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      messages: [
        TicketMessage(
          id: 'msg-001-1',
          body: 'Every time I tap the Scan tab the app crashes immediately. I am using Android 13.',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          isSupport: false,
        ),
        TicketMessage(
          id: 'msg-001-2',
          body:
              'This was a known issue with camera permissions on Android 13. We released a fix in version 1.0.1. Please update the app and let us know if the issue persists.',
          timestamp: DateTime.now().subtract(const Duration(days: 9)),
          isSupport: true,
        ),
      ],
    ),
  ];
}
