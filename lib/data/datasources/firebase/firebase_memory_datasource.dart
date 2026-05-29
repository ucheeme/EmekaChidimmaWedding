import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/media/image_compress_helper.dart';
import '../../../domain/enums/media_type.dart';
import '../../models/memory_model.dart';

class FirebaseMemoryDataSource {
  FirebaseMemoryDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    Uuid? uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _uuid = uuid ?? const Uuid();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  CollectionReference<Map<String, dynamic>> get _memoriesCollection =>
      _firestore.collection(FirebaseCollections.memories);

  Stream<List<MemoryModel>> watchMemories({String? weddingId}) {
    final id = weddingId ?? WeddingConfig.weddingId;
    return _memoriesCollection
        .where(MemoryFields.weddingId, isEqualTo: id)
        .where(MemoryFields.visible, isEqualTo: true)
        .orderBy(MemoryFields.timestamp, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(MemoryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Admin-only: streams every memory (including hidden ones) for moderation.
  Stream<List<MemoryModel>> watchAllMemories({String? weddingId}) {
    final id = weddingId ?? WeddingConfig.weddingId;
    return _memoriesCollection
        .where(MemoryFields.weddingId, isEqualTo: id)
        .orderBy(MemoryFields.timestamp, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(MemoryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Admin-only: show or hide a memory in the guest gallery.
  Future<void> setMemoryVisibility({
    required String memoryId,
    required bool visible,
  }) async {
    try {
      await _memoriesCollection
          .doc(memoryId)
          .update({MemoryFields.visible: visible});
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not update memory.', e.code);
    }
  }

  /// Admin-only: permanently delete a memory. A Cloud Function removes the
  /// associated Storage file when the document is deleted.
  Future<void> deleteMemory(String memoryId) async {
    try {
      await _memoriesCollection.doc(memoryId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not delete memory.', e.code);
    }
  }

  Future<List<MemoryModel>> getMemories({String? weddingId}) async {
    final id = weddingId ?? WeddingConfig.weddingId;
    final snapshot = await _memoriesCollection
        .where(MemoryFields.weddingId, isEqualTo: id)
        .orderBy(MemoryFields.timestamp, descending: true)
        .get();
    return snapshot.docs.map(MemoryModel.fromFirestore).toList();
  }

  Future<MemoryModel> uploadMemory({
    required XFile mediaFile,
    required MediaType mediaType,
    String? guestName,
    String? message,
    String? tableNumber,
    String weddingId = WeddingConfig.weddingId,
  }) async {
    try {
      final memoryId = _uuid.v4();
      final extension = _extensionFor(mediaType, mediaFile.name);
      final storagePath = FirebaseStoragePaths.memoryFile(
        weddingId: weddingId,
        memoryId: memoryId,
        extension: extension,
      );

      var bytes = await mediaFile.readAsBytes();
      if (mediaType == MediaType.photo) {
        bytes = await ImageCompressHelper.preparePhotoBytes(bytes);
      }

      final ref = _storage.ref(storagePath);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: _contentType(mediaType, extension)),
      );
      final downloadUrl = await ref.getDownloadURL();

      final model = MemoryModel(
        id: memoryId,
        imageUrl: downloadUrl,
        timestamp: DateTime.now(),
        mediaType: mediaType.value,
        weddingId: weddingId,
        guestName: guestName,
        message: message,
        tableNumber: tableNumber,
        storagePath: storagePath,
      );

      await _memoriesCollection.doc(memoryId).set(model.toFirestore());

      return model;
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? 'Upload failed.', e.code);
    }
  }

  String _extensionFor(MediaType mediaType, String fileName) {
    if (mediaType == MediaType.video) {
      final lower = fileName.toLowerCase();
      if (lower.endsWith('.mov')) return 'mov';
      if (lower.endsWith('.webm')) return 'webm';
      return 'mp4';
    }
    return 'jpg';
  }

  String _contentType(MediaType mediaType, String extension) {
    if (mediaType == MediaType.video) {
      return switch (extension) {
        'mov' => 'video/quicktime',
        'webm' => 'video/webm',
        _ => 'video/mp4',
      };
    }
    return 'image/jpeg';
  }
}
