import 'package:audioplayers/audioplayers.dart';

/// Owns the single background-music player used across the guest experience.
///
/// Browsers block audio until a user gesture, so [play] is only ever called
/// from within a tap handler (the intro "Enter" button) or the app-bar toggle.
class MusicService {
  final AudioPlayer _player = AudioPlayer();
  String? _url;
  bool _sourceSet = false;

  bool get hasTrack => _url != null && _url!.isNotEmpty;
  bool get isPlaying => _player.state == PlayerState.playing;
  Stream<PlayerState> get onStateChanged => _player.onPlayerStateChanged;

  void setUrl(String? url) {
    if (url == _url) return;
    _url = url;
    _sourceSet = false;
  }

  Future<void> play() async {
    if (!hasTrack) return;
    if (!_sourceSet) {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.55);
      await _player.setSource(UrlSource(_url!));
      _sourceSet = true;
    }
    await _player.resume();
  }

  Future<void> pause() => _player.pause();

  Future<void> dispose() => _player.dispose();
}
