import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/sizes.dart';
//import 'package:url_launcher/url_launcher_string.dart';

class TDeviceUtils {
  static void hideKeyBoards(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: color));
  }

  static bool isLandscapeOrientation(BuildContext context) {
    final viewInsest = View.of(context).viewInsets;

    return viewInsest.bottom == 0;
  }

  static bool isPortraitOrientation(BuildContext context) {
    final viewInsest = View.of(context).viewInsets;

    return viewInsest.bottom != 0;
  }

  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
        enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
  }

  static double getScreenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getPixelRatio() {
    return MediaQuery.of(Get.context!).devicePixelRatio;
  }

  static double getStatusbarHeight() {
    return MediaQuery.of(Get.context!).padding.top;
  }

  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  static double getAppbarHeight() {
    return kToolbarHeight;
  }

  static double getKeyBoardHeight() {
    final viewInsest = MediaQuery.of(Get.context!).viewInsets;

    return viewInsest.bottom;
  }

  static Future<bool> isKeyBoardVisible() async {
    final viewInsest = View.of(Get.context!).viewInsets;

    return viewInsest.bottom > 0;
  }

  static Future<bool> isPhysicalDevice() async {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static void vibrate(Duration duration) {
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }

  static Future<void> setPrefferedOrientations(
      List<DeviceOrientation> orintation) async {
    await SystemChrome.setPreferredOrientations(orintation);
  }

  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static bool isIos() {
    return Platform.isIOS;
  }

  static bool isDesktopScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= TSizes.desctopScreenSize;
  }

  static bool isTabletScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= TSizes.tabletScreenSize &&
        MediaQuery.of(context).size.width < TSizes.desctopScreenSize;
  }

  static bool isMobileScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < TSizes.tabletScreenSize;
  }

  // static void lunchUrl(String url) async {
  //   if (await canLaunchUrlString(url)) {
  //     await launchUrlString(url);
  //   } else {
  //     throw 'Could not lunch $url';
  //   }
  // }
}
