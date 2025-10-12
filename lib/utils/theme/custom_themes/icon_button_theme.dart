import 'package:flutter/material.dart';

class TIconButtonTheme {
  TIconButtonTheme._();

  // Icon Button - دائري أسود مع أيقونة بيضاء (مثل الزر مع السهم)
  static final lightIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      elevation: 1,
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      disabledForegroundColor: Colors.grey[400],
      disabledBackgroundColor: Colors.grey[300],
      padding: const EdgeInsets.all(6),
      minimumSize: const Size(20, 20),
      maximumSize: const Size(40, 40),
      shape: const CircleBorder(),
      iconSize: 20,
    ),
  );

  // Dark Theme
  static final darkIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      disabledForegroundColor: Colors.grey[600],
      disabledBackgroundColor: Colors.grey[700],
      padding: const EdgeInsets.all(6),
      minimumSize: const Size(40, 40),
      maximumSize: const Size(40, 40),
      shape: const CircleBorder(),
      iconSize: 20,
    ),
  );
}
