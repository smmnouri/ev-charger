import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اسکن')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text('به زودی', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
