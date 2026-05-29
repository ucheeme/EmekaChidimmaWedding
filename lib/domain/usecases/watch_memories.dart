import '../entities/memory.dart';
import '../repositories/memory_repository.dart';

class WatchMemories {
  const WatchMemories(this._repository);

  final MemoryRepository _repository;

  Stream<List<Memory>> call({String? weddingId}) =>
      _repository.watchMemories(weddingId: weddingId);
}
