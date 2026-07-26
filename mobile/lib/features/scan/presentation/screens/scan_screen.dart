import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

// ── Mock data shown after any QR code is detected ────────────────────────────

const _kMockStationName = 'ایستگاه میدان ونک';
const _kMockConnectorId = 'DC-02';
const _kMockConnectorType = 'CCS DC';
const _kMockPowerKw = 150;
const _kMockStationId = 's1';
const _kMockConnectorDbId = 's1c1';

// ── States ────────────────────────────────────────────────────────────────────

enum _ScanStep { scanning, preview }

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  _ScanStep _step = _ScanStep.scanning;
  bool _detected = false;

  final _scannerCtrl = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // Scan line animation
  late final AnimationController _lineCtrl;
  late final Animation<double> _lineAnim;

  // Corner bracket pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _lineAnim = Tween<double>(begin: 0.05, end: 0.9).animate(
      CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut),
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
    _scannerCtrl.dispose();
    _lineCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected || _step == _ScanStep.preview) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _detected = true;
    _scannerCtrl.stop();
    setState(() => _step = _ScanStep.preview);
  }

  void _onStartCharging() {
    final sessionId = 'qr-${DateTime.now().millisecondsSinceEpoch}';
    context.push(
      '/charging/$sessionId?stationId=$_kMockStationId&connectorId=$_kMockConnectorDbId',
    );
  }

  void _onDismissPreview() {
    _detected = false;
    _scannerCtrl.start();
    setState(() => _step = _ScanStep.scanning);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    final size = MediaQuery.sizeOf(context);
    final frameSize = size.width * 0.72;
    final frameTop = topPad + 80 + 32.0; // below title bar
    final frameLeft = (size.width - frameSize) / 2;
    final frameRect = Rect.fromLTWH(frameLeft, frameTop, frameSize, frameSize);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed (full screen) ────────────────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerCtrl,
              onDetect: _onDetect,
            ),
          ),

          // ── Dark scrim with transparent hole ────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _ScrimPainter(frameRect: frameRect),
            ),
          ),

          // ── Corner brackets + scan line inside the frame ─────────────────
          Positioned(
            top: frameTop,
            left: frameLeft,
            child: SizedBox(
              width: frameSize,
              height: frameSize,
              child: Stack(
                children: [
                  // Corner brackets
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, _) => CustomPaint(
                      size: Size(frameSize, frameSize),
                      painter: _CornerBracketsPainter(
                        color: _step == _ScanStep.scanning
                            ? AppColors.secondary
                            : AppColors.secondary.withValues(alpha: _pulseAnim.value),
                        strokeWidth: 3.5,
                        bracketLength: 28,
                        borderRadius: 6,
                      ),
                    ),
                  ),

                  // Scan line (only while scanning)
                  if (_step == _ScanStep.scanning)
                    AnimatedBuilder(
                      animation: _lineAnim,
                      builder: (_, _) => Positioned(
                        top: frameSize * _lineAnim.value,
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
                ],
              ),
            ),
          ),

          // ── Title bar ────────────────────────────────────────────────────
          Positioned(
            top: topPad + 12,
            left: 0,
            right: 0,
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

          // ── Instructions below frame ─────────────────────────────────────
          Positioned(
            top: frameTop + frameSize + 28,
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            child: Text(
              l10n.scanInstructions,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Connector preview sheet ──────────────────────────────────────
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
// Scrim painter — dark overlay with a transparent rounded-rect hole
// ─────────────────────────────────────────────────────────────────────────────

class _ScrimPainter extends CustomPainter {
  const _ScrimPainter({required this.frameRect});
  final Rect frameRect;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(20)));
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.72),
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.frameRect != frameRect;
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
// Connector preview bottom sheet — shown after a QR code is detected
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
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + bottomPadding + 100,
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

                    // "Detected" badge
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

                    const Text(
                      _kMockStationName,
                      style: TextStyle(
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
