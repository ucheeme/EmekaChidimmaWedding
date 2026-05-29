import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'glass_card.dart';

/// Encourages guests to install the PWA on their home screen (web only).
class AddToHomeScreenBanner extends StatelessWidget {
  const AddToHomeScreenBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.add_to_home_screen_outlined,
              color: AppColors.deepWine.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to Home Screen',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepWine,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _instructions,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.deepWine.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _instructions =
      'iPhone: tap Share, then "Add to Home Screen".\n'
      'Android: tap the menu (⋮), then "Install app" or "Add to Home screen".';
}
