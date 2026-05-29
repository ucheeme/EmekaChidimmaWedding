import 'package:equatable/equatable.dart';

enum GuestMessageStatus { initial, submitting, success, failure }

class GuestMessageState extends Equatable {
  const GuestMessageState({
    this.status = GuestMessageStatus.initial,
    this.message,
  });

  final GuestMessageStatus status;
  final String? message;

  bool get isSubmitting => status == GuestMessageStatus.submitting;

  GuestMessageState copyWith({
    GuestMessageStatus? status,
    String? message,
  }) {
    return GuestMessageState(
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
