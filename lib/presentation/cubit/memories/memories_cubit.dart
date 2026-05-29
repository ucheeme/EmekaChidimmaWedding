import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/demo_memories.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/memory.dart';
import '../../../domain/usecases/watch_memories.dart';
import 'memories_state.dart';

/// Real-time guest memories for live gallery and wedding wall.
class MemoriesCubit extends Cubit<MemoriesState> {
  MemoriesCubit({WatchMemories? watchMemories})
      : _watchMemories = watchMemories,
        super(const MemoriesState());

  final WatchMemories? _watchMemories;
  StreamSubscription<List<Memory>>? _subscription;

  void startWatching() {
    final watchMemories = _watchMemories;
    if (watchMemories == null) {
      _emitDemoData();
      return;
    }

    emit(state.copyWith(status: MemoriesStatus.loading, message: null));
    _subscription?.cancel();

    _subscription = watchMemories().listen(
      _onMemoriesUpdated,
      onError: _onStreamError,
    );
  }

  void _onMemoriesUpdated(List<Memory> list) {
    if (list.isEmpty) {
      emit(
        const MemoriesState(
          status: MemoriesStatus.empty,
          isDemoData: false,
        ),
      );
      return;
    }

    emit(
      MemoriesState(
        status: MemoriesStatus.loaded,
        memories: list,
        isDemoData: false,
      ),
    );
  }

  void _onStreamError(Object error, StackTrace stack) {
    AppLogger.error(
      'Memories stream error',
      tag: 'MemoriesCubit',
      error: error,
      stackTrace: stack,
    );
    emit(
      const MemoriesState(
        status: MemoriesStatus.failure,
        message: 'Unable to load memories. Pull to retry.',
      ),
    );
  }

  void _emitDemoData() {
    emit(
      MemoriesState(
        status: MemoriesStatus.loaded,
        memories: DemoMemories.gallery,
        isDemoData: true,
      ),
    );
  }

  void retry() {
    if (_watchMemories == null) {
      emit(state.copyWith(status: MemoriesStatus.loading, message: null));
      _emitDemoData();
      return;
    }
    startWatching();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
