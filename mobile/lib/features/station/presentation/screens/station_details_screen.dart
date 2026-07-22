import 'package:flutter/material.dart';

import '../../../map/data/mock_station_repository.dart';
import '../../../map/presentation/widgets/share_station_button.dart';

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key, required this.stationId});
  final String stationId;

  @override
  Widget build(BuildContext context) {
    final matched = MockStationRepository.stations.where((s) => s.id == stationId);
    final station = matched.isEmpty ? null : matched.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        title: Text(station?.name ?? 'ایستگاه'),
        backgroundColor: const Color(0xFF141929),
        foregroundColor: Colors.white,
        actions: [
          if (station != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ShareStationButton(station: station, size: 36),
            ),
        ],
      ),
      body: Center(
        child: Text(
          station?.name ?? 'Station $stationId',
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
