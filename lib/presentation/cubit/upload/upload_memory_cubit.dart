import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/memory_upload.dart';
import '../../../domain/usecases/upload_memory.dart';
import 'upload_memory_state.dart';

/// Handles guest photo/video upload flow (Stage 8 wires camera capture).
class UploadMemoryCubit extends Cubit<UploadMemoryState> {
  UploadMemoryCubit(
    this._uploadMemory, {
    ConnectivityService? connectivity,
  })  : _connectivity = connectivity,
        super(const UploadMemoryState());

  final UploadMemory? _uploadMemory;
  final ConnectivityService? _connectivity;

  Future<void> upload(MemoryUpload payload) async {
    final online =
        _connectivity != null ? await _connectivity.isOnline : true;
    if (!online) {
      emit(
        const UploadMemoryState(
          status: UploadMemoryStatus.failure,
          message: 'You\'re offline. Connect to the internet to upload.',
        ),
      );
      return;
    }

    if (_uploadMemory == null) {
      emit(
        const UploadMemoryState(
          status: UploadMemoryStatus.failure,
          message: 'Upload is unavailable until Firebase is configured.',
        ),
      );
      return;
    }

    emit(
      const UploadMemoryState(
        status: UploadMemoryStatus.uploading,
        progress: 0,
      ),
    );

    final result = await _uploadMemory(payload);

    result.when(
      onSuccess: (memory) {
        AppLogger.info('Memory uploaded', tag: 'UploadMemoryCubit');
        emit(
          UploadMemoryState(
            status: UploadMemoryStatus.success,
            memory: memory,
            progress: 1,
          ),
        );
      },
      onFailure: (failure) {
        AppLogger.warning('Upload failed', tag: 'UploadMemoryCubit');
        emit(
          UploadMemoryState(
            status: UploadMemoryStatus.failure,
            message: failure.message,
          ),
        );
      },
    );
  }

  void reset() => emit(const UploadMemoryState());
}
