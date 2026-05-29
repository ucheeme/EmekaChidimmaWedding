import 'package:equatable/equatable.dart';

/// Text message left by a wedding guest.
class GuestMessageEntity extends Equatable {
  const GuestMessageEntity({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.weddingId,
    this.guestName,
  });

  final String id;
  final String text;
  final DateTime timestamp;
  final String weddingId;
  final String? guestName;

  @override
  List<Object?> get props => [id, text, timestamp, weddingId, guestName];
}
