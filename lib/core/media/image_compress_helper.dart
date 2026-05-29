import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses images before upload (mobile/desktop only; web uploads as-is).
abstract final class ImageCompressHelper {
  static Future<Uint8List> preparePhotoBytes(Uint8List source) async {
    if (kIsWeb) {
      return source;
    }

    final compressed = await FlutterImageCompress.compressWithList(
      source,
      quality: 85,
      minWidth: 1920,
      minHeight: 1920,
    );

    return compressed.isEmpty ? source : compressed;
  }
}
