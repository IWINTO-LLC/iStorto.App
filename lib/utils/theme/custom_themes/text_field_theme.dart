import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();
  static InputDecorationTheme lightInputDecorationThem = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey[600],
    suffixIconColor: Colors.grey[600],
    filled: true,
    fillColor: Colors.grey[100],
    labelStyle: const TextStyle().copyWith(
      fontSize: 16,
      color: Colors.grey[600],
      fontWeight: FontWeight.w400,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 16,
      color: Colors.grey[600],
      fontWeight: FontWeight.w400,
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: Colors.red[600],
      fontSize: 14,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: Colors.grey[600],
      fontSize: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red[600]!, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red[600]!, width: 2),
    ),
    contentPadding: const EdgeInsets.only(
      left: 16,
      right: 16,
      top: 6,
      bottom: 4,
    ),
  );

  static InputDecorationTheme darkInputDecorationThem = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey[400],
    suffixIconColor: Colors.grey[400],
    filled: true,
    fillColor: Colors.grey[800],
    labelStyle: const TextStyle().copyWith(
      fontSize: 16,
      color: Colors.grey[400],
      fontWeight: FontWeight.w400,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 16,
      color: Colors.grey[400],
      fontWeight: FontWeight.w400,
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: Colors.red[400],
      fontSize: 14,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: Colors.grey[400],
      fontSize: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red[400]!, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red[400]!, width: 2),
    ),
    contentPadding: const EdgeInsets.only(
      left: 16,
      right: 16,
      top: 6,
      bottom: 4,
    ),
  );
}
