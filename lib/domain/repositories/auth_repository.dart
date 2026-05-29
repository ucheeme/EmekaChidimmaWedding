import '../../core/utils/result.dart';

/// Authentication operations (anonymous guest sessions).
abstract class AuthRepository {
  Future<Result<String>> signInAnonymously();

  Future<Result<String?>> getCurrentUserId();
}
