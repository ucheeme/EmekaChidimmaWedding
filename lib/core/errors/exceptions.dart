/// Thrown when a remote data source encounters an error.
class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error', super.code]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error', super.code]);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Storage error', super.code]);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error', super.code]);
}
