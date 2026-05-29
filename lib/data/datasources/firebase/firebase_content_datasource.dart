import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/content/wedding_content.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/media/image_compress_helper.dart';

/// Reads and writes the curated wedding content stored in Firestore
/// (`wedding_content/{section}` documents, each with an `items` array).
///
/// Guests read the merged [WeddingContentBundle] (remote when present, bundled
/// defaults otherwise); admins save sections and upload media.
class FirebaseContentDataSource {
  FirebaseContentDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    Uuid? uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _uuid = uuid ?? const Uuid();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  DocumentReference<Map<String, dynamic>> _sectionDoc(String section) =>
      _firestore.collection(FirebaseCollections.weddingContent).doc(section);

  /// Fetches all sections once, falling back to bundled defaults per section.
  Future<WeddingContentBundle> fetchBundle() async {
    final results = await Future.wait([
      _readItems(ContentSections.loveStory),
      _readItems(ContentSections.gallery),
      _readItems(ContentSections.videos),
      _readItems(ContentSections.loveNotes),
      _readItems(ContentSections.program),
    ]);

    const d = WeddingContentBundle.defaults;
    return WeddingContentBundle(
      loveStory: results[0] == null
          ? d.loveStory
          : results[0]!.map(LoveStoryChapter.fromMap).toList(),
      gallery: results[1] == null
          ? d.gallery
          : results[1]!.map(GalleryPhoto.fromMap).toList(),
      videos: results[2] == null
          ? d.videos
          : results[2]!.map(WeddingVideo.fromMap).toList(),
      loveNotes: results[3] == null
          ? d.loveNotes
          : results[3]!.map(LoveNote.fromMap).toList(),
      program: results[4] == null
          ? d.program
          : results[4]!.map(ProgramPage.fromMap).toList(),
    );
  }

  /// Reads a single section's raw items once for the admin editor. Returns null
  /// when the section has never been saved (caller falls back to defaults).
  Future<List<Map<String, dynamic>>?> fetchSectionItems(String section) async {
    return _readItems(section);
  }

  /// Admin-only: persists the ordered items for a section.
  Future<void> saveSection(
    String section,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      await _sectionDoc(section).set({
        ContentSections.itemsField: items,
        ContentSections.updatedAtField: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not save content.', e.code);
    }
  }

  /// Admin-only: uploads a content image/video and returns its download URL.
  Future<String> uploadMedia({
    required XFile file,
    required String section,
    required bool isVideo,
  }) async {
    try {
      final id = _uuid.v4();
      final extension = isVideo ? _videoExtension(file.name) : 'jpg';
      final path = FirebaseStoragePaths.contentMedia(
        section: section,
        id: id,
        extension: extension,
      );

      var bytes = await file.readAsBytes();
      if (!isVideo) {
        bytes = await ImageCompressHelper.preparePhotoBytes(bytes);
      }

      final ref = _storage.ref(path);
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: isVideo
              ? _videoContentType(extension)
              : 'image/jpeg',
        ),
      );
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? 'Upload failed.', e.code);
    }
  }

  Future<List<Map<String, dynamic>>?> _readItems(String section) async {
    try {
      final snap = await _sectionDoc(section).get();
      return _itemsFrom(snap.data());
    } on FirebaseException {
      return null; // Fall back to defaults on read failure.
    }
  }

  /// Returns the items array, or null when the doc/array is missing or empty
  /// (signals "use defaults").
  List<Map<String, dynamic>>? _itemsFrom(Map<String, dynamic>? data) {
    final raw = data?[ContentSections.itemsField];
    if (raw is! List || raw.isEmpty) return null;
    return raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);
  }

  String _videoExtension(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mov')) return 'mov';
    if (lower.endsWith('.webm')) return 'webm';
    return 'mp4';
  }

  String _videoContentType(String extension) {
    return switch (extension) {
      'mov' => 'video/quicktime',
      'webm' => 'video/webm',
      _ => 'video/mp4',
    };
  }
}
