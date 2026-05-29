import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in_anonymously.dart';
import 'auth_state.dart';

/// Manages anonymous guest authentication session.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthRepository? authRepository,
    SignInAnonymously? signInAnonymously,
  })  : _authRepository = authRepository,
        _signInAnonymously = signInAnonymously,
        super(const AuthState());

  final AuthRepository? _authRepository;
  final SignInAnonymously? _signInAnonymously;

  /// Restores existing session or signs in anonymously.
  Future<void> ensureSession() async {
    if (_authRepository == null || _signInAnonymously == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, message: null));

    final existing = await _authRepository.getCurrentUserId();
    if (existing.isSuccess && existing.valueOrNull != null) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          userId: existing.valueOrNull,
        ),
      );
      return;
    }

    final result = await _signInAnonymously();
    result.when(
      onSuccess: (uid) {
        AppLogger.info('Guest session ready', tag: 'AuthCubit');
        emit(AuthState(status: AuthStatus.authenticated, userId: uid));
      },
      onFailure: (failure) {
        AppLogger.warning('Guest sign-in failed', tag: 'AuthCubit');
        emit(
          AuthState(
            status: AuthStatus.failure,
            message: failure.message,
          ),
        );
      },
    );
  }
}
