import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/guest_message.dart';
import '../cubit/messages_cubit.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminMessagesCubit, AdminMessagesState>(
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
        if (state.status == AdminMessagesStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.roseGold),
          );
        }
        if (state.status == AdminMessagesStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.wine),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<AdminMessagesCubit>().start(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state.status == AdminMessagesStatus.empty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum_outlined, size: 48, color: AppColors.champagne),
                SizedBox(height: 12),
                Text('No guest messages yet.',
                    style: TextStyle(color: AppColors.champagne)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _MessageCard(message: state.messages[i]),
        );
      },
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final GuestMessageEntity message;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A130C),
        title: const Text('Remove this message?'),
        content: const Text('This permanently deletes the guest message.'),
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
      context.read<AdminMessagesCubit>().remove(message.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AdminMessagesCubit, bool>(
        (c) => c.state.actioningIds.contains(message.id));
    final name = message.guestName?.trim().isNotEmpty == true
        ? message.guestName!
        : 'Anonymous guest';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A130C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2118)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.olive,
            child: Icon(Icons.person, color: AppColors.mint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 6),
                Text(message.text,
                    style: const TextStyle(
                        color: AppColors.ivory, height: 1.4, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  _formatDate(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.champagne.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          busy
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.roseGold),
                  ),
                )
              : IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, color: AppColors.wine),
                  onPressed: () => _confirmDelete(context),
                ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
