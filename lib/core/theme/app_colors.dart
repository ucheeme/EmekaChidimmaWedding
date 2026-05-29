import 'package:flutter/material.dart';

/// Joyce & Emeka wedding palette.
/// Black · army green · mint green · gold · wine red · white · chocolate brown.
abstract final class AppColors {
  // --- Core wedding colors ---

  /// Black — dramatic hero backgrounds & dark screens.
  static const noir = Color(0xFF0E0E0E);

  /// Chocolate brown — primary text, dark surfaces (reads on light bg).
  static const deepWine = Color(0xFF2B1A10);

  /// Wine red — special accents & celebratory CTAs.
  static const wine = Color(0xFF6E1A2B);

  /// Army green — secondary accent & deep gradient tone.
  static const olive = Color(0xFF3E4A2B);

  /// Mint green — soft highlights & friendly accents.
  static const mint = Color(0xFFA8D8C0);

  /// Gold — primary accent, couple names, dividers, shimmer.
  static const roseGold = Color(0xFFC49A2D);

  /// Deeper gold/bronze for outlines & pressed states.
  static const goldDeep = Color(0xFFA8842A);

  /// White — content backgrounds.
  static const blush = Color(0xFFFAF8F3);

  /// Pure white card surface / light text on dark.
  static const ivory = Color(0xFFFFFFFF);

  // --- Supporting neutrals ---

  /// Mint-tinted neutral for gradient midtones.
  static const softPink = Color(0xFFE4EDE6);

  /// Pale gold wash.
  static const champagne = Color(0xFFEFE6CC);

  /// Near-black espresso for the darkest gradient stop.
  static const espresso = Color(0xFF0B0B0B);

  // --- Gradients ---

  /// Light, clean content background (white → mint → pale gold).
  static const gradientRomantic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blush, softPink, champagne],
  );

  /// Dramatic hero gradient (black → chocolate → army green).
  static const gradientProgram = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [noir, deepWine, olive],
    stops: [0.0, 0.55, 1.0],
  );

  /// Dark mode for gallery / wedding wall.
  static const gradientNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [espresso, Color(0xFF1A130C), Color(0xFF20281A)],
  );
}
