import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/guest_message.dart';

class GuestMessageModel {
  const GuestMessageModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.weddingId,
    this.guestName,
  });

  final String id;
  final String text;
  final DateTime timestamp;
  final String weddingId;
  final String? guestName;

  Map<String, dynamic> toFirestore() {
    return {
      GuestMessageFields.text: text,
      GuestMessageFields.timestamp: FieldValue.serverTimestamp(),
      GuestMessageFields.weddingId: weddingId,
      if (guestName != null) GuestMessageFields.guestName: guestName,
    };
  }

  GuestMessageEntity toEntity() {
    return GuestMessageEntity(
      id: id,
      text: text,
      timestamp: timestamp,
      weddingId: weddingId,
      guestName: guestName,
    );
  }
}
