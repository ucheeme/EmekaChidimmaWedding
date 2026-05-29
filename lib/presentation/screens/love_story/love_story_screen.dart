import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/route_paths.dart';
import '../../../core/content/wedding_content.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubit/content/content_cubit.dart';
import '../../widgets/app_image.dart';
import '../../widgets/nav_buttons.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/romantic_background.dart';

class LoveStoryScreen extends StatefulWidget {
  const LoveStoryScreen({super.key});

  @override
  State<LoveStoryScreen> createState() => _LoveStoryScreenState();
}

class _LoveStoryScreenState extends State<LoveStoryScreen> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = context.watch<ContentCubit>().state.bundle.loveStory;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Our Love Story'),
        actions: const [MusicToggleButton(), HomeIconButton()],
      ),
      body: RomanticBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _PageIndicator(
                count: chapters.length,
                current: _currentPage,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: chapters.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 1;
                        if (_pageController.position.haveDimensions) {
                          final page = _pageController.page ?? index.toDouble();
                          scale = (1 - (page - index).abs() * 0.08).clamp(0.92, 1.0);
                        }
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: _StoryCard(chapter: chapters[index], index: index),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: PremiumButton(
                  label: _currentPage < chapters.length - 1
                      ? 'Continue'
                      : 'View Pre-Wedding Gallery',
                  onPressed: () {
                    if (_currentPage < chapters.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      context.push(RoutePaths.preWeddingGallery);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.chapter, required this.index});

  final LoveStoryChapter chapter;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shadowColor: AppColors.deepWine.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: 'story-image-$index',
                child: KenBurnsImage(source: chapter.imageUrl),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.date,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: AppColors.roseGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapter.title,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepWine,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          chapter.body,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            height: 1.7,
                            color: AppColors.deepWine.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.05);
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: active
                ? AppColors.deepWine
                : AppColors.deepWine.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }
}
