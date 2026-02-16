import 'package:flutter/material.dart';

class ThemeConfig {
  final Color primaryColor;
  final Color accentColor;
  final Color scaffoldBackgroundColor;
  final Color cardColor;
  final Color errorColor;

  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle bodyStyle;
  final TextStyle buttonStyle;
  final TextStyle captionStyle;

  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;

  final double borderRadiusSm;
  final double borderRadiusMd;
  final double borderRadiusLg;

  ThemeConfig({
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldBackgroundColor,
    required this.cardColor,
    required this.errorColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.bodyStyle,
    required this.buttonStyle,
    required this.captionStyle,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.borderRadiusSm,
    required this.borderRadiusMd,
    required this.borderRadiusLg,
  });

  static ThemeConfig get light => ThemeConfig(
    primaryColor: const Color(0xFF2196F3),
    accentColor: const Color(0xFF03DAC6),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    errorColor: const Color(0xFFB00020),
    titleStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    subtitleStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
    ),
    bodyStyle: const TextStyle(fontSize: 14, color: Colors.black87),
    buttonStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    captionStyle: const TextStyle(fontSize: 12, color: Colors.black45),
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
    borderRadiusSm: 4,
    borderRadiusMd: 8,
    borderRadiusLg: 16,
  );

  static ThemeConfig get dark => ThemeConfig(
    primaryColor: const Color(0xFF90CAF9),
    accentColor: const Color(0xFF03DAC6),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    errorColor: const Color(0xFFCF6679),
    titleStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    subtitleStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    bodyStyle: const TextStyle(fontSize: 14, color: Colors.white70),
    buttonStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    captionStyle: const TextStyle(fontSize: 12, color: Colors.white60),
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
    borderRadiusSm: 4,
    borderRadiusMd: 8,
    borderRadiusLg: 16,
  );
}
