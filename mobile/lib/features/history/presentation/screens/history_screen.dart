import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.history_rounded, color: AppColors.secondary, size: 40),
            ),
            const SizedBox(height: 16),
            Text('به زودی', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
