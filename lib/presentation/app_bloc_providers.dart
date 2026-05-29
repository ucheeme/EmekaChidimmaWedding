import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/firebase/firebase_bootstrap.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/connectivity/connectivity_cubit.dart';
import 'cubit/content/content_cubit.dart';
import 'cubit/memories/memories_cubit.dart';
import 'cubit/music/music_cubit.dart';

/// Root BLoC providers for Forever Moments.
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({
    super.key,
    required this.firebase,
    required this.child,
  });

  final FirebaseBootstrapResult firebase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityCubit>.value(
          value: sl<ConnectivityCubit>(),
        ),
        if (firebase.initialized && sl.isRegistered<AuthCubit>())
          BlocProvider<AuthCubit>(
            create: (_) => sl<AuthCubit>()..ensureSession(),
          ),
        BlocProvider<MemoriesCubit>(
          create: (_) => sl<MemoriesCubit>()..startWatching(),
        ),
        BlocProvider<ContentCubit>(
          create: (_) => sl<ContentCubit>()..load(),
        ),
        BlocProvider<MusicCubit>(
          create: (_) => sl<MusicCubit>()..load(),
        ),
      ],
      child: child,
    );
  }
}
