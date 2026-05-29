import 'package:equatable/equatable.dart';

import '../../../domain/entities/memory.dart';

enum UploadMemoryStatus { initial, uploading, success, failure }

class UploadMemoryState extends Equatable {
  const UploadMemoryState({
    this.status = UploadMemoryStatus.initial,
    this.memory,
    this.message,
    this.progress,
  });

  final UploadMemoryStatus status;
  final Memory? memory;
  final String? message;
  final double? progress;

  bool get isUploading => status == UploadMemoryStatus.uploading;

  UploadMemoryState copyWith({
    UploadMemoryStatus? status,
    Memory? memory,
    String? message,
    double? progress,
  }) {
    return UploadMemoryState(
      status: status ?? this.status,
      memory: memory ?? this.memory,
      message: message,
      progress: progress,
    );
  }

  @override
  List<Object?> get props => [status, memory, message, progress];
}
