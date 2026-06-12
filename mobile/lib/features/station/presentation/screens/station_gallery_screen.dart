import 'package:flutter/material.dart';

class StationGalleryScreen extends StatelessWidget {
  const StationGalleryScreen({
    super.key,
    required this.stationId,
    required this.initialIndex,
  });
  final String stationId;
  final int initialIndex;

  @override
  Widget build(BuildContext context) =>
      _Stub(title: 'Gallery $stationId [$initialIndex]');
}

class _Stub extends StatelessWidget {
  const _Stub({required this.title});
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
