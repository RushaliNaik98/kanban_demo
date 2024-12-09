import 'package:flutter/material.dart';

class AppColors {
  static Color appNameColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.white;
  static Color textColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.black;
  static Color columnColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xff221c44) : Colors.white;
  static Color todoColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xff949494) : const Color(0xff949494);
  static Color inProgressColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xff3eaced) : const Color(0xff3eaced);
  static Color completedColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xff38c589) : const Color(0xff38c589);
  static Color backgroundColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xff1d0539) : Colors.deepPurple;
  static Color backgroundBodyGradientHigh(bool isDarkMode) =>
      isDarkMode ? const Color(0xff1d0539) : const Color(0xfff0e7f6);
  static Color backgroundBodyGradientLow(bool isDarkMode) =>
      isDarkMode ? const Color(0xff101213) : const Color(0xffc9b1d6);
  static Color statusTextColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.white;

  static Color primaryColor(bool isDarkMode) =>
      isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple;

  static Color accentColor(bool isDarkMode) =>
      isDarkMode ? Colors.blueGrey : Colors.indigo;

  static Color cardColor(bool isDarkMode) =>
      isDarkMode ? Colors.grey[800]! : Colors.white;

  static Color iconColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.black;
  static Color innerScreenTextColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.black;
  static Color tileColor(bool isDarkMode) =>
      isDarkMode ? Colors.grey : Colors.white;
  static Color tileIconColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xff1d0539) : Colors.deepPurple;
}
