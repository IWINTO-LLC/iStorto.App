import 'package:flutter/material.dart';

class TCheckBoxTheme {
  TCheckBoxTheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF0099ff);
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    side: BorderSide(color: Colors.grey[400]!, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF3F50CB);
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    side: BorderSide(color: Colors.grey[600]!, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );
}
