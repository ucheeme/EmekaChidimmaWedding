import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/memory.dart';
import '../../domain/enums/media_type.dart';

class MemoryModel {
  const MemoryModel({
    required this.id,
    required this.imageUrl,
    required this.timestamp,
    required this.mediaType,
    required this.weddingId,
    this.guestName,
    this.message,
    this.tableNumber,
    this.storagePath,
    this.driveSyncStatus,
  });

  final String id;
  final String imageUrl;
  final DateTime timestamp;
  final String mediaType;
  final String weddingId;
  final String? guestName;
  final String? message;
  final String? tableNumber;
  final String? storagePath;
  final String? driveSyncStatus;

  factory MemoryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data[MemoryFields.timestamp];
    return MemoryModel(
      id: doc.id,
      imageUrl: data[MemoryFields.imageUrl] as String? ?? '',
      timestamp: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      mediaType: data[MemoryFields.mediaType] as String? ?? 'photo',
      weddingId: data[MemoryFields.weddingId] as String? ?? '',
      guestName: data[MemoryFields.guestName] as String?,
      message: data[MemoryFields.message] as String?,
      tableNumber: data[MemoryFields.tableNumber] as String?,
      storagePath: data[MemoryFields.storagePath] as String?,
      driveSyncStatus: data[MemoryFields.driveSyncStatus] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      MemoryFields.imageUrl: imageUrl,
      MemoryFields.timestamp: FieldValue.serverTimestamp(),
      MemoryFields.mediaType: mediaType,
      MemoryFields.weddingId: weddingId,
      if (guestName != null) MemoryFields.guestName: guestName,
      if (message != null) MemoryFields.message: message,
      if (tableNumber != null) MemoryFields.tableNumber: tableNumber,
      if (storagePath != null) MemoryFields.storagePath: storagePath,
    };
  }

  Memory toEntity() {
    return Memory(
      id: id,
      imageUrl: imageUrl,
      timestamp: timestamp,
      mediaType: MediaType.fromString(mediaType),
      weddingId: weddingId,
      guestName: guestName,
      message: message,
      tableNumber: tableNumber,
      storagePath: storagePath,
      driveSyncStatus: driveSyncStatus,
    );
  }
}
