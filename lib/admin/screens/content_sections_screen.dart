import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../content/content_specs.dart';
import 'content_editor_screen.dart';
import 'music_editor_screen.dart';

/// Lists the editable content sections; tapping one opens its editor.
class ContentSectionsScreen extends StatelessWidget {
  const ContentSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final specCount = ContentSpecs.all.length;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      // header + section cards + music card
      itemCount: specCount + 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              'Edit what guests see. Changes go live as soon as you Save.',
              style: TextStyle(color: AppColors.champagne, height: 1.4),
            ),
          );
        }
        if (index <= specCount) {
          return _SectionCard(spec: ContentSpecs.all[index - 1]);
        }
        return const _MusicCard();
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.spec});

  final ContentSectionSpec spec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A130C),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ContentEditorScreen(spec: spec)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.roseGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(spec.icon, color: AppColors.roseGold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spec.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(spec.subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.champagne)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.champagne),
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A130C),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MusicEditorScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.roseGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.library_music_outlined,
                    color: AppColors.roseGold),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Background Music',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Plays softly while guests browse',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.champagne)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.champagne),
            ],
          ),
        ),
      ),
    );
  }
}
