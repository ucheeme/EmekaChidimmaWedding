import 'package:flutter/foundation.dart';

import '../constants/route_paths.dart';

/// Web / PWA configuration for QR-based guest access.
abstract final class WebConfig {
  /// Query param on the QR code URL (e.g. `?from=qr`).
  static const String qrEntryParam = 'from';
  static const String qrEntryValue = 'qr';

  /// Optional wedding id on QR URL (e.g. `?from=qr&w=emeka-wedding-2026`).
  static const String weddingParam = 'w';

  /// Preferred QR launch path (no query params).
  static const String qrLaunchPath = RoutePaths.start;

  /// Legacy query launch path.
  static String qrLaunchQueryPath({String? weddingId}) {
    final query = weddingId != null
        ? '$qrEntryParam=$qrEntryValue&$weddingParam=$weddingId'
        : '$qrEntryParam=$qrEntryValue';
    return '/?$query';
  }

  /// Skip QR gate in debug: `--dart-define=ALLOW_DIRECT_WEB_ACCESS=true`
  static const bool allowDirectWebAccess = bool.fromEnvironment(
    'ALLOW_DIRECT_WEB_ACCESS',
    defaultValue: !kReleaseMode,
  );

  static bool get enforceQrEntry => kIsWeb && !allowDirectWebAccess;
}
