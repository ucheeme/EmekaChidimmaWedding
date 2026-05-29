import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/firebase/firebase_options.dart';
import '../core/utils/app_logger.dart';
import 'admin_app.dart';

/// Entry point for the Forever Moments **admin** app (separate build target).
///
/// Build with:
///   flutter build apk --release --target=lib/admin/admin_main.dart \
///     --dart-define=FIREBASE_CONFIGURED=true
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        AppLogger.error(
          'Uncaught Flutter error',
          tag: 'AdminMain',
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };

      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } catch (_) {
        // Not critical.
      }

      var initialized = false;
      String? initError;
      try {
        if (DefaultFirebaseOptions.isConfigured) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          initialized = true;
        } else {
          initError = 'Firebase is not configured for this build.';
        }
      } catch (error, stack) {
        AppLogger.error(
          'Admin Firebase init failed',
          tag: 'AdminMain',
          error: error,
          stackTrace: stack,
        );
        initError = 'Unable to connect to wedding services.';
      }

      runApp(AdminApp(firebaseReady: initialized, initError: initError));
    },
    (error, stack) {
      AppLogger.error(
        'Uncaught zone error',
        tag: 'AdminMain',
        error: error,
        stackTrace: stack,
      );
    },
  );
}
