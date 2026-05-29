import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/firebase/firebase_guest_message_datasource.dart';
import '../../data/datasources/firebase/firebase_memory_datasource.dart';
import '../cubit/admin_auth_cubit.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/moderation_cubit.dart';
import 'messages_view.dart';
import 'moderation_view.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _index = 0;

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A130C),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to moderate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminAuthCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ModerationCubit>(
          create: (ctx) =>
              ModerationCubit(ctx.read<FirebaseMemoryDataSource>())..start(),
        ),
        BlocProvider<AdminMessagesCubit>(
          create: (ctx) =>
              AdminMessagesCubit(ctx.read<FirebaseGuestMessageDataSource>())
                ..start(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_index == 0 ? 'Guest Gallery' : 'Guest Messages'),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: _confirmSignOut,
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: const [
            ModerationView(),
            MessagesView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: const Color(0xFF1A130C),
          indicatorColor: AppColors.roseGold.withValues(alpha: 0.25),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum),
              label: 'Messages',
            ),
          ],
        ),
      ),
    );
  }
}
