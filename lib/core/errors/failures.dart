import 'package:equatable/equatable.dart';

/// Base failure for domain layer error handling.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Please check your connection and try again.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Unable to sign you in. Please try again.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Upload failed. Please try again.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to load saved data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
