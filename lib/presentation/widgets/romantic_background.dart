import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'animations/falling_petals.dart';
import 'animations/floating_hearts.dart';
import 'app_image.dart';

/// Layered romantic background with optional particles and a photo backdrop.
class RomanticBackground extends StatelessWidget {
  const RomanticBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.gradientRomantic,
    this.showHearts = true,
    this.showPetals = false,
    this.dark = false,
    this.backgroundImage,
    this.imageOverlayOpacity = 0.72,
  });

  final Widget child;
  final Gradient gradient;
  final bool showHearts;
  final bool showPetals;
  final bool dark;

  /// Optional asset/URL rendered behind the content with a slow Ken Burns pan.
  final String? backgroundImage;

  /// Strength of the dark scrim over [backgroundImage] to keep text legible.
  final double imageOverlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: dark ? AppColors.gradientNight : gradient,
          ),
        ),
        if (backgroundImage != null) ...[
          KenBurnsImage(source: backgroundImage!, maxScale: 1.18),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.noir.withValues(alpha: imageOverlayOpacity * 0.9),
                  AppColors.noir.withValues(alpha: imageOverlayOpacity),
                  AppColors.noir.withValues(alpha: imageOverlayOpacity + 0.12),
                ],
              ),
            ),
          ),
        ],
        if (showHearts) const FloatingHearts(),
        if (showPetals) const FallingPetals(),
        child,
      ],
    );
  }
}
