import '../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymously {
  const SignInAnonymously(this._repository);

  final AuthRepository _repository;

  Future<Result<String>> call() => _repository.signInAnonymously();
}
