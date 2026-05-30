import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth/auth_cubit.dart';
import '../cubit/auth/auth_state.dart';
import '../cubit/memories/memories_cubit.dart';

/// Starts (or restarts) the live-memories Firestore stream once guest auth is
/// ready. Avoids attaching the listener before anonymous sign-in completes,
/// which can leave the gallery empty or in a failed state on mobile web.
class MemoriesBootstrap extends StatefulWidget {
  const MemoriesBootstrap({
    super.key,
    required this.firebaseReady,
    required this.child,
  });

  final bool firebaseReady;
  final Widget child;

  @override
  State<MemoriesBootstrap> createState() => _MemoriesBootstrapState();
}

class _MemoriesBootstrapState extends State<MemoriesBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMemories());
  }

  void _syncMemories() {
    if (!mounted) return;
    if (!widget.firebaseReady) {
      context.read<MemoriesCubit>().startWatching();
      return;
    }
    // Bootstrap already signs in anonymously before the UI mounts. Start
    // immediately when a Firebase user exists — don't wait on AuthCubit UX
    // state, which can leave the gallery stuck in a blank initial state.
    if (FirebaseAuth.instance.currentUser != null) {
      context.read<MemoriesCubit>().startWatching();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseReady) return widget.child;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          curr.status == AuthStatus.authenticated,
      listener: (_, __) => context.read<MemoriesCubit>().startWatching(),
      child: widget.child,
    );
  }
}
