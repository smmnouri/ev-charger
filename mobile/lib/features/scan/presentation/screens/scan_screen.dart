import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

// ── Mock connector preview data ───────────────────────────────────────────────

const _kMockStationName = 'ایستگاه میدان ونک';
const _kMockConnectorId = 'DC-02';
const _kMockConnectorType = 'CCS DC';
const _kMockPowerKw = 150;
const _kMockStationId = 's1';
const _kMockConnectorDbId = 's1c1';

// ── Scan step state ───────────────────────────────────────────────────────────

enum _ScanStep { idle, scanning, preview }

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  _ScanStep _step = _ScanStep.idle;

  // Scanning line animation
  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLineAnim;

  // Corner pulse animation
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.05, end: 0.9).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onDemoTapped() {
    if (_step != _ScanStep.idle) return;
    setState(() => _step = _ScanStep.scanning);

    // Simulate scan delay
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _step = _ScanStep.preview);
    });
  }

  void _onStartCharging() {
    final sessionId = 'qr-${DateTime.now().millisecondsSinceEpoch}';
    context.push(
      '/charging/$sessionId?stationId=$_kMockStationId&connectorId=$_kMockConnectorDbId',
    );
  }

  void _onDismissPreview() {
    setState(() => _step = _ScanStep.idle);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────────
          Column(
            children: [
              SizedBox(height: topPadding + 8),
              // Title bar
              _TitleBar(l10n: l10n),
              const SizedBox(height: 32),
              // QR scanner frame
              Expanded(
                child: _ScannerFrame(
                  step: _step,
                  scanLineAnim: _scanLineAnim,
                  pulseAnim: _pulseAnim,
                  l10n: l10n,
                ),
              ),
              const SizedBox(height: 24),
              // Instructions + demo card
              _BottomSection(
                step: _step,
                onDemoTap: _onDemoTapped,
                l10n: l10n,
              ),
              const SizedBox(height: 100), // nav bar clearance
            ],
          ),

          // ── Connector preview sheet ───────────────────────────────────────
          if (_step == _ScanStep.preview)
            _ConnectorPreviewSheet(
              l10n: l10n,
              onStartCharging: _onStartCharging,
              onDismiss: _onDismissPreview,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Title bar
// ─────────────────────────────────────────────────────────────────────────────

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.scanTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanner frame
// ─────────────────────────────────────────────────────────────────────────────

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({
    required this.step,
    required this.scanLineAnim,
    required this.pulseAnim,
    required this.l10n,
  });

  final _ScanStep step;
  final Animation<double> scanLineAnim;
  final Animation<double> pulseAnim;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final frameSize = MediaQuery.sizeOf(context).width * 0.72;

    return Center(
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          children: [
            // Dark translucent background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: step == _ScanStep.scanning
                      ? AppColors.secondary.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Corner brackets
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, _) => CustomPaint(
                size: Size(frameSize, frameSize),
                painter: _CornerBracketsPainter(
                  color: step == _ScanStep.scanning
                      ? AppColors.secondary
                      : AppColors.secondary.withValues(alpha: pulseAnim.value),
                  strokeWidth: 3.5,
                  bracketLength: 28,
                  borderRadius: 6,
                ),
              ),
            ),

            // Scanning line
            if (step != _ScanStep.preview)
              AnimatedBuilder(
                animation: scanLineAnim,
                builder: (_, _) => Positioned(
                  top: frameSize * scanLineAnim.value,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.secondary.withValues(alpha: 0.9),
                          AppColors.secondary,
                          AppColors.secondary.withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),

            // Scanning state overlay
            if (step == _ScanStep.scanning)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.scanScanning,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Success checkmark (brief)
            if (step == _ScanStep.preview)
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Corner brackets painter
// ─────────────────────────────────────────────────────────────────────────────

class _CornerBracketsPainter extends CustomPainter {
  const _CornerBracketsPainter({
    required this.color,
    required this.strokeWidth,
    required this.bracketLength,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double bracketLength;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final r = borderRadius;
    final b = bracketLength;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(r, 0)
        ..lineTo(b, 0)
        ..moveTo(0, r)
        ..lineTo(0, b),
      paint,
    );
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), math.pi, math.pi / 2, false, paint);

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - b, 0)
        ..lineTo(w - r, 0)
        ..moveTo(w, r)
        ..lineTo(w, b),
      paint,
    );
    canvas.drawArc(Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2), -math.pi / 2, math.pi / 2, false, paint);

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, h - b)
        ..lineTo(0, h - r)
        ..moveTo(r, h)
        ..lineTo(b, h),
      paint,
    );
    canvas.drawArc(Rect.fromLTWH(0, h - r * 2, r * 2, r * 2), math.pi / 2, math.pi / 2, false, paint);

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w - b, h)
        ..lineTo(w - r, h)
        ..moveTo(w, h - b)
        ..lineTo(w, h - r),
      paint,
    );
    canvas.drawArc(Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2), 0, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(_CornerBracketsPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom section: instructions + demo card + camera button
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.step,
    required this.onDemoTap,
    required this.l10n,
  });

  final _ScanStep step;
  final VoidCallback onDemoTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions text
          Text(
            l10n.scanInstructions,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Demo card
          Semantics(
            label: l10n.scanDemo,
            hint: l10n.scanDemoHint,
            button: true,
            enabled: step == _ScanStep.idle,
            child: GestureDetector(
              onTap: step == _ScanStep.idle ? onDemoTap : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: step == _ScanStep.idle ? 1.0 : 0.45,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: AppRadius.rLg,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.scanDemo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.scanDemoHint,
                              style: const TextStyle(
                                color: AppColors.textTertiaryDark,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.secondary.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Open camera button (disabled in MVP — shows coming soon snackbar)
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'دوربین واقعی در نسخه بعدی',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.surfaceDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: Text(l10n.scanOpenCamera),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondaryDark,
              side: BorderSide(
                color: AppColors.outlineDark.withValues(alpha: 0.5),
              ),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connector preview bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectorPreviewSheet extends StatelessWidget {
  const _ConnectorPreviewSheet({
    required this.l10n,
    required this.onStartCharging,
    required this.onDismiss,
  });

  final AppLocalizations l10n;
  final VoidCallback onStartCharging;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.5),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              // Prevent taps inside the sheet from dismissing
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + bottomPadding + 100, // nav bar clearance
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: AppColors.outlineDark.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detected label
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.rFull,
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.secondary,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.scanDetected,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Station name
                    Text(
                      _kMockStationName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantDark,
                        borderRadius: AppRadius.rMd,
                        border: Border.all(
                          color: AppColors.outlineDark.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: l10n.scanConnectorTitle,
                            value: _kMockConnectorId,
                            valueColor: AppColors.textPrimaryDark,
                          ),
                          Divider(
                            height: 16,
                            color: AppColors.outlineDark.withValues(alpha: 0.5),
                          ),
                          _InfoRow(
                            label: l10n.scanTypeLabel,
                            value: _kMockConnectorType,
                            valueColor: AppColors.textPrimaryDark,
                          ),
                          Divider(
                            height: 16,
                            color: AppColors.outlineDark.withValues(alpha: 0.5),
                          ),
                          _InfoRow(
                            label: l10n.scanPowerLabel,
                            value: '$_kMockPowerKw kW',
                            valueColor: AppColors.statusCharging,
                          ),
                          Divider(
                            height: 16,
                            color: AppColors.outlineDark.withValues(alpha: 0.5),
                          ),
                          _InfoRow(
                            label: 'وضعیت',
                            value: l10n.scanAvailable,
                            valueColor: AppColors.statusAvailable,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Start charging CTA
                    Semantics(
                      button: true,
                      label: l10n.scanStartCharging,
                      child: ElevatedButton.icon(
                        onPressed: onStartCharging,
                        icon: const Icon(Icons.bolt_rounded, size: 20),
                        label: Text(
                          l10n.scanStartCharging,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onSecondary,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiaryDark,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
