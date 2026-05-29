import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/media/video_player_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/enums/media_type.dart';

/// Preview captured photo or video before upload (mobile + web).
class MediaPreview extends StatefulWidget {
  const MediaPreview({
    super.key,
    required this.file,
    required this.mediaType,
  });

  final XFile file;
  final MediaType mediaType;

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _videoController;
  Future<void>? _videoInit;
  Future<Uint8List>? _photoBytes;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == MediaType.video) {
      _initVideo();
    } else {
      _photoBytes = widget.file.readAsBytes();
    }
  }

  void _initVideo() {
    _videoController = createVideoController(widget.file);
    _videoInit = _videoController!.initialize().then((_) {
      _videoController!
        ..setLooping(true)
        ..play();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: widget.mediaType == MediaType.video &&
                _videoController != null &&
                _videoController!.value.isInitialized
            ? _videoController!.value.aspectRatio
            : 3 / 4,
        child: Container(
          color: AppColors.deepWine.withValues(alpha: 0.08),
          child: widget.mediaType == MediaType.photo
              ? _buildPhotoPreview()
              : _buildVideoPreview(),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return FutureBuilder<Uint8List>(
      future: _photoBytes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }

  Widget _buildVideoPreview() {
    return FutureBuilder<void>(
      future: _videoInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            _videoController == null ||
            !_videoController!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDuration(_videoController!.value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '0:$seconds';
  }
}
