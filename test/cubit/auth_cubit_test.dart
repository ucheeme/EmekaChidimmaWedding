import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forever_moments/core/utils/result.dart';
import 'package:forever_moments/domain/repositories/auth_repository.dart';
import 'package:forever_moments/domain/usecases/sign_in_anonymously.dart';
import 'package:forever_moments/presentation/cubit/auth/auth_cubit.dart';
import 'package:forever_moments/presentation/cubit/auth/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SignInAnonymously signInAnonymously;

  setUp(() {
    repository = _MockAuthRepository();
    signInAnonymously = SignInAnonymously(repository);
  });

  blocTest<AuthCubit, AuthState>(
    'emits authenticated when session exists',
    build: () => AuthCubit(
      authRepository: repository,
      signInAnonymously: signInAnonymously,
    ),
    setUp: () {
      when(() => repository.getCurrentUserId())
          .thenAnswer((_) async => const Success('guest-123'));
    },
    act: (cubit) => cubit.ensureSession(),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.authenticated)
          .having((s) => s.userId, 'uid', 'guest-123'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signs in anonymously when no session',
    build: () => AuthCubit(
      authRepository: repository,
      signInAnonymously: signInAnonymously,
    ),
    setUp: () {
      when(() => repository.getCurrentUserId())
          .thenAnswer((_) async => const Success(null));
      when(() => repository.signInAnonymously())
          .thenAnswer((_) async => const Success('new-guest'));
    },
    act: (cubit) => cubit.ensureSession(),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.authenticated)
          .having((s) => s.userId, 'uid', 'new-guest'),
    ],
  );
}
