import 'package:flutter/material.dart';

class AppConstants {
  // Shared Preferences keys
  static const String keyIsDarkMode = 'isDarkMode';
  static const String keyPinCode = 'pinCode';

  // App Strings
  static const String appName = 'Dear Days';
  static const String defaultDiaryTitle = 'Untitled Entry';

  // Padding and Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;

  // Colors
  static const Color primaryColor = Colors.indigo;
  static const Color accentColor = Colors.indigoAccent;

  // Font Sizes
  static const double titleFontSize = 20.0;
  static const double contentFontSize = 16.0;

  // Border Radius
  static const BorderRadius defaultBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );

  // Date Format
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String fullDateTimeFormat = 'dd MMM yyyy • hh:mm a';
}
