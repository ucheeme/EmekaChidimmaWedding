import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/romantic_background.dart';

/// Shown on web when guests open the site without scanning the wedding QR code.
class QrGateScreen extends StatelessWidget {
  const QrGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RomanticBackground(
        gradient: AppColors.gradientProgram,
        showHearts: false,
        showPetals: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 88,
                  color: AppColors.roseGold,
                ),
                const SizedBox(height: 28),
                Text(
                  'Forever Moments',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ivory,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  WeddingConfig.coupleDisplayName,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    letterSpacing: 1.5,
                    color: AppColors.roseGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Please scan the QR code at the wedding to begin your experience.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.ivory.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No app store needed — your browser is all you need.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.mint.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
