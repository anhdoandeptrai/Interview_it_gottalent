import 'package:flutter/material.dart';

class SplashConstants {
  // App Information
  static const String appName = 'Interview Practice';
  static const String appTagline = 'Master Your Skills with AI';
  static const String appVersion = 'Version 1.0.0';
  static const String designedBy = 'Designed by Doan Duong';
  static const String copyright = '© 2025 Interview Practice App';

  // Colors
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  static const Color accentColor = Color(0xFF4F46E5);
  static const Color darkNavy = Color(0xFF0F0F23);
  static const Color mediumNavy = Color(0xFF1A1A2E);
  static const Color lightNavy = Color(0xFF16213E);
  static const Color glowColor = Color(0xFF7C3AED);
  static const Color shimmerColor = Color(0xFF9333EA);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkNavy, mediumNavy, lightNavy],
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient textGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
  );

  // Animation Durations
  static const Duration logoAnimationDuration = Duration(milliseconds: 1500);
  static const Duration textAnimationDuration = Duration(milliseconds: 1000);
  static const Duration progressAnimationDuration =
      Duration(milliseconds: 2000);
  static const Duration minimumSplashDuration = Duration(seconds: 3);

  // Sizes
  static const double logoSize = 120.0;
  static const double titleFontSize = 32.0;
  static const double taglineFontSize = 16.0;
  static const double loadingTextFontSize = 16.0;
  static const double versionFontSize = 12.0;
  static const double progressBarHeight = 4.0;

  // Spacings
  static const double logoToTitleSpacing = 30.0;
  static const double titleToTaglineSpacing = 8.0;
  static const double textToProgressSpacing = 20.0;
  static const double progressToPercentageSpacing = 10.0;
  static const double progressToVersionSpacing = 40.0;
  static const double horizontalPadding = 40.0;

  // Opacity Values
  static const double textOpacity = 0.9;
  static const double taglineOpacity = 0.8;
  static const double loadingTextOpacity = 0.9;
  static const double versionOpacity = 0.5;
  static const double progressBackgroundOpacity = 0.2;
  static const double percentageOpacity = 0.7;

  // Loading Steps
  static const List<Map<String, dynamic>> loadingSteps = [
    {'text': 'Initializing Firebase Services...', 'delay': 800, 'icon': '🔥'},
    {'text': 'Loading AI Intelligence...', 'delay': 600, 'icon': '🤖'},
    {'text': 'Setting up Camera Detection...', 'delay': 500, 'icon': '📸'},
    {'text': 'Preparing Speech Recognition...', 'delay': 400, 'icon': '🎤'},
    {'text': 'Optimizing Performance...', 'delay': 300, 'icon': '⚡'},
    {'text': 'Almost Ready to Practice...', 'delay': 200, 'icon': '🚀'},
  ];

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get taglineStyle => TextStyle(
        fontSize: taglineFontSize,
        color: Colors.white.withValues(alpha: taglineOpacity),
        letterSpacing: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get loadingTextStyle => TextStyle(
        fontSize: loadingTextFontSize,
        color: Colors.white.withValues(alpha: loadingTextOpacity),
        fontWeight: FontWeight.w500,
      );

  static TextStyle get percentageStyle => TextStyle(
        fontSize: 14,
        color: Colors.white.withValues(alpha: percentageOpacity),
        fontWeight: FontWeight.w600,
      );

  static TextStyle get versionStyle => TextStyle(
        fontSize: versionFontSize,
        color: Colors.white.withValues(alpha: versionOpacity),
      );

  static TextStyle get designerStyle => const TextStyle(
        fontSize: 12,
        color: Color(0xFFB8C5D1),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get copyrightStyle => TextStyle(
        fontSize: 10,
        color: Colors.white.withValues(alpha: 0.4),
        fontWeight: FontWeight.w300,
      );

  // Shadow Effects
  static List<BoxShadow> get logoShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.4),
          blurRadius: 25,
          spreadRadius: 8,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: glowColor.withValues(alpha: 0.2),
          blurRadius: 40,
          spreadRadius: 12,
          offset: const Offset(0, 5),
        ),
      ];

  static List<BoxShadow> get progressBarShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 2,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ];

  // Animation Curves
  static const Curve logoAnimationCurve = Curves.elasticOut;
  static const Curve textAnimationCurve = Curves.easeInOut;
  static const Curve slideAnimationCurve = Curves.easeOutBack;
  static const Curve progressAnimationCurve = Curves.easeInOut;

  // Slide Animation Offset
  static const Offset slideAnimationBegin = Offset(0, 1);
  static const Offset slideAnimationEnd = Offset.zero;
}
