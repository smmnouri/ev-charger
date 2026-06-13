import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class ChargingHubScreen extends StatelessWidget {
  const ChargingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chargingTitle)),
      body: Center(child: Text(l10n.chargingTitle)),
    );
  }
}
