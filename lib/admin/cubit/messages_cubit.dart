import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_logger.dart';
import '../../data/datasources/firebase/firebase_guest_message_datasource.dart';
import '../../domain/entities/guest_message.dart';

enum AdminMessagesStatus { loading, loaded, empty, error }

class AdminMessagesState extends Equatable {
  const AdminMessagesState({
    this.status = AdminMessagesStatus.loading,
    this.messages = const [],
    this.actioningIds = const {},
    this.message,
  });

  final AdminMessagesStatus status;
  final List<GuestMessageEntity> messages;
  final Set<String> actioningIds;
  final String? message;

  AdminMessagesState copyWith({
    AdminMessagesStatus? status,
    List<GuestMessageEntity>? messages,
    Set<String>? actioningIds,
    String? message,
  }) {
    return AdminMessagesState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      actioningIds: actioningIds ?? this.actioningIds,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, messages, actioningIds, message];
}

/// Streams guest text messages for review and allows admins to remove them.
class AdminMessagesCubit extends Cubit<AdminMessagesState> {
  AdminMessagesCubit(this._dataSource) : super(const AdminMessagesState());

  final FirebaseGuestMessageDataSource _dataSource;
  StreamSubscription? _subscription;

  void start() {
    emit(state.copyWith(status: AdminMessagesStatus.loading, message: null));
    _subscription?.cancel();
    _subscription = _dataSource.watchMessages().listen(
      (models) {
        final messages = models.map((m) => m.toEntity()).toList(growable: false);
        emit(state.copyWith(
          status: messages.isEmpty
              ? AdminMessagesStatus.empty
              : AdminMessagesStatus.loaded,
          messages: messages,
        ));
      },
      onError: (Object error, StackTrace stack) {
        AppLogger.error('Messages stream error',
            tag: 'AdminMessages', error: error, stackTrace: stack);
        emit(state.copyWith(
          status: AdminMessagesStatus.error,
          message: 'Unable to load messages. Pull to retry.',
        ));
      },
    );
  }

  Future<void> remove(String id) async {
    final next = Set<String>.from(state.actioningIds)..add(id);
    emit(state.copyWith(actioningIds: next));
    try {
      await _dataSource.deleteMessage(id);
    } catch (e, stack) {
      AppLogger.error('Delete message failed',
          tag: 'AdminMessages', error: e, stackTrace: stack);
      emit(state.copyWith(message: 'Could not remove that message.'));
    } finally {
      final after = Set<String>.from(state.actioningIds)..remove(id);
      emit(state.copyWith(actioningIds: after));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
