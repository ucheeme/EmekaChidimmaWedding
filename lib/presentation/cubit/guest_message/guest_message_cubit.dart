import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/submit_guest_message.dart';
import 'guest_message_state.dart';

class GuestMessageCubit extends Cubit<GuestMessageState> {
  GuestMessageCubit({
    SubmitGuestMessage? submitGuestMessage,
    ConnectivityService? connectivity,
  })  : _submit = submitGuestMessage,
        _connectivity = connectivity,
        super(const GuestMessageState());

  final SubmitGuestMessage? _submit;
  final ConnectivityService? _connectivity;

  Future<void> submit({
    required String text,
    String? guestName,
  }) async {
    final online = _connectivity != null
        ? await _connectivity.isOnline
        : true;
    if (!online) {
      emit(
        const GuestMessageState(
          status: GuestMessageStatus.failure,
          message: 'You\'re offline. Connect to send your message.',
        ),
      );
      return;
    }

    if (_submit == null) {
      emit(
        const GuestMessageState(
          status: GuestMessageStatus.failure,
          message: 'Messaging is unavailable until Firebase is configured.',
        ),
      );
      return;
    }

    emit(const GuestMessageState(status: GuestMessageStatus.submitting));

    final result = await _submit(
      text: text,
      guestName: guestName,
    );

    result.when(
      onSuccess: (_) {
        AppLogger.info('Guest message sent', tag: 'GuestMessageCubit');
        emit(const GuestMessageState(status: GuestMessageStatus.success));
      },
      onFailure: (failure) {
        emit(
          GuestMessageState(
            status: GuestMessageStatus.failure,
            message: failure.message,
          ),
        );
      },
    );
  }

  void reset() => emit(const GuestMessageState());
}
