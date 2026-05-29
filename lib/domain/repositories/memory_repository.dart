import '../../core/utils/result.dart';
import '../entities/memory.dart';
import '../entities/memory_upload.dart';

/// Guest memory uploads and live gallery stream.
abstract class MemoryRepository {
  Future<Result<Memory>> uploadMemory(MemoryUpload upload);

  Stream<List<Memory>> watchMemories({String? weddingId});

  Future<Result<List<Memory>>> getMemories({String? weddingId});
}
