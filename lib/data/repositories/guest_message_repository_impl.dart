import '../../core/config/wedding_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/guest_message.dart';
import '../../domain/repositories/guest_message_repository.dart';
import '../datasources/firebase/firebase_guest_message_datasource.dart';

class GuestMessageRepositoryImpl implements GuestMessageRepository {
  GuestMessageRepositoryImpl(this._dataSource);

  final FirebaseGuestMessageDataSource _dataSource;

  @override
  Future<Result<GuestMessageEntity>> submitMessage({
    required String text,
    String? guestName,
    String? weddingId,
  }) async {
    if (text.trim().isEmpty) {
      return const Error(ValidationFailure('Please write a message first.'));
    }
    if (text.trim().length > 500) {
      return const Error(
        ValidationFailure('Message must be 500 characters or less.'),
      );
    }

    try {
      final model = await _dataSource.submitMessage(
        text: text,
        guestName: guestName,
        weddingId: weddingId ?? WeddingConfig.weddingId,
      );
      return Success(model.toEntity());
    } on StorageException {
      return const Error(ServerFailure('Could not send your message.'));
    } catch (_) {
      return const Error(ServerFailure());
    }
  }
}
