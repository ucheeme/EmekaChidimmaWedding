import 'package:audioplayers/audioplayers.dart';

import '../utils/app_logger.dart';

/// Owns the single background-music player used across the guest experience.
///
/// Browsers block audio until a user gesture, so [play] is only ever called
/// from within a tap handler (the intro "Enter" button) or the app-bar toggle.
class MusicService {
  final AudioPlayer _player = AudioPlayer();
  String? _url;

  bool get hasTrack => _url != null && _url!.isNotEmpty;
  bool get isPlaying => _player.state == PlayerState.playing;
  Stream<PlayerState> get onStateChanged => _player.onPlayerStateChanged;

  void setUrl(String? url) {
    if (url == _url) return;
    _url = url;
  }

  /// Starts or resumes playback. Uses [play(UrlSource)] which is reliable on
  /// web; the previous setSource + resume pattern often silently failed on iOS
  /// Safari and mobile browsers.
  Future<void> play() async {
    if (!hasTrack) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.55);
      await _player.stop();
      await _player.play(UrlSource(_url!));
    } catch (e, stack) {
      AppLogger.error(
        'Music playback failed',
        tag: 'MusicService',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> dispose() => _player.dispose();
}
