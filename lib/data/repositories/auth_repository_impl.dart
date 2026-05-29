import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  Future<Result<String>> signInAnonymously() async {
    try {
      final uid = await _dataSource.signInAnonymously();
      return Success(uid);
    } on AuthException {
      return const Error(AuthFailure());
    } catch (_) {
      return const Error(ServerFailure());
    }
  }

  @override
  Future<Result<String?>> getCurrentUserId() async {
    try {
      return Success(_dataSource.getCurrentUserId());
    } catch (_) {
      return const Error(ServerFailure());
    }
  }
}
