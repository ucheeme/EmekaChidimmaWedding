import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';

import '../enums/media_type.dart';

/// Payload for uploading a new guest memory (works on mobile and web).
class MemoryUpload extends Equatable {
  const MemoryUpload({
    required this.mediaFile,
    required this.mediaType,
    this.guestName,
    this.message,
    this.tableNumber,
  });

  final XFile mediaFile;
  final MediaType mediaType;
  final String? guestName;
  final String? message;
  final String? tableNumber;

  @override
  List<Object?> get props => [
        mediaFile.path,
        mediaFile.name,
        mediaType,
        guestName,
        message,
        tableNumber,
      ];
}
