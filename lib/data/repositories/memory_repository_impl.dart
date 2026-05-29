import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_upload.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/firebase/firebase_memory_datasource.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  MemoryRepositoryImpl(this._dataSource);

  final FirebaseMemoryDataSource _dataSource;

  @override
  Future<Result<Memory>> uploadMemory(MemoryUpload upload) async {
    try {
      final model = await _dataSource.uploadMemory(
        mediaFile: upload.mediaFile,
        mediaType: upload.mediaType,
        guestName: upload.guestName,
        message: upload.message,
        tableNumber: upload.tableNumber,
      );
      return Success(model.toEntity());
    } on StorageException {
      return const Error(StorageFailure());
    } on NetworkException {
      return const Error(NetworkFailure());
    } catch (_) {
      return const Error(ServerFailure());
    }
  }

  @override
  Stream<List<Memory>> watchMemories({String? weddingId}) {
    return _dataSource
        .watchMemories(weddingId: weddingId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Result<List<Memory>>> getMemories({String? weddingId}) async {
    try {
      final models = await _dataSource.getMemories(weddingId: weddingId);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (_) {
      return const Error(ServerFailure());
    }
  }
}
