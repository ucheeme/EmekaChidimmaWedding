import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController createVideoController(XFile file) {
  return VideoPlayerController.file(File(file.path));
}
