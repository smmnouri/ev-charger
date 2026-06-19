import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _fadeInCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go(AppRoutes.map);
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _floatCtrl.dispose();
    _fadeInCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topPad = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF060D09),
      body: Stack(
        children: [
          // ── Background: diagonal dark-green gradient ──────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF0A1F0D), // dark forest green (top-right)
                  Color(0xFF07100B), // deep green-black (centre)
                  Color(0xFF040A06), // near-black (bottom-left)
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Top-right atmospheric green bloom
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 420,
              height: 420,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x5022C55E), Colors.transparent],
                ),
              ),
            ),
          ),

          // Mid-screen radial glow — "emanates" from the neon ring
          Positioned(
            top: size.height * 0.28,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size.width * 1.1,
                height: size.width * 1.1,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x3000FF80), Colors.transparent],
                    radius: 0.60,
                  ),
                ),
              ),
            ),
          ),

          // Bottom floor reflection
          Positioned(
            bottom: 0,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x2000FF7F), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Floating location pins ────────────────────────────────────────
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, _) {
              final t = _floatCtrl.value;
              return Stack(
                children: [
                  Positioned(
                    top: topPad + size.height * 0.19 + 9 * t,
                    right: 38,
                    child: _Pin(size: 22, opacity: 0.55, color: AppColors.brandCyan),
                  ),
                  Positioned(
                    top: size.height * 0.43 - 7 * t,
                    left: 24,
                    child: _Pin(size: 17, opacity: 0.38, color: AppColors.brandGreen),
                  ),
                  Positioned(
                    top: size.height * 0.61 + 5 * t,
                    right: 32,
                    child: _Pin(size: 15, opacity: 0.30, color: AppColors.brandCyan),
                  ),
                  Positioned(
                    bottom: bottomPad + size.height * 0.25 - 4 * t,
                    left: 48,
                    child: _Pin(size: 19, opacity: 0.42, color: AppColors.brandGreen),
                  ),
                ],
              );
            },
          ),

          // ── Main content ──────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeInCtrl,
            child: Column(
              children: [
                SizedBox(height: topPad + 24),

                // Logo row: circle icon ＋ wordmark ＋ tagline
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular green logo with bolt
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'EV',
                                style: TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'charge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'شارژ هوشمند، آینده سبز',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Neon ring with EV car + lightning bolt
                AnimatedBuilder(
                  animation: _ringCtrl,
                  builder: (_, _) {
                    final ringSize = size.width * 0.74;
                    return SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: CustomPaint(
                        painter: _NeonRingPainter(animValue: _ringCtrl.value),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Car silhouette — white with slight green tint
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (b) => const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFEEFFEE), Color(0xFFCCFFDD)],
                                ).createShader(b),
                                child: Icon(
                                  Icons.electric_car_rounded,
                                  size: ringSize * 0.50,
                                ),
                              ),
                              // Large lightning bolt in front
                              Positioned(
                                top: ringSize * 0.12,
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (b) => const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFADFF2F), Color(0xFF22C55E)],
                                  ).createShader(b),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: ringSize * 0.44,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Bottom: "در مسیر انرژی پاک" with decorative lines
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0x6022C55E)],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'در مسیر انرژی پاک',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0x6022C55E), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: bottomPad + 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Pin extends StatelessWidget {
  const _Pin({required this.size, required this.opacity, required this.color});
  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity,
        child: Icon(Icons.location_on, color: color, size: size),
      );
}

class _NeonRingPainter extends CustomPainter {
  const _NeonRingPainter({required this.animValue});
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.46;

    // Outer atmospheric haze
    canvas.drawCircle(
      center,
      radius + 35,
      Paint()
        ..color = const Color(0x1800FF7F)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    // Stacked glow halos (soft neon bloom)
    for (int i = 5; i >= 1; i--) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Color.fromARGB((9 * i).clamp(0, 255), 0, 255, 120)
          ..strokeWidth = 2.5 * i + 3
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 * i),
      );
    }

    // Core ring — rotating sweep gradient (green → yellow-green → cyan)
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: const [
            Color(0xFF00FFB0), // cyan-green
            Color(0xFFADFF2F), // yellow-green
            Color(0xFF00FF7F), // bright green
            Color(0xFF00FFCC), // cyan
            Color(0xFF00FFB0),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          transform: GradientRotation(animValue * 2 * math.pi),
        ).createShader(rect)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Travelling bright dot on the ring
    final angle = animValue * 2 * math.pi;
    canvas.drawCircle(
      Offset(center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle)),
      5,
      Paint()
        ..color = const Color(0xDDFFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_NeonRingPainter old) => old.animValue != animValue;
}
