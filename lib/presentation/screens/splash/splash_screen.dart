import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/constants/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/romantic_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _navTimer = Timer(const Duration(seconds: 5), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    context.go(RoutePaths.intro);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RomanticBackground(
        gradient: AppColors.gradientProgram,
        showHearts: false,
        showPetals: true,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RingAnimation(controller: _ringController),
                  const SizedBox(height: 40),
                  Text(
                    'Forever Moments',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roseGold,
                      letterSpacing: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 20),
                  AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        WeddingConfig.splashWelcome,
                        textStyle: GoogleFonts.lato(
                          fontSize: 16,
                          color: AppColors.ivory.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                        duration: const Duration(milliseconds: 2200),
                      ),
                    ],
                    totalRepeatCount: 1,
                    isRepeatingAnimation: false,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.roseGold.withValues(alpha: 0.7),
                    ),
                  ).animate().fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingAnimation extends StatelessWidget {
  const _RingAnimation({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: controller.value * 2 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.roseGold.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.diamond_outlined,
                      color: AppColors.roseGold.withValues(alpha: 0.9),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.favorite,
                size: 44,
                color: AppColors.wine,
              ),
            ],
          ),
        );
      },
    );
  }
}
