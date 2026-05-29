import 'package:equatable/equatable.dart';

import '../enums/media_type.dart';

/// Guest-uploaded wedding memory (photo or video metadata).
class Memory extends Equatable {
  const Memory({
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
  final MediaType mediaType;
  final String weddingId;
  final String? guestName;
  final String? message;
  final String? tableNumber;
  final String? storagePath;
  final String? driveSyncStatus;

  bool get isVideo => mediaType == MediaType.video;

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        timestamp,
        mediaType,
        weddingId,
        guestName,
        message,
        tableNumber,
        storagePath,
        driveSyncStatus,
      ];
}
