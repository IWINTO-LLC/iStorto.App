import 'package:flutter/material.dart';

class TTextButtonTheme {
  TTextButtonTheme._();

  // Text Button - نص رمادي بدون خلفية
  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.grey[600],
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.grey[400],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // Dark Theme
  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.grey[300],
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.grey[600],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
