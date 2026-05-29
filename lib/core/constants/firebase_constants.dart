import '../config/wedding_config.dart';

/// Firestore collection and field names.
class FirebaseCollections {
  const FirebaseCollections._();

  static const String memories = 'memories';
  static const String guestMessages = 'guest_messages';
  static const String weddingContent = 'wedding_content';

  /// Allow-list of admin user UIDs. A document id == auth uid grants moderation
  /// rights (checked in Firestore security rules).
  static const String admins = 'admins';
}

/// Document ids inside [FirebaseCollections.weddingContent], one per editable
/// section. Each document holds an `items` array managed by the admin app.
class ContentSections {
  const ContentSections._();

  static const String loveStory = 'love_story';
  static const String gallery = 'gallery';
  static const String videos = 'videos';
  static const String loveNotes = 'love_notes';
  static const String program = 'program';

  /// Single background-music track document (holds [urlField], not [itemsField]).
  static const String music = 'music';

  /// Array field holding the ordered items within a section document.
  static const String itemsField = 'items';
  static const String updatedAtField = 'updatedAt';
  static const String urlField = 'url';
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

  /// Admin-uploaded curated content media (love-story photos, gallery, videos,
  /// program pages).
  static String contentMedia({
    String weddingId = WeddingConfig.weddingId,
    required String section,
    required String id,
    required String extension,
  }) =>
      'weddings/$weddingId/content/$section/$id.$extension';
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

  /// Moderation flag. When false, the memory is hidden from the guest gallery
  /// (set by an admin). Absent/true means visible.
  static const String visible = 'visible';
}

/// Firestore field keys for [FirebaseCollections.guestMessages].
class GuestMessageFields {
  const GuestMessageFields._();

  static const String text = 'text';
  static const String timestamp = 'timestamp';
  static const String weddingId = 'weddingId';
  static const String guestName = 'guestName';
}
