/// Wedding-specific content identifiers and display names.
/// Update [brideName] before your wedding day.
class WeddingConfig {
  const WeddingConfig._();

  static const String groomName = 'Emeka';
  static const String brideName = 'Chidimma';

  /// Used in Firestore queries and Storage paths.
  static const String weddingId = 'emeka-wedding-2026';

  /// Bride first, e.g. "Joyce & Emeka".
  static String get coupleDisplayName => '$brideName & $groomName';

  static String get splashWelcome =>
      'Welcome to $brideName & $groomName\'s Wedding';
}
