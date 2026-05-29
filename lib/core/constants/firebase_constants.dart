import '../config/wedding_config.dart';

/// Firestore collection and field names.
class FirebaseCollections {
  const FirebaseCollections._();

  static const String memories = 'memories';
  static const String guestMessages = 'guest_messages';
  static const String weddingContent = 'wedding_content';
}

/// Cloud Storage path helpers.
class FirebaseStoragePaths {
  const FirebaseStoragePaths._();

  static String memoryFile({
    String weddingId = WeddingConfig.weddingId,
    required String memoryId,
    required String extension,
  }) =>
      'weddings/$weddingId/memories/$memoryId.$extension';
}

/// Firestore field keys for [FirebaseCollections.memories].
class MemoryFields {
  const MemoryFields._();

  static const String imageUrl = 'imageUrl';
  static const String timestamp = 'timestamp';
  static const String guestName = 'guestName';
  static const String message = 'message';
  static const String mediaType = 'mediaType';
  static const String tableNumber = 'tableNumber';
  static const String weddingId = 'weddingId';
  static const String storagePath = 'storagePath';
  static const String driveSyncStatus = 'driveSyncStatus';
}

/// Firestore field keys for [FirebaseCollections.guestMessages].
class GuestMessageFields {
  const GuestMessageFields._();

  static const String text = 'text';
  static const String timestamp = 'timestamp';
  static const String weddingId = 'weddingId';
  static const String guestName = 'guestName';
}
