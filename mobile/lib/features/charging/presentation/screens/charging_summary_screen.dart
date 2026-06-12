import 'package:flutter/material.dart';

class ChargingSummaryScreen extends StatelessWidget {
  const ChargingSummaryScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) =>
      _Stub(title: 'Summary $sessionId');
}

class _Stub extends StatelessWidget {
  const _Stub({required this.title, this.dark = false});
  final String title;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A0F1E) : null,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: dark ? const Color(0xFF141929) : null,
        foregroundColor: dark ? Colors.white : null,
      ),
      body: Center(
        child: Text(
          title,
          style: TextStyle(color: dark ? Colors.white54 : null),
        ),
      ),
    );
  }
}
