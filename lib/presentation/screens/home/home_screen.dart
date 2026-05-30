import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/add_to_home_screen_banner.dart';
import '../../widgets/app_image.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nav_buttons.dart';
import '../../widgets/romantic_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Forever Moments'),
        actions: [
          const AppNavActions(),
          IconButton(
            icon: const Icon(Icons.tv_outlined),
            tooltip: 'Wedding Wall',
            onPressed: () => context.push(RoutePaths.weddingWall),
          ),
        ],
      ),
      body: RomanticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 1.5,
                      color: AppColors.roseGold,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'WELCOME',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                        color: AppColors.roseGold,
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                Text(
                  WeddingConfig.coupleDisplayName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepWine,
                    height: 1.05,
                  ),
                ).animate().fadeIn().slideX(begin: -0.05),
                const SizedBox(height: 6),
                Text(
                  'Capture & share moments from our special day.',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.deepWine.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 16),
                const _HomeHeroStrip()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                const SizedBox(height: 18),
                const AddToHomeScreenBanner(),
                const _ProgramBanner()
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 500.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.92,
                    children: [
                      _HomeActionCard(
                        icon: Icons.photo_camera_rounded,
                        title: 'Take Picture',
                        subtitle: 'Capture a memory',
                        accent: AppColors.roseGold,
                        delay: 200,
                        onTap: () => context.push(RoutePaths.capturePhoto),
                      ),
                      _HomeActionCard(
                        icon: Icons.videocam_rounded,
                        title: 'Record Video',
                        subtitle: 'Up to 30 seconds',
                        accent: AppColors.wine,
                        delay: 300,
                        onTap: () => context.push(RoutePaths.captureVideo),
                      ),
                      _HomeActionCard(
                        icon: Icons.grid_view_rounded,
                        title: 'View Gallery',
                        subtitle: 'Live guest uploads',
                        accent: AppColors.olive,
                        delay: 400,
                        onTap: () => context.push(RoutePaths.liveGallery),
                      ),
                      _HomeActionCard(
                        icon: Icons.favorite_rounded,
                        title: 'Leave a Message',
                        subtitle: 'Share your wishes',
                        accent: AppColors.olive,
                        accentSoft: true,
                        delay: 500,
                        onTap: () => context.push(RoutePaths.guestMessage),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.push(RoutePaths.loveStory),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.deepWine,
                    ),
                    icon: const Icon(Icons.auto_stories_outlined, size: 18),
                    label: const Text('Revisit our love story'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeroStrip extends StatelessWidget {
  const _HomeHeroStrip();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 104,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const KenBurnsImage(source: AppAssets.white1, maxScale: 1.15),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.noir.withValues(alpha: 0.7),
                    AppColors.noir.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our special day',
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.champagne,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thank you for celebrating with us',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}

class _ProgramBanner extends StatelessWidget {
  const _ProgramBanner();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push(RoutePaths.program),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.wine,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.wine.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order of Program',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepWine,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Church order of service & reception schedule',
                  style: GoogleFonts.lato(
                    fontSize: 11.5,
                    color: AppColors.deepWine.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.deepWine.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    required this.delay,
    this.accentSoft = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool accentSoft;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final chipColor = accentSoft ? AppColors.mint : accent;
    final iconColor = accentSoft ? AppColors.olive : Colors.white;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: chipColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: AppColors.deepWine.withValues(alpha: 0.35),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepWine,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 11.5,
                  color: AppColors.deepWine.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.12, curve: Curves.easeOutCubic);
  }
}
