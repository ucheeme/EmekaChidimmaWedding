import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_logger.dart';
import '../../data/datasources/firebase/firebase_memory_datasource.dart';
import '../../domain/entities/memory.dart';

enum ModerationStatus { loading, loaded, empty, error }

class ModerationState extends Equatable {
  const ModerationState({
    this.status = ModerationStatus.loading,
    this.memories = const [],
    this.actioningIds = const {},
    this.message,
  });

  final ModerationStatus status;
  final List<Memory> memories;

  /// Ids currently being hidden/shown/deleted (for per-tile spinners).
  final Set<String> actioningIds;
  final String? message;

  int get visibleCount => memories.where((m) => m.visible).length;
  int get hiddenCount => memories.where((m) => !m.visible).length;

  ModerationState copyWith({
    ModerationStatus? status,
    List<Memory>? memories,
    Set<String>? actioningIds,
    String? message,
  }) {
    return ModerationState(
      status: status ?? this.status,
      memories: memories ?? this.memories,
      actioningIds: actioningIds ?? this.actioningIds,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, memories, actioningIds, message];
}

/// Streams every guest memory (including hidden) and lets an admin hide/show or
/// permanently remove uploads from the guest gallery.
class ModerationCubit extends Cubit<ModerationState> {
  ModerationCubit(this._dataSource) : super(const ModerationState());

  final FirebaseMemoryDataSource _dataSource;
  StreamSubscription? _subscription;

  void start() {
    emit(state.copyWith(status: ModerationStatus.loading, message: null));
    _subscription?.cancel();
    _subscription = _dataSource.watchAllMemories().listen(
      (models) {
        final memories = models.map((m) => m.toEntity()).toList(growable: false);
        emit(state.copyWith(
          status: memories.isEmpty
              ? ModerationStatus.empty
              : ModerationStatus.loaded,
          memories: memories,
        ));
      },
      onError: (Object error, StackTrace stack) {
        AppLogger.error('Moderation stream error',
            tag: 'Moderation', error: error, stackTrace: stack);
        emit(state.copyWith(
          status: ModerationStatus.error,
          message: 'Unable to load uploads. Pull to retry.',
        ));
      },
    );
  }

  Future<void> setVisible(String id, bool visible) async {
    _markActioning(id, true);
    try {
      await _dataSource.setMemoryVisibility(memoryId: id, visible: visible);
    } catch (e, stack) {
      AppLogger.error('Set visibility failed',
          tag: 'Moderation', error: e, stackTrace: stack);
      emit(state.copyWith(message: 'Could not update that upload.'));
    } finally {
      _markActioning(id, false);
    }
  }

  Future<void> remove(String id) async {
    _markActioning(id, true);
    try {
      await _dataSource.deleteMemory(id);
    } catch (e, stack) {
      AppLogger.error('Delete memory failed',
          tag: 'Moderation', error: e, stackTrace: stack);
      emit(state.copyWith(message: 'Could not remove that upload.'));
    } finally {
      _markActioning(id, false);
    }
  }

  void _markActioning(String id, bool active) {
    final next = Set<String>.from(state.actioningIds);
    if (active) {
      next.add(id);
    } else {
      next.remove(id);
    }
    emit(state.copyWith(actioningIds: next));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
