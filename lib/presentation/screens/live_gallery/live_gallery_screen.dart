import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_cache_config.dart';
import '../../../domain/entities/memory.dart';
import '../../cubit/memories/memories_cubit.dart';
import '../../cubit/memories/memories_state.dart';
import '../../widgets/romantic_background.dart';

class LiveGalleryScreen extends StatefulWidget {
  const LiveGalleryScreen({super.key});

  @override
  State<LiveGalleryScreen> createState() => _LiveGalleryScreenState();
}

class _LiveGalleryScreenState extends State<LiveGalleryScreen> {
  bool _slideshow = false;
  int _slideshowIndex = 0;
  Timer? _slideshowTimer;

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    super.dispose();
  }

  void _toggleSlideshow(List<Memory> memories) {
    setState(() {
      _slideshow = !_slideshow;
      if (_slideshow && memories.isNotEmpty) {
        _slideshowIndex = 0;
        _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (_) {
          if (!mounted || memories.isEmpty) return;
          setState(() {
            _slideshowIndex = (_slideshowIndex + 1) % memories.length;
          });
        });
      } else {
        _slideshowTimer?.cancel();
        _slideshowTimer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Live Gallery'),
        actions: [
          BlocBuilder<MemoriesCubit, MemoriesState>(
            buildWhen: (prev, curr) => prev.memories != curr.memories,
            builder: (context, state) {
              return IconButton(
                icon: Icon(_slideshow ? Icons.grid_view : Icons.slideshow),
                onPressed: state.hasMemories
                    ? () => _toggleSlideshow(state.memories)
                    : null,
                tooltip: _slideshow ? 'Grid view' : 'Slideshow',
              );
            },
          ),
        ],
      ),
      body: RomanticBackground(
        child: SafeArea(
          child: BlocBuilder<MemoriesCubit, MemoriesState>(
            builder: (context, state) {
              if (state.isLoading) {
                return _buildShimmer();
              }
              if (state.status == MemoriesStatus.failure) {
                return _buildError(context, state.message);
              }
              if (state.status == MemoriesStatus.empty) {
                return _buildEmpty();
              }
              if (_slideshow && state.hasMemories) {
                return _buildSlideshow(state.memories);
              }
              return _buildGrid(state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.deepWine.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: AppColors.deepWine),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.read<MemoriesCubit>().retry(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.softPink,
      highlightColor: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.deepWine.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              'No memories yet',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                color: AppColors.deepWine,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to capture a beautiful moment!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: AppColors.deepWine.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideshow(List<Memory> memories) {
    final memory = memories[_slideshowIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Stack(
        key: ValueKey(memory.id),
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: memory.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.deepWine.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (memory.guestName != null)
                  Text(
                    memory.guestName!,
                    style: GoogleFonts.lato(
                      color: AppColors.roseGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (memory.message != null)
                  Text(
                    memory.message!,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(MemoriesState state) {
    final memories = state.memories;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MemoriesCubit>().retry();
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: CustomScrollView(
        slivers: [
          if (state.isDemoData)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: _DemoBanner(),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childCount: memories.length,
              itemBuilder: (context, memoryIndex) {
          final memory = memories[memoryIndex];
          final height = memoryIndex.isEven ? 180.0 : 240.0;
          return GestureDetector(
            onTap: () => _openPreview(memory),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                  CachedNetworkImage(
                    imageUrl: memory.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: ImageCacheConfig.memCacheWidth(context),
                  ),
                    if (memory.isVideo)
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    if (memory.guestName != null)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.deepWine.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            memory.guestName!,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (memoryIndex * 60).ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPreview(Memory memory) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(memory.imageUrl),
          ),
        ),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.roseGold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.roseGold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'Preview mode — connect Firebase for live guest uploads',
        style: GoogleFonts.lato(
          fontSize: 11,
          color: AppColors.deepWine,
        ),
      ),
    );
  }
}
