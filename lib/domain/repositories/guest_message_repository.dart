import '../../core/utils/result.dart';
import '../entities/guest_message.dart';

abstract class GuestMessageRepository {
  Future<Result<GuestMessageEntity>> submitMessage({
    required String text,
    String? guestName,
    String? weddingId,
  });
}
