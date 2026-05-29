import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/romantic_background.dart';

/// Cinematic wedding intro before the love story journey.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RomanticBackground(
        gradient: AppColors.gradientProgram,
        showPetals: true,
        backgroundImage: AppAssets.embrace,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  WeddingConfig.coupleDisplayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 900.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                Text(
                  'are getting married',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    letterSpacing: 3,
                    color: AppColors.ivory.withValues(alpha: 0.9),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 700.ms),
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 1,
                  color: AppColors.roseGold,
                ).animate().scaleX(begin: 0, duration: 800.ms, delay: 500.ms),
                const SizedBox(height: 32),
                Text(
                  'Join us on a journey through our love story, '
                  'our favourite memories, and a day we will cherish forever.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.ivory.withValues(alpha: 0.92),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 800.ms),
                const Spacer(flex: 3),
                PremiumButton(
                  label: 'Begin Our Story',
                  icon: Icons.auto_stories_outlined,
                  onPressed: () => context.go(RoutePaths.loveStory),
                ),
                const SizedBox(height: 16),
                PremiumButton(
                  label: 'Skip to Capture Moments',
                  icon: Icons.camera_alt_outlined,
                  outlined: true,
                  onPressed: () => context.go(RoutePaths.home),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
