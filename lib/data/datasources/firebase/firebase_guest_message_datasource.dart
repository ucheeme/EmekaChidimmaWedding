import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/guest_message_model.dart';

class FirebaseGuestMessageDataSource {
  FirebaseGuestMessageDataSource({
    required FirebaseFirestore firestore,
    Uuid? uuid,
  })  : _firestore = firestore,
        _uuid = uuid ?? const Uuid();

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseCollections.guestMessages);

  Future<GuestMessageModel> submitMessage({
    required String text,
    String? guestName,
    String weddingId = WeddingConfig.weddingId,
  }) async {
    try {
      final id = _uuid.v4();
      final model = GuestMessageModel(
        id: id,
        text: text.trim(),
        timestamp: DateTime.now(),
        weddingId: weddingId,
        guestName: guestName?.trim(),
      );

      await _collection.doc(id).set(model.toFirestore());
      return model;
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? 'Could not send message.', e.code);
    }
  }
}
