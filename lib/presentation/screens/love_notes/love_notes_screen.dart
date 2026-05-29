import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/route_paths.dart';
import '../../../core/content/wedding_content.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubit/content/content_cubit.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nav_buttons.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/romantic_background.dart';

class LoveNotesScreen extends StatefulWidget {
  const LoveNotesScreen({super.key});

  @override
  State<LoveNotesScreen> createState() => _LoveNotesScreenState();
}

class _LoveNotesScreenState extends State<LoveNotesScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<ContentCubit>().state.bundle.loveNotes;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Love Notes'),
        actions: const [MusicToggleButton(), HomeIconButton()],
      ),
      body: RomanticBackground(
        showPetals: true,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: notes.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _LoveNoteCard(
                        note: notes[i],
                        active: i == _index,
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  notes.length,
                  (i) => Container(
                    margin: const EdgeInsets.all(4),
                    width: i == _index ? 10 : 6,
                    height: i == _index ? 10 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? AppColors.deepWine
                          : AppColors.deepWine.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: PremiumButton(
                  label: 'Capture Beautiful Moments',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => context.go(RoutePaths.home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoveNoteCard extends StatelessWidget {
  const _LoveNoteCard({required this.note, required this.active});

  final LoveNote note;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 36,
            color: AppColors.roseGold.withValues(alpha: 0.9),
          )
              .animate(target: active ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 600.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.15, 1.15),
                end: const Offset(1, 1),
                duration: 600.ms,
              ),
          const SizedBox(height: 32),
          if (active)
            AnimatedTextKit(
              key: ValueKey(note.text),
              animatedTexts: [
                TypewriterAnimatedText(
                  '"${note.text}"',
                  textStyle: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    color: AppColors.deepWine,
                    height: 1.5,
                  ),
                  speed: const Duration(milliseconds: 35),
                ),
              ],
              totalRepeatCount: 1,
              isRepeatingAnimation: false,
            )
          else
            Text(
              '"${note.text}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: AppColors.deepWine.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          if (note.author != null) ...[
            const SizedBox(height: 24),
            Text(
              '— ${note.author}',
              style: GoogleFonts.lato(
                fontSize: 13,
                letterSpacing: 1,
                color: AppColors.roseGold,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
