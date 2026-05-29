import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forever_moments/core/services/connectivity_service.dart';
import 'package:forever_moments/presentation/cubit/guest_message/guest_message_cubit.dart';
import 'package:forever_moments/presentation/cubit/guest_message/guest_message_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late _MockConnectivityService connectivity;

  setUp(() {
    connectivity = _MockConnectivityService();
    when(() => connectivity.isOnline).thenAnswer((_) async => true);
  });

  blocTest<GuestMessageCubit, GuestMessageState>(
    'fails when Firebase is not configured',
    build: () => GuestMessageCubit(connectivity: connectivity),
    act: (cubit) => cubit.submit(text: 'Congratulations!'),
    expect: () => [
      isA<GuestMessageState>()
          .having((s) => s.status, 'status', GuestMessageStatus.failure)
          .having((s) => s.message, 'message', contains('Firebase')),
    ],
  );

  blocTest<GuestMessageCubit, GuestMessageState>(
    'fails when offline',
    build: () => GuestMessageCubit(connectivity: connectivity),
    setUp: () {
      when(() => connectivity.isOnline).thenAnswer((_) async => false);
    },
    act: (cubit) => cubit.submit(text: 'Congratulations!'),
    expect: () => [
      isA<GuestMessageState>()
          .having((s) => s.status, 'status', GuestMessageStatus.failure)
          .having((s) => s.message, 'message', contains('offline')),
    ],
  );
}
