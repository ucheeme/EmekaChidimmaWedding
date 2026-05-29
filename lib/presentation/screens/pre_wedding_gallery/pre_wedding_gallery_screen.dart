import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/constants/route_paths.dart';
import '../../../core/content/wedding_content.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_image.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/romantic_background.dart';
import '../../widgets/video_showcase.dart';

class PreWeddingGalleryScreen extends StatefulWidget {
  const PreWeddingGalleryScreen({super.key});

  @override
  State<PreWeddingGalleryScreen> createState() =>
      _PreWeddingGalleryScreenState();
}

class _PreWeddingGalleryScreenState extends State<PreWeddingGalleryScreen> {
  final _carouselController = PageController(viewportFraction: 0.82);

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = WeddingContent.preWeddingPhotos;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Pre-Wedding Gallery'),
      ),
      body: RomanticBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    'Moments before forever',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      color: AppColors.deepWine,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: PageView.builder(
                    controller: _carouselController,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _CarouselCard(
                          photo: photo,
                          heroTag: 'gallery-$index',
                          onTap: () => _openFullscreen(context, photo, index),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Gallery',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.roseGold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    final height = index.isEven ? 200.0 : 260.0;
                    return GestureDetector(
                      onTap: () => _openFullscreen(context, photo, index),
                      child: Hero(
                        tag: 'gallery-$index',
                        child: _MasonryTile(photo: photo, height: height),
                      ),
                    ).animate().fadeIn(delay: (index * 80).ms);
                  },
                ),
              ),
              if (WeddingContent.weddingVideos.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Moments in motion',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.roseGold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: WeddingContent.weddingVideos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final video = WeddingContent.weddingVideos[index];
                        return VideoShowcaseCard(video: video)
                            .animate()
                            .fadeIn(delay: (index * 100).ms)
                            .slideX(begin: 0.1);
                      },
                    ),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: PremiumButton(
                    label: 'Read Our Love Notes',
                    icon: Icons.favorite_border,
                    onPressed: () => context.go(RoutePaths.loveNotes),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, GalleryPhoto photo, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenPreview(photo: photo, heroTag: 'gallery-$index'),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.photo,
    required this.heroTag,
    required this.onTap,
  });

  final GalleryPhoto photo;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(source: photo.imageUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.deepWine.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.caption,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      photo.date,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasonryTile extends StatelessWidget {
  const _MasonryTile({required this.photo, required this.height});

  final GalleryPhoto photo;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(source: photo.imageUrl),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: AppColors.deepWine.withValues(alpha: 0.55),
                child: Text(
                  photo.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenPreview extends StatelessWidget {
  const _FullscreenPreview({required this.photo, required this.heroTag});

  final GalleryPhoto photo;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: Hero(
              tag: heroTag,
              child: PhotoView(
                imageProvider: appImageProvider(photo.imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.deepWine,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.caption,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  photo.message,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
