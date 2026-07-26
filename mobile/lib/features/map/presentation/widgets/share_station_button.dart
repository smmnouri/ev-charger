import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/station_share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_station_repository.dart';

/// One-tap share button for a charging station.
///
/// Renders a small icon container that invokes [StationShareService.shareStation]
/// on tap, triggering the native OS share sheet with station name, address,
/// connector types, availability status, and OpenStreetMap / Google Maps links.
class ShareStationButton extends StatelessWidget {
  const ShareStationButton({
    super.key,
    required this.station,
    this.size = 34.0,
  });

  final MockStation station;

  /// Box size of the button in logical pixels (icon is ~16 px inside).
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.shareStationLabel,
      button: true,
      child: GestureDetector(
        onTap: () => StationShareService.shareStation(station),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.ios_share_rounded,
            color: AppColors.primary,
            size: 16,
          ),
        ),
      ),
    );
  }
}
