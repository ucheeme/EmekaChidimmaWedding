import 'package:flutter/foundation.dart';

import 'core/constants/route_paths.dart';
import 'core/di/injection.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/services/qr_entry_service.dart';

class AppBootstrapData {
  const AppBootstrapData({required this.firebase});

  final FirebaseBootstrapResult firebase;
}

Future<AppBootstrapData> bootstrap() async {
  final firebase = await FirebaseBootstrap.initialize();
  await configureDependencies(firebaseReady: firebase.initialized);

  if (kIsWeb) {
    final qrEntry = sl<QrEntryService>();
    if (qrEntry.launchUriGrantsEntry(Uri.base)) {
      await qrEntry.grantEntryFromQr();
    }
  }

  return AppBootstrapData(firebase: firebase);
}

/// Web launch location including query params (GoRouter drops them if omitted).
String resolveInitialLocation(FirebaseBootstrapResult firebase) {
  if (!firebase.initialized) {
    return RoutePaths.firebaseSetup;
  }

  if (kIsWeb) {
    final base = Uri.base;
    final path = base.path.isEmpty ? RoutePaths.splash : base.path;
    if (base.hasQuery) {
      return '$path?${base.query}';
    }
    return path;
  }

  return RoutePaths.splash;
}
