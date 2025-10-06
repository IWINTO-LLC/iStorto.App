import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  // Primary Button - أسود مع نص أبيض (مثل "Let's get started")
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,

      backgroundColor: Colors.black,
      disabledBackgroundColor: Colors.grey[400],
      disabledForegroundColor: Colors.grey[600],
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 4, top: 6),
      textStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.tajawal().fontFamily,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // زوايا مدورة مثل الحبة
      ),
      minimumSize: const Size(double.infinity, 50), // عرض كامل مع ارتفاع مناسب
    ),
  );

  // Dark Theme - نفس التصميم
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey[400],
      disabledForegroundColor: Colors.grey[600],
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 4, top: 6),
      textStyle: TextStyle(
        fontSize: 16.0,
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25), // زوايا مدورة مثل الحبة
      ),
      minimumSize: const Size(double.infinity, 50), // عرض كامل مع ارتفاع مناسب
    ),
  );
}
