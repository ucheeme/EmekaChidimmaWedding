import 'package:equatable/equatable.dart';

class ConnectivityState extends Equatable {
  const ConnectivityState({this.isOnline = true});

  final bool isOnline;

  ConnectivityState copyWith({bool? isOnline}) {
    return ConnectivityState(isOnline: isOnline ?? this.isOnline);
  }

  @override
  List<Object?> get props => [isOnline];
}
