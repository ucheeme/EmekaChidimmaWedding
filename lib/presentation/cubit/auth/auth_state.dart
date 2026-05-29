import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.message,
  });

  final AuthStatus status;
  final String? userId;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, userId, message];
}
