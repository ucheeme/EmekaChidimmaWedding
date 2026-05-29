import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/connectivity_service.dart';
import 'connectivity_state.dart';

/// App-wide online/offline status for graceful offline UX.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._connectivity) : super(const ConnectivityState()) {
    _init();
  }

  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _subscription;

  Future<void> _init() async {
    final online = await _connectivity.isOnline;
    emit(ConnectivityState(isOnline: online));

    _subscription = _connectivity.onConnectivityChanged.listen((online) {
      emit(ConnectivityState(isOnline: online));
    });
  }

  Future<void> refresh() async {
    final online = await _connectivity.isOnline;
    emit(ConnectivityState(isOnline: online));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
