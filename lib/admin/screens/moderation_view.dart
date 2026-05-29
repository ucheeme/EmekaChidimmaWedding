import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/memory.dart';
import '../cubit/moderation_cubit.dart';

enum _Filter { all, visible, hidden }

class ModerationView extends StatefulWidget {
  const ModerationView({super.key});

  @override
  State<ModerationView> createState() => _ModerationViewState();
}

class _ModerationViewState extends State<ModerationView> {
  _Filter _filter = _Filter.all;

  List<Memory> _apply(List<Memory> all) {
    switch (_filter) {
      case _Filter.all:
        return all;
      case _Filter.visible:
        return all.where((m) => m.visible).toList();
      case _Filter.hidden:
        return all.where((m) => !m.visible).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModerationCubit, ModerationState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.message!),
            backgroundColor: AppColors.wine,
          ));
      },
      builder: (context, state) {
        if (state.status == ModerationStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.roseGold),
          );
        }
        if (state.status == ModerationStatus.error) {
          return _Retry(onRetry: () => context.read<ModerationCubit>().start());
        }

        final items = _apply(state.memories);
        return Column(
          children: [
            _FilterBar(
              filter: _filter,
              total: state.memories.length,
              visible: state.visibleCount,
              hidden: state.hiddenCount,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: items.isEmpty
                  ? const _Empty()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.74,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) => _MemoryTile(memory: items[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.total,
    required this.visible,
    required this.hidden,
    required this.onChanged,
  });

  final _Filter filter;
  final int total;
  final int visible;
  final int hidden;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          _chip(context, 'All ($total)', _Filter.all),
          const SizedBox(width: 8),
          _chip(context, 'Visible ($visible)', _Filter.visible),
          const SizedBox(width: 8),
          _chip(context, 'Hidden ($hidden)', _Filter.hidden),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, _Filter value) {
    final selected = filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(value),
      backgroundColor: const Color(0xFF1A130C),
      selectedColor: AppColors.roseGold,
      labelStyle: TextStyle(
        color: selected ? AppColors.noir : AppColors.champagne,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: Color(0xFF2A2118)),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.memory});

  final Memory memory;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A130C),
        title: const Text('Remove this upload?'),
        content: const Text(
          'This permanently deletes the photo/video for everyone. '
          'To temporarily hide it instead, use the eye button.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.wine),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ModerationCubit>().remove(memory.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy =
        context.select<ModerationCubit, bool>((c) => c.state.actioningIds.contains(memory.id));

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: const Color(0xFF1A130C),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Thumbnail(memory: memory),
                  if (!memory.visible)
                    Container(
                      color: Colors.black.withValues(alpha: 0.55),
                      alignment: Alignment.center,
                      child: const _Badge(
                        icon: Icons.visibility_off,
                        label: 'HIDDEN',
                        color: AppColors.wine,
                      ),
                    ),
                  if (memory.isVideo)
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: _Badge(
                        icon: Icons.videocam,
                        label: 'VIDEO',
                        color: Colors.black54,
                      ),
                    ),
                  if (busy)
                    Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.roseGold,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.guestName?.trim().isNotEmpty == true
                              ? memory.guestName!
                              : 'Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (memory.message?.trim().isNotEmpty == true)
                          Text(
                            memory.message!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.champagne,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: memory.visible ? 'Hide from gallery' : 'Show in gallery',
                    icon: Icon(
                      memory.visible ? Icons.visibility : Icons.visibility_off,
                      color: memory.visible ? AppColors.mint : AppColors.champagne,
                      size: 20,
                    ),
                    onPressed: busy
                        ? null
                        : () => context
                            .read<ModerationCubit>()
                            .setVisible(memory.id, !memory.visible),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.wine, size: 20),
                    onPressed: busy ? null : () => _confirmDelete(context),
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    if (memory.isVideo) {
      return Container(
        color: const Color(0xFF20281A),
        alignment: Alignment.center,
        child: const Icon(Icons.play_circle_outline,
            size: 44, color: AppColors.mint),
      );
    }
    return CachedNetworkImage(
      imageUrl: memory.imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: const Color(0xFF20281A),
        alignment: Alignment.center,
        child: const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.roseGold),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFF20281A),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.champagne),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 48, color: AppColors.champagne),
          SizedBox(height: 12),
          Text('No uploads here yet.',
              style: TextStyle(color: AppColors.champagne)),
        ],
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.wine),
          const SizedBox(height: 12),
          const Text('Unable to load uploads.',
              style: TextStyle(color: AppColors.ivory)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
