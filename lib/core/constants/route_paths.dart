/// GoRouter path constants.
class RoutePaths {
  const RoutePaths._();

  static const String splash = '/';
  /// QR launch path — more reliable than query params on Flutter web.
  static const String start = '/start';
  static const String qrGate = '/join';
  static const String intro = '/intro';
  static const String loveStory = '/love-story';
  static const String preWeddingGallery = '/pre-wedding-gallery';
  static const String loveNotes = '/love-notes';
  static const String program = '/program';
  static const String home = '/home';
  static const String capture = '/capture';

  static String capturePhoto = '$capture?type=photo';
  static String captureVideo = '$capture?type=video';
  static const String liveGallery = '/live-gallery';
  static const String weddingWall = '/wedding-wall';
  static const String guestMessage = '/guest-message';
  static const String firebaseSetup = '/firebase-setup';
}
