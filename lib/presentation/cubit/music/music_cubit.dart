import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/music_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/datasources/firebase/firebase_content_datasource.dart';

class MusicState extends Equatable {
  const MusicState({this.hasTrack = false, this.playing = false});

  final bool hasTrack;
  final bool playing;

  MusicState copyWith({bool? hasTrack, bool? playing}) =>
      MusicState(hasTrack: hasTrack ?? this.hasTrack, playing: playing ?? this.playing);

  @override
  List<Object?> get props => [hasTrack, playing];
}

/// Controls background music: discovers the configured track, plays it after
/// the first user gesture, and exposes a play/pause toggle for the app bars.
class MusicCubit extends Cubit<MusicState> {
  MusicCubit({required MusicService service, FirebaseContentDataSource? dataSource})
      : _service = service,
        _dataSource = dataSource,
        super(const MusicState()) {
    _sub = _service.onStateChanged.listen((s) {
      emit(state.copyWith(playing: s == PlayerState.playing));
    });
  }

  final MusicService _service;
  final FirebaseContentDataSource? _dataSource;
  StreamSubscription<PlayerState>? _sub;
  bool _autoStartRequested = false;

  Future<void> load() async {
    final dataSource = _dataSource;
    if (dataSource == null) return;
    try {
      final url = await dataSource.fetchMusicUrl();
      _service.setUrl(url);
      emit(state.copyWith(hasTrack: _service.hasTrack));
      // If the user already passed the intro before the track resolved, honour it.
      if (_autoStartRequested) unawaited(_service.play());
    } catch (e, stack) {
      AppLogger.error('Music load failed',
          tag: 'Music', error: e, stackTrace: stack);
    }
  }

  /// Called from a user gesture (intro "Enter") — satisfies browser autoplay.
  Future<void> userStart() async {
    _autoStartRequested = true;
    if (state.hasTrack && !state.playing) {
      await _service.play();
    }
  }

  Future<void> toggle() async {
    if (!state.hasTrack) {
      await load();
    }
    if (!state.hasTrack) return;

    try {
      if (state.playing) {
        await _service.pause();
      } else {
        await _service.play();
      }
    } catch (e, stack) {
      AppLogger.error('Music toggle failed',
          tag: 'Music', error: e, stackTrace: stack);
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
