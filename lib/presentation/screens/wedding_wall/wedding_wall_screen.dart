import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/content/demo_memories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/memory.dart';
import '../../cubit/memories/memories_cubit.dart';
import '../../cubit/memories/memories_state.dart';
import '../../widgets/animations/falling_petals.dart';

/// Fullscreen TV/projector slideshow with auto-advance.
class WeddingWallScreen extends StatefulWidget {
  const WeddingWallScreen({super.key});

  @override
  State<WeddingWallScreen> createState() => _WeddingWallScreenState();
}

class _WeddingWallScreenState extends State<WeddingWallScreen> {
  final _pageController = PageController();
  Timer? _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<MemoriesCubit>().state;
      _ensureAutoPlay(_resolveMemories(state).length);
    });
  }

  List<Memory> _resolveMemories(MemoriesState state) {
    if (state.isDemoData) {
      return DemoMemories.weddingWall;
    }
    return state.memories;
  }

  void _ensureAutoPlay(int count) {
    _autoTimer?.cancel();
    if (count == 0) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_current + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<MemoriesCubit, MemoriesState>(
        listenWhen: (prev, curr) =>
            prev.memories.length != curr.memories.length ||
            prev.isDemoData != curr.isDemoData,
        listener: (context, state) {
          final memories = _resolveMemories(state);
          _ensureAutoPlay(memories.length);
        },
        builder: (context, state) {
          final memories = _resolveMemories(state);

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.roseGold),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              if (memories.isEmpty)
                Center(
                  child: Text(
                    WeddingConfig.coupleDisplayName,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 48,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: memories.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, index) {
                    final memory = memories[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1000),
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
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 48,
                            bottom: 48,
                            right: 48,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  WeddingConfig.coupleDisplayName,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 36,
                                    color: AppColors.roseGold,
                                  ),
                                ),
                                if (memory.message != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    memory.message!,
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                if (memory.guestName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '— ${memory.guestName}',
                                      style: GoogleFonts.lato(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const FallingPetals(),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
