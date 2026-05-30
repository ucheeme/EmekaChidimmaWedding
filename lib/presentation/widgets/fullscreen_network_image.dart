import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Pinch-zoom fullscreen viewer for guest-uploaded photos.
///
/// Uses [InteractiveViewer] + [CachedNetworkImage] instead of [PhotoView] with
/// an [ImageProvider], which is unreliable on Flutter web and often shows
/// corrupt or blank images for Firebase Storage URLs.
class FullscreenNetworkImage extends StatelessWidget {
  const FullscreenNetworkImage({super.key, required this.imageUrl});

  final String imageUrl;

  static Future<void> open(BuildContext context, String imageUrl) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FullscreenNetworkImage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: AppColors.roseGold),
            ),
            errorWidget: (_, __, ___) => Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.roseGold),
                );
              },
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
