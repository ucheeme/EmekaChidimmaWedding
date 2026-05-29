import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'core/utils/app_logger.dart';
import 'presentation/screens/startup_error/startup_error_screen.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        AppLogger.error(
          'Uncaught Flutter error',
          tag: 'Main',
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };

      // Best-effort: orientation lock is a no-op / unsupported on web.
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } catch (_) {
        // Ignored — not critical and unsupported on some platforms.
      }

      try {
        final bootstrapData = await bootstrap();
        runApp(ForeverMomentsApp(firebase: bootstrapData.firebase));
      } catch (error, stackTrace) {
        AppLogger.error(
          'App bootstrap failed',
          tag: 'Main',
          error: error,
          stackTrace: stackTrace,
        );
        // Never leave the user on a blank page — show a recoverable screen.
        runApp(StartupErrorApp(details: error.toString()));
      }
    },
    (error, stackTrace) {
      AppLogger.error(
        'Uncaught zone error',
        tag: 'Main',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
