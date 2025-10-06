// نظام المسارات المركزي للتطبيق
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/home-page/views/home_page.dart';
import 'package:istoreto/featured/product/views/favorite_products_list.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/featured/shop/view/policy_page.dart';
import 'package:istoreto/featured/shop/view/policy_webview_page.dart';
import 'package:istoreto/featured/shop/view/seller.info.dart';
import 'package:istoreto/featured/shop/view/store_settings.dart';
import 'package:istoreto/views/splash_screen.dart';
import 'package:istoreto/navigation_menu.dart';
import 'package:istoreto/views/login_page.dart';
import 'package:istoreto/views/register_page.dart';
import 'package:istoreto/views/email_verification_page.dart';

import 'package:istoreto/views/orders_page.dart';

import 'package:istoreto/views/profile_page.dart';

class AppRoutes {
  // الصفحات الرئيسية
  static const String home = '/home';

  // صفحات المتجر والتاجر
  static const String marketPlace = '/market-place';
  static const String marketPlaceManagement = '/market-place-management';
  static const String storeSettings = '/store-settings';

  // صفحات السياسات
  static const String policyPage = '/policy-page';
  static const String policyPageNew = '/policy-page-new';
  static const String policyWebView = '/policy-webview';
  static const String sellerInfo = '/seller-info';

  // صفحات الفئات والمنتجات
  static const String createCategory = '/create-category';
  static const String productDetails = '/product-details';
  static const String allCategories = '/all-categories';

  // صفحات أخرى
  static const String profile = '/profile';
  static const String settings = '/settings';

  // صفحات المصادقة والتنقل
  static const String splash = '/';
  static const String navigationMenu = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String cart = '/cart';
}

// قائمة المسارات
final List<GetPage> appRoutes = [
  // الصفحات الأساسية
  GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
  GetPage(name: AppRoutes.navigationMenu, page: () => const NavigationMenu()),

  // صفحات المصادقة
  GetPage(name: AppRoutes.login, page: () => const LoginPage()),
  GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
  GetPage(
    name: AppRoutes.emailVerification,
    page: () => const EmailVerificationPage(),
  ),

  // صفحات التطبيق
  GetPage(name: AppRoutes.favorites, page: () => const FavoriteProductsPage()),
  GetPage(name: AppRoutes.orders, page: () => const OrdersPage()),

  GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),

  // الصفحة الرئيسية
  GetPage(name: AppRoutes.home, page: () => const HomePage()),

  // صفحات المتجر
  GetPage(
    name: AppRoutes.marketPlace,
    page:
        () => MarketPlaceView(
          editMode: Get.arguments['editMode'] ?? false,
          vendorId: Get.arguments['vendorId'] ?? '',
        ),
  ),

  GetPage(
    name: AppRoutes.marketPlaceManagement,
    page:
        () => MarketPlaceManagment(
          editMode: Get.arguments['editMode'] ?? false,
          vendorId: Get.arguments['vendorId'] ?? '',
        ),
  ),

  GetPage(
    name: AppRoutes.storeSettings,
    page:
        () => VendorSettingsPage(
          vendorId: Get.arguments['vendorId'] ?? '',
          fromBage:
              Get.arguments['fromBage'], // Pass the required 'fromBage' argument
        ),
  ),

  // صفحات السياسات
  GetPage(
    name: AppRoutes.policyPage,
    page: () => PolicyPage(vendorId: Get.arguments['vendorId'] ?? ''),
  ),

  // GetPage(
  //   name: AppRoutes.policyPageNew,
  //   page: () => PolicyPageNew(vendorId: Get.arguments['vendorId'] ?? ''),
  // ),
  GetPage(
    name: AppRoutes.policyWebView,
    page:
        () => PolicyWebViewPage(
          url: Get.arguments['url'] ?? '',
          title: Get.arguments['title'] ?? '',
        ),
  ),

  GetPage(
    name: AppRoutes.sellerInfo,
    page: () => PolicyDisplayPage(vendorId: Get.arguments['vendorId'] ?? ''),
  ),

  // صفحات الفئات والمنتجات
  GetPage(
    name: AppRoutes.createCategory,
    page: () => CreateCategory(vendorId: Get.arguments['vendorId'] ?? ''),
  ),

  GetPage(
    name: AppRoutes.productDetails,
    page:
        () => ProductDetails(
          product: Get.arguments['product'],
          vendorId: Get.arguments['vendorId'] ?? '',
          selected: Get.arguments['selected'] ?? 0,
          spotList: Get.arguments['spotList'] ?? [],
          key: UniqueKey(),
        ),
  ),

  // GetPage(name: AppRoutes.allCategories, page: () => AllCategories()),
];
