import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forever_moments/core/services/media_capture_service.dart';
import 'package:forever_moments/presentation/cubit/capture/capture_cubit.dart';
import 'package:forever_moments/presentation/cubit/capture/capture_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockMediaCaptureService extends Mock implements MediaCaptureService {}

void main() {
  late _MockMediaCaptureService mediaCapture;

  setUp(() {
    mediaCapture = _MockMediaCaptureService();
  });

  blocTest<CaptureCubit, CaptureState>(
    'emits preview after successful photo capture',
    build: () => CaptureCubit(mediaCapture),
    setUp: () {
      when(() => mediaCapture.capturePhoto()).thenAnswer(
        (_) async => XFile.fromData(
          Uint8List.fromList(List.filled(8, 0)),
          name: 'test.jpg',
          mimeType: 'image/jpeg',
        ),
      );
    },
    act: (cubit) => cubit.capturePhoto(),
    expect: () => [
      isA<CaptureState>().having((s) => s.step, 'step', CaptureStep.capturing),
      isA<CaptureState>()
          .having((s) => s.step, 'step', CaptureStep.preview)
          .having((s) => s.capturedFile, 'file', isNotNull),
    ],
  );

  blocTest<CaptureCubit, CaptureState>(
    'returns to idle when capture is cancelled',
    build: () => CaptureCubit(mediaCapture),
    setUp: () {
      when(() => mediaCapture.captureVideo()).thenAnswer((_) async => null);
    },
    act: (cubit) => cubit.captureVideo(),
    expect: () => [
      isA<CaptureState>().having((s) => s.step, 'step', CaptureStep.capturing),
      isA<CaptureState>().having((s) => s.step, 'step', CaptureStep.idle),
    ],
  );

  blocTest<CaptureCubit, CaptureState>(
    'updates guest metadata fields',
    build: () => CaptureCubit(mediaCapture),
    act: (cubit) {
      cubit.updateGuestName('Sarah');
      cubit.updateMessage('Congratulations!');
      cubit.updateTableNumber('7');
    },
    expect: () => [
      isA<CaptureState>().having((s) => s.guestName, 'name', 'Sarah'),
      isA<CaptureState>().having((s) => s.message, 'message', 'Congratulations!'),
      isA<CaptureState>().having((s) => s.tableNumber, 'table', '7'),
    ],
  );
}
