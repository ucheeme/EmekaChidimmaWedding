import '../../core/utils/result.dart';
import '../entities/guest_message.dart';
import '../repositories/guest_message_repository.dart';

class SubmitGuestMessage {
  const SubmitGuestMessage(this._repository);

  final GuestMessageRepository _repository;

  Future<Result<GuestMessageEntity>> call({
    required String text,
    String? guestName,
    String? weddingId,
  }) =>
      _repository.submitMessage(
        text: text,
        guestName: guestName,
        weddingId: weddingId,
      );
}
