import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forever_moments/presentation/cubit/upload/upload_memory_cubit.dart';
import 'package:forever_moments/presentation/cubit/upload/upload_memory_state.dart';

void main() {
  blocTest<UploadMemoryCubit, UploadMemoryState>(
    'starts in initial state',
    build: () => UploadMemoryCubit(null),
    expect: () => [],
    verify: (cubit) {
      expect(cubit.state.status, UploadMemoryStatus.initial);
    },
  );

  blocTest<UploadMemoryCubit, UploadMemoryState>(
    'reset returns to initial',
    build: () => UploadMemoryCubit(null),
    seed: () => const UploadMemoryState(
      status: UploadMemoryStatus.failure,
      message: 'error',
    ),
    act: (cubit) => cubit.reset(),
    expect: () => [const UploadMemoryState()],
  );
}
