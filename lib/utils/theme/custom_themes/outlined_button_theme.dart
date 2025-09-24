import 'package:flutter/material.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  // Outlined Button - حدود رمادية مع نص رمادي
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.grey[600],
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.grey[400],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      minimumSize: const Size(double.infinity, 50),
    ),
  );

  // Dark Theme
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.grey[300],
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.grey[600],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      side: BorderSide(color: Colors.grey[600]!, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      minimumSize: const Size(double.infinity, 50),
    ),
  );
}
