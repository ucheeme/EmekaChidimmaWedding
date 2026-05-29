import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController createVideoController(XFile file) {
  return VideoPlayerController.networkUrl(Uri.parse(file.path));
}
