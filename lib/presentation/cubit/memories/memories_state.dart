import 'package:equatable/equatable.dart';

import '../../../domain/entities/memory.dart';

enum MemoriesStatus { initial, loading, loaded, empty, failure }

class MemoriesState extends Equatable {
  const MemoriesState({
    this.status = MemoriesStatus.initial,
    this.memories = const [],
    this.isDemoData = false,
    this.message,
  });

  final MemoriesStatus status;
  final List<Memory> memories;
  final bool isDemoData;
  final String? message;

  bool get isLoading =>
      status == MemoriesStatus.loading || status == MemoriesStatus.initial;
  bool get hasMemories => memories.isNotEmpty;

  MemoriesState copyWith({
    MemoriesStatus? status,
    List<Memory>? memories,
    bool? isDemoData,
    String? message,
  }) {
    return MemoriesState(
      status: status ?? this.status,
      memories: memories ?? this.memories,
      isDemoData: isDemoData ?? this.isDemoData,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, memories, isDemoData, message];
}
