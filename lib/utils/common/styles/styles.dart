import 'package:flutter/material.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';

final isArabic = TranslationController.instance.isRTL;
var titilliumRegular = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeDefault,
);

var titilliumSemiBold = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontSize: TSizes.fontSizeLarge,
  fontWeight: FontWeight.w500,
);

var titilliumNormal = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontSize: TSizes.fontSizeDefault,
  fontWeight: FontWeight.normal,
);

var titilliumBold = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontSize: TSizes.fontSizeDefault,
  fontWeight: FontWeight.w600,
);
var titilliumItalic = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontSize: TSizes.fontSizeDefault,
  fontStyle: FontStyle.italic,
);

var robotoHintRegular = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeSmall,
  color: Colors.grey,
);
var robotoRegular = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeDefault,
);
var robotoRegularMainHeadingAddProduct = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeDefault,
);

var robotoRegularForAddProductHeading = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  color: Color(0xFF9D9D9D),
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeSmall,
);

var robotoTitleRegular = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeLarge,
);

var robotoSmallTitleRegular = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontWeight: FontWeight.w400,
  fontSize: TSizes.fontSizeSmall,
);

var robotoBold = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontSize: TSizes.fontSizeDefault,
  fontWeight: FontWeight.w600,
);

var robotoMedium = TextStyle(
  fontFamily: isArabic ? arabicFonts : englishFonts,
  fontSize: TSizes.fontSizeDefault,
  fontWeight: FontWeight.w500,
);

class ThemeShadow {
  static List<BoxShadow> getShadow(BuildContext context) {
    List<BoxShadow> boxShadow = [
      BoxShadow(
        color: Theme.of(context).primaryColor.withValues(alpha: .075),
        blurRadius: 5,
        spreadRadius: 1,
        offset: const Offset(1, 1),
      ),
    ];
    return boxShadow;
  }
}
