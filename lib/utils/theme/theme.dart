import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:istoreto/utils/theme/custom_themes/elevated_button.theme.dart';
import 'package:istoreto/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:istoreto/utils/theme/custom_themes/text_button_theme.dart';
import 'package:istoreto/utils/theme/custom_themes/icon_button_theme.dart';
import 'package:istoreto/utils/theme/custom_themes/text_field_theme.dart';
import 'package:istoreto/utils/theme/custom_themes/text_theme.dart';
import 'package:istoreto/utils/theme/custom_themes/checkbox_theme.dart';

import 'custom_themes/appbar_theme.dart';

class TAppTheme {
  TAppTheme._();
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.tajawal().fontFamily,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0099ff),
      brightness: Brightness.light,
    ),

    // Primary Colors
    primaryColor: Colors.black, //const Color(0xFF0099ff),
    primaryColorLight: const Color(0xFF0099ff),
    primaryColorDark: const Color(0xFF0099ff),

    // Scaffold
    scaffoldBackgroundColor: Colors.white,

    // Themes
    textTheme: TTextTheme.lightTextTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    textButtonTheme: TTextButtonTheme.lightTextButtonTheme,
    iconButtonTheme: TIconButtonTheme.lightIconButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationThem,
    checkboxTheme: TCheckBoxTheme.lightCheckboxTheme,

    // Card Theme
    cardTheme: const CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: Colors.black87, size: 24),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3F50CB),
      brightness: Brightness.dark,
    ),

    // Primary Colors
    primaryColor: const Color(0xFF3F50CB),
    primaryColorLight: const Color(0xFF0099ff),
    primaryColorDark: const Color(0xFF3F50CB),

    // Scaffold
    scaffoldBackgroundColor: TColors.containerdarkColor,

    // Themes
    textTheme: TTextTheme.darkTextTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    textButtonTheme: TTextButtonTheme.darkTextButtonTheme,
    iconButtonTheme: TIconButtonTheme.darkIconButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationThem,
    checkboxTheme: TCheckBoxTheme.darkCheckboxTheme,

    // Card Theme
    cardTheme: const CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[700],
      thickness: 1,
      space: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: Colors.white70, size: 24),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}
