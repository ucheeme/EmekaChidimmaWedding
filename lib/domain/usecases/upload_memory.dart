import '../../core/utils/result.dart';
import '../entities/memory.dart';
import '../entities/memory_upload.dart';
import '../repositories/memory_repository.dart';

class UploadMemory {
  const UploadMemory(this._repository);

  final MemoryRepository _repository;

  Future<Result<Memory>> call(MemoryUpload upload) =>
      _repository.uploadMemory(upload);
}
