/// Centralized registry of bundled media assets.
///
/// Keeping every asset path in one place prevents typo-driven runtime crashes
/// (Flutter throws at paint time for a missing asset) and makes it trivial to
/// swap photos without touching presentation code.
abstract final class AppAssets {
  static const String _img = 'assets/images';

  // Love story chapters.
  static const String storyMet = '$_img/met.jpg';
  static const String storyJourney = '$_img/journey.jpg';
  static const String storyProposal = '$_img/proposal_kneel.jpg';
  static const String storyForever = '$_img/trad_01.jpg';

  // Proposal moments.
  static const String proposalKneel = '$_img/proposal_kneel.jpg';
  static const String proposalRing1 = '$_img/ring_01.jpg';
  static const String proposalRing2 = '$_img/ring_02.jpg';
  static const String proposalHug = '$_img/hug.jpg';
  static const String proposalCelebrate = '$_img/celebrate.jpg';

  // Studio pre-wedding shoot.
  static const String white1 = '$_img/white_01.jpg';
  static const String white2 = '$_img/white_02.jpg';
  static const String white3 = '$_img/white_03.jpg';
  static const String portraitBride = '$_img/portrait_bride.jpg';
  static const String embrace = '$_img/embrace.jpg';
  static const String elegantBlue = '$_img/elegant_blue.jpg';
  static const String trad1 = '$_img/trad_01.jpg';
  static const String trad2 = '$_img/trad_02.jpg';
  static const String trad3 = '$_img/trad_03.jpg';
  static const String trad4 = '$_img/trad_04.jpg';

  // Candid couple moments.
  static const String casual1 = '$_img/casual_01.jpg';
  static const String casual2 = '$_img/casual_02.jpg';
  static const String casual3 = '$_img/casual_03.jpg';
  static const String casual4 = '$_img/casual_04.jpg';
  static const String groomSolo = '$_img/groom_solo.jpg';

  // Motion — short clips.
  static const String clip1 = '$_img/clip_01.mp4';
  static const String clip2 = '$_img/clip_02.mp4';
  static const String clip3 = '$_img/clip_03.mp4';
}
