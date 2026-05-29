import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bootstrap.dart';

import '../config/web_config.dart';
import '../di/injection.dart';
import '../services/qr_entry_service.dart';
import '../../domain/enums/media_type.dart';
import '../../presentation/cubit/capture/capture_cubit.dart';
import '../../presentation/cubit/upload/upload_memory_cubit.dart';
import '../../presentation/screens/capture/capture_screen.dart';
import '../../presentation/cubit/guest_message/guest_message_cubit.dart';
import '../../presentation/screens/firebase_setup/firebase_setup_screen.dart';
import '../../presentation/screens/guest_message/guest_message_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/intro/intro_screen.dart';
import '../../presentation/screens/live_gallery/live_gallery_screen.dart';
import '../../presentation/screens/love_notes/love_notes_screen.dart';
import '../../presentation/screens/love_story/love_story_screen.dart';
import '../../presentation/screens/pre_wedding_gallery/pre_wedding_gallery_screen.dart';
import '../../presentation/screens/qr_gate/qr_gate_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/wedding_wall/wedding_wall_screen.dart';
import '../constants/route_paths.dart';
import '../firebase/firebase_bootstrap.dart';
import 'page_transitions.dart';

GoRouter createAppRouter({required FirebaseBootstrapResult firebase}) {
  return GoRouter(
    initialLocation: resolveInitialLocation(firebase),
    redirect: _qrEntryRedirect,
    routes: [
      GoRoute(
        path: RoutePaths.start,
        redirect: (context, state) async {
          await sl<QrEntryService>().grantEntryFromQr();
          return RoutePaths.splash;
        },
      ),
      GoRoute(
        path: RoutePaths.qrGate,
        pageBuilder: (context, state) => fadeSlidePage(
          child: const QrGateScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) => heroFadePage(
          child: const SplashScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.intro,
        pageBuilder: (context, state) => fadeSlidePage(
          child: const IntroScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.loveStory,
        pageBuilder: (context, state) => fadeSlidePage(
          child: const LoveStoryScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.preWeddingGallery,
        pageBuilder: (context, state) => fadeSlidePage(
          child: const PreWeddingGalleryScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.loveNotes,
        pageBuilder: (context, state) => fadeSlidePage(
          child: const LoveNotesScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.home,
        pageBuilder: (context, state) => heroFadePage(
          child: const HomeScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.capture,
        pageBuilder: (context, state) => fadeSlidePage(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<CaptureCubit>(
                create: (_) => sl<CaptureCubit>(),
              ),
              BlocProvider<UploadMemoryCubit>(
                create: (_) => sl<UploadMemoryCubit>(),
              ),
            ],
            child: CaptureScreen(
              initialMediaType: _parseCaptureMediaType(state),
            ),
          ),
          state: state,
          slideAxis: Axis.horizontal,
        ),
      ),
      GoRoute(
        path: RoutePaths.guestMessage,
        pageBuilder: (context, state) => fadeSlidePage(
          child: BlocProvider<GuestMessageCubit>(
            create: (_) => sl<GuestMessageCubit>(),
            child: const GuestMessageScreen(),
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.liveGallery,
        pageBuilder: (context, state) => fadeSlidePage(
          child: const LiveGalleryScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.weddingWall,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const WeddingWallScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.firebaseSetup,
        builder: (context, state) => FirebaseSetupScreen(
          message: firebase.errorMessage,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error.toString())),
    ),
  );
}

MediaType? _parseCaptureMediaType(GoRouterState state) {
  return switch (state.uri.queryParameters['type']) {
    'photo' => MediaType.photo,
    'video' => MediaType.video,
    _ => null,
  };
}

Future<String?> _qrEntryRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  try {
    if (!WebConfig.enforceQrEntry) {
      return null;
    }

    final location = state.matchedLocation;
    if (location == RoutePaths.qrGate ||
        location == RoutePaths.firebaseSetup) {
      return null;
    }

    final qrEntry = sl<QrEntryService>();
    // Detect QR entry from the router's own target only. Using Uri.base here
    // breaks under the hash URL strategy (Uri.base.path stays at the launch
    // path, e.g. "/start", for the whole session), which would force every
    // in-app navigation back to the splash screen — an infinite loop. The
    // initial Uri.base grant is handled in bootstrap()/resolveInitialLocation.
    if (qrEntry.launchUriGrantsEntry(state.uri)) {
      await qrEntry.grantEntryFromQr();
      if (location != RoutePaths.splash) {
        return RoutePaths.splash;
      }
      return null;
    }

    if (await qrEntry.hasValidEntry()) {
      return null;
    }

    return RoutePaths.qrGate;
  } catch (_) {
    return RoutePaths.qrGate;
  }
}
