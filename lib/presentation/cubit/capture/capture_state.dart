import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/enums/media_type.dart';

enum CaptureStep { idle, capturing, preview, details }

class CaptureState extends Equatable {
  const CaptureState({
    this.step = CaptureStep.idle,
    this.mediaType,
    this.capturedFile,
    this.guestName = '',
    this.message = '',
    this.tableNumber = '',
    this.errorMessage,
  });

  final CaptureStep step;
  final MediaType? mediaType;
  final XFile? capturedFile;
  final String guestName;
  final String message;
  final String tableNumber;
  final String? errorMessage;

  bool get hasCapture => capturedFile != null && mediaType != null;
  bool get isCapturing => step == CaptureStep.capturing;

  CaptureState copyWith({
    CaptureStep? step,
    MediaType? mediaType,
    XFile? capturedFile,
    bool clearFile = false,
    String? guestName,
    String? message,
    String? tableNumber,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CaptureState(
      step: step ?? this.step,
      mediaType: mediaType ?? this.mediaType,
      capturedFile: clearFile ? null : (capturedFile ?? this.capturedFile),
      guestName: guestName ?? this.guestName,
      message: message ?? this.message,
      tableNumber: tableNumber ?? this.tableNumber,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        step,
        mediaType,
        capturedFile?.path,
        capturedFile?.name,
        guestName,
        message,
        tableNumber,
        errorMessage,
      ];
}
