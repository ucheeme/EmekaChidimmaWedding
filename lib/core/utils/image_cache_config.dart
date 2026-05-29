import 'package:flutter/material.dart';

/// Helpers for responsive image caching in gallery grids.
abstract final class ImageCacheConfig {
  static int memCacheWidth(BuildContext context, {int columns = 2}) {
    final width = MediaQuery.sizeOf(context).width;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ((width / columns) * dpr).round();
  }
}
