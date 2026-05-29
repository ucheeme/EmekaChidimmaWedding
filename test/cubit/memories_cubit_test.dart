import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forever_moments/presentation/cubit/memories/memories_cubit.dart';
import 'package:forever_moments/presentation/cubit/memories/memories_state.dart';

void main() {
  blocTest<MemoriesCubit, MemoriesState>(
    'emits demo data when Firebase is not configured',
    build: MemoriesCubit.new,
    act: (cubit) => cubit.startWatching(),
    expect: () => [
      isA<MemoriesState>()
          .having((s) => s.status, 'status', MemoriesStatus.loaded)
          .having((s) => s.isDemoData, 'isDemo', true)
          .having((s) => s.memories.isNotEmpty, 'has items', true),
    ],
  );

  blocTest<MemoriesCubit, MemoriesState>(
    'retry reloads demo data',
    build: MemoriesCubit.new,
    act: (cubit) {
      cubit.startWatching();
      cubit.retry();
    },
    expect: () => [
      isA<MemoriesState>().having((s) => s.status, 'status', MemoriesStatus.loaded),
      isA<MemoriesState>().having((s) => s.status, 'status', MemoriesStatus.loading),
      isA<MemoriesState>().having((s) => s.status, 'status', MemoriesStatus.loaded),
    ],
  );
}
