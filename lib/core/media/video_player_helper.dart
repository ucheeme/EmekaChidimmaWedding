import 'video_player_helper_stub.dart'
    if (dart.library.io) 'video_player_helper_io.dart' as impl;

import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController createVideoController(XFile file) =>
    impl.createVideoController(file);
