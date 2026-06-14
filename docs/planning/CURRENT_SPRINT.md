# Sprint 8 – Support Center

## Sprint Goal

Implement a complete customer support experience using mock data.

Users should be able to:

* Browse FAQs
* Search FAQs
* Create support tickets
* View ticket history
* View ticket details

No backend integration is required.

---

## In Scope

### FAQ

* Categories
* Expandable Questions
* Search

Categories:

* Reservations
* Charging
* Wallet
* Payments
* Account

### Ticket Creation

Fields:

* Subject
* Category
* Description

### Ticket History

Statuses:

* Open
* In Progress
* Resolved
* Closed

### Ticket Details

Display:

* Ticket ID
* Created Date
* Category
* Status
* Conversation Timeline

### Contact Support

* Email
* Phone
* WhatsApp (mock)

### States

* Empty
* Loading
* Success

### Localization

* Persian
* English

### Accessibility

* RTL
* Screen Reader Labels

---

## Out of Scope

* Real ticket backend
* Live chat
* Zendesk
* Intercom
* Email sending

---

## Relevant Files

mobile/lib/features/support/**

mobile/lib/core/router/**

mobile/lib/core/l10n/**

---

## Acceptance Criteria

* FAQ implemented
* Search implemented
* Ticket creation implemented
* Ticket history implemented
* Ticket details implemented
* Localization complete
* flutter analyze passes
* APK builds successfully
