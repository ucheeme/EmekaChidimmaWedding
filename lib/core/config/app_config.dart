/// Runtime configuration for Forever Moments.
class AppConfig {
  const AppConfig._();

  static const String appName = 'Forever Moments';

  /// Set via: `--dart-define=USE_FIREBASE_EMULATOR=true`
  static const bool useFirebaseEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
    defaultValue: false,
  );

  /// Set via: `--dart-define=FIREBASE_CONFIGURED=true` after `flutterfire configure`.
  static const bool firebaseConfigured = bool.fromEnvironment(
    'FIREBASE_CONFIGURED',
    defaultValue: false,
  );
}
