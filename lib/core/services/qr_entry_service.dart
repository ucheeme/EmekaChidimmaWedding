import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/web_config.dart';
import '../utils/app_logger.dart';

/// Persists whether the guest opened the app via the wedding QR code (web/PWA).
class QrEntryService {
  QrEntryService({SharedPreferences? preferences})
      : _preferencesFuture = preferences != null
            ? Future.value(preferences)
            : SharedPreferences.getInstance();

  static const _storageKey = 'forever_moments_qr_entry_granted';

  final Future<SharedPreferences> _preferencesFuture;

  /// In-memory flag for the current browser tab/session.
  /// Safari/private mode can block localStorage; this still allows QR entry.
  bool _sessionGranted = false;

  /// Returns true if the guest may use the app (QR entry or dev bypass).
  Future<bool> hasValidEntry() async {
    if (!WebConfig.enforceQrEntry) {
      return true;
    }
    if (_sessionGranted) {
      return true;
    }
    try {
      final prefs = await _preferencesFuture;
      final persisted = prefs.getBool(_storageKey) ?? false;
      if (persisted) {
        _sessionGranted = true;
      }
      return persisted;
    } catch (e, stack) {
      AppLogger.error(
        'Unable to read QR entry state',
        tag: 'QrEntry',
        error: e,
        stackTrace: stack,
      );
      return _sessionGranted;
    }
  }

  /// True when launch URL is a valid guest entry link.
  bool launchUriGrantsEntry(Uri uri) {
    if (uri.path == WebConfig.qrLaunchPath ||
        uri.path == '${WebConfig.qrLaunchPath}/') {
      return true;
    }
    return uri.queryParameters[WebConfig.qrEntryParam] ==
        WebConfig.qrEntryValue;
  }

  /// Call when the launch URL contains the QR query param.
  Future<void> grantEntryFromQr() async {
    _sessionGranted = true;
    if (!kIsWeb) return;
    try {
      final prefs = await _preferencesFuture;
      await prefs.setBool(_storageKey, true);
      AppLogger.info('QR entry granted', tag: 'QrEntry');
    } catch (e, stack) {
      AppLogger.error(
        'Unable to persist QR entry state (session entry still active)',
        tag: 'QrEntry',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// For testing only.
  Future<void> clearEntry() async {
    _sessionGranted = false;
    try {
      final prefs = await _preferencesFuture;
      await prefs.remove(_storageKey);
    } catch (_) {
      // no-op for non-critical test helper
    }
  }
}
