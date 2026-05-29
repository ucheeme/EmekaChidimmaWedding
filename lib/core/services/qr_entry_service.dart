import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/web_config.dart';
import '../utils/app_logger.dart';

/// Persists whether the guest opened the app via the wedding QR code (web/PWA).
///
/// Storage is treated as best-effort: if `shared_preferences` is unavailable
/// (e.g. Safari private mode, or the web plugin failing to register), the
/// service falls back to an in-memory session flag so QR entry still works and
/// the app never crashes on startup.
class QrEntryService {
  QrEntryService({SharedPreferences? preferences}) : _injected = preferences;

  static const _storageKey = 'forever_moments_qr_entry_granted';

  final SharedPreferences? _injected;
  Future<SharedPreferences?>? _preferencesFuture;

  /// In-memory flag for the current browser tab/session.
  bool _sessionGranted = false;

  /// Resolves shared preferences, returning null on any failure instead of
  /// throwing. The future is cached and carries its own error handler so a
  /// rejected plugin call can never surface as an unhandled zone error.
  Future<SharedPreferences?> _prefs() {
    if (_injected != null) {
      return Future<SharedPreferences?>.value(_injected);
    }
    return _preferencesFuture ??= SharedPreferences.getInstance()
        .then<SharedPreferences?>((prefs) => prefs)
        .catchError((Object error, StackTrace stack) {
      AppLogger.error(
        'Shared preferences unavailable; using in-memory QR entry',
        tag: 'QrEntry',
        error: error,
        stackTrace: stack,
      );
      return null;
    });
  }

  /// Returns true if the guest may use the app (QR entry or dev bypass).
  Future<bool> hasValidEntry() async {
    if (!WebConfig.enforceQrEntry) {
      return true;
    }
    if (_sessionGranted) {
      return true;
    }
    final prefs = await _prefs();
    if (prefs == null) {
      return _sessionGranted;
    }
    final persisted = prefs.getBool(_storageKey) ?? false;
    if (persisted) {
      _sessionGranted = true;
    }
    return persisted;
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
    final prefs = await _prefs();
    if (prefs == null) {
      // Session flag already set; persistence is best-effort.
      return;
    }
    final ok = await prefs.setBool(_storageKey, true);
    if (ok) {
      AppLogger.info('QR entry granted', tag: 'QrEntry');
    }
  }

  /// For testing only.
  Future<void> clearEntry() async {
    _sessionGranted = false;
    final prefs = await _prefs();
    await prefs?.remove(_storageKey);
  }
}
