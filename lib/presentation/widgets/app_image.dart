import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

bool _isNetwork(String source) =>
    source.startsWith('http://') || source.startsWith('https://');

/// Returns the correct [ImageProvider] for a bundled asset or a remote URL.
///
/// Used by widgets (e.g. [PhotoView]) that require a provider rather than a
/// widget. Keeps the rest of the UI agnostic about where a photo lives.
ImageProvider appImageProvider(String source) => _isNetwork(source)
    ? CachedNetworkImageProvider(source)
    : AssetImage(source) as ImageProvider;

/// Renders an image from either a local asset path or a network URL, choosing
/// the appropriate loader transparently.
///
/// This lets the gallery/love-story screens reference the couple's bundled
/// photos while still tolerating remote URLs without any call-site changes.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (_isNetwork(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => const _ImagePlaceholder(),
        errorWidget: (_, __, ___) => const _ImageError(),
      );
    }

    return Image.asset(
      source,
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const _ImageError(),
    );
  }
}

/// Image wrapped in a slow, continuous "Ken Burns" pan-and-zoom for a
/// cinematic feel. Purely cosmetic and safe — it only animates a [Transform].
class KenBurnsImage extends StatefulWidget {
  const KenBurnsImage({
    super.key,
    required this.source,
    this.duration = const Duration(seconds: 12),
    this.maxScale = 1.12,
    this.fit = BoxFit.cover,
  });

  final String source;
  final Duration duration;
  final double maxScale;
  final BoxFit fit;

  @override
  State<KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);
          final scale = 1 + (widget.maxScale - 1) * t;
          final dx = (t - 0.5) * 12;
          return Transform.scale(
            scale: scale,
            child: Transform.translate(offset: Offset(dx, -dx), child: child),
          );
        },
        child: AppImage(source: widget.source, fit: widget.fit),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softPink,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softPink,
      child: Icon(
        Icons.favorite,
        color: AppColors.roseGold.withValues(alpha: 0.4),
      ),
    );
  }
}
