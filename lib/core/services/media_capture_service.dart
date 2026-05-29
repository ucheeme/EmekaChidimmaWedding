import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_logger.dart';

/// Handles camera permissions and photo/video capture (mobile + web).
class MediaCaptureService {
  MediaCaptureService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const maxVideoDuration = Duration(seconds: 30);

  Future<bool> requestPermissions({required bool forVideo}) async {
    if (kIsWeb) {
      return true;
    }

    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      AppLogger.warning('Camera permission denied', tag: 'MediaCapture');
      return false;
    }

    if (forVideo) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        AppLogger.warning('Microphone permission denied', tag: 'MediaCapture');
        return false;
      }
    }

    return true;
  }

  Future<XFile?> capturePhoto() async {
    final granted = await requestPermissions(forVideo: false);
    if (!granted) return null;

    try {
      return _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
        preferredCameraDevice: CameraDevice.rear,
      );
    } catch (e, stack) {
      AppLogger.error(
        'Photo capture failed',
        tag: 'MediaCapture',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<XFile?> captureVideo() async {
    final granted = await requestPermissions(forVideo: true);
    if (!granted) return null;

    try {
      return _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxVideoDuration,
        preferredCameraDevice: CameraDevice.rear,
      );
    } catch (e, stack) {
      AppLogger.error(
        'Video capture failed',
        tag: 'MediaCapture',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
