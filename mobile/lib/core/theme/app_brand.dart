import 'package:flutter/material.dart';

import 'app_colors.dart';

/// EVcharge brand constants and reusable widgets.
abstract final class AppBrand {
  static const name = 'EVcharge';
  static const taglineFa = 'شارژ هوشمند، آینده سبز';

  // Brand gradient — green → cyan
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brandGreen, AppColors.brandCyan],
  );

  static const gradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.brandGreen, AppColors.brandCyan],
  );
}

/// The EVcharge logo mark: rounded square with green-to-cyan gradient and a bolt.
class EvLogo extends StatelessWidget {
  const EvLogo({super.key, this.size = 88, this.withGlow = false});

  final double size;
  final bool withGlow;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.24;

    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppBrand.gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: AppColors.brandGreen.withValues(alpha: 0.45),
                  blurRadius: size * 0.55,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: AppColors.brandCyan.withValues(alpha: 0.25),
                  blurRadius: size * 0.8,
                  spreadRadius: -8,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Center(
        child: Icon(
          Icons.bolt_rounded,
          color: const Color(0xFF002B1A),
          size: size * 0.54,
        ),
      ),
    );

    return logo;
  }
}

/// Full brand lockup: logo + "EVcharge" wordmark stacked vertically.
class EvBrandLockup extends StatelessWidget {
  const EvBrandLockup({super.key, this.logoSize = 88, this.showTagline = true});

  final double logoSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EvLogo(size: logoSize, withGlow: true),
        SizedBox(height: logoSize * 0.22),
        _EvWordmark(fontSize: logoSize * 0.38),
        if (showTagline) ...[
          SizedBox(height: logoSize * 0.10),
          Text(
            AppBrand.taglineFa,
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: logoSize * 0.18,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// "EV" in brand green + "charge" in white, inline.
class _EvWordmark extends StatelessWidget {
  const _EvWordmark({this.fontSize = 32});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'EV',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: AppColors.brandGreen,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'charge',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient text painter — wraps a [Text] with the brand gradient.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppBrand.gradient.createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
