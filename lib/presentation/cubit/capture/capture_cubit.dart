import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/media_capture_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/enums/media_type.dart';
import 'capture_state.dart';

/// Manages camera capture, preview, and guest metadata before upload.
class CaptureCubit extends Cubit<CaptureState> {
  CaptureCubit(this._mediaCapture) : super(const CaptureState());

  final MediaCaptureService _mediaCapture;

  Future<void> capturePhoto() => _capture(MediaType.photo);

  Future<void> captureVideo() => _capture(MediaType.video);

  Future<void> _capture(MediaType type) async {
    emit(
      state.copyWith(
        step: CaptureStep.capturing,
        mediaType: type,
        clearError: true,
        clearFile: true,
      ),
    );

    try {
      final file = type == MediaType.photo
          ? await _mediaCapture.capturePhoto()
          : await _mediaCapture.captureVideo();

      if (file == null) {
        emit(
          state.copyWith(
            step: CaptureStep.idle,
            clearFile: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          step: CaptureStep.preview,
          capturedFile: file,
          mediaType: type,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          step: CaptureStep.idle,
          errorMessage: type == MediaType.photo
              ? 'Could not take photo. Please try again.'
              : 'Could not record video. Please try again.',
        ),
      );
    }
  }

  void retake() {
    final type = state.mediaType;
    if (type == null) return;
    if (type == MediaType.photo) {
      capturePhoto();
    } else {
      captureVideo();
    }
  }

  void goToDetails() {
    if (!state.hasCapture) return;
    emit(state.copyWith(step: CaptureStep.details, clearError: true));
  }

  void backToPreview() {
    if (!state.hasCapture) return;
    emit(state.copyWith(step: CaptureStep.preview, clearError: true));
  }

  void updateGuestName(String value) {
    emit(state.copyWith(guestName: value.trim()));
  }

  void updateMessage(String value) {
    emit(state.copyWith(message: value.trim()));
  }

  void updateTableNumber(String value) {
    emit(state.copyWith(tableNumber: value.trim()));
  }

  void reset() {
    AppLogger.debug('Capture flow reset', tag: 'CaptureCubit');
    emit(const CaptureState());
  }
}
