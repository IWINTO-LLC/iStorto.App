import 'package:get/get.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/edit_category_controller.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/data/repositories/category_repository.dart';
import 'package:istoreto/featured/album/controller/album_controller.dart';
import 'package:istoreto/featured/album/controller/photo_controller.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/controller/save_for_later.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/utils/http/network.dart';
import 'package:istoreto/utils/logging/logger.dart';
import 'package:istoreto/utils/upload.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() async {
    // Get.put(SectorController());
    TLoggerHelper.info("SectorController initialize");
    Get.put(CurrencyController());
    Get.put(TranslateController());

    Get.put(UploadService());

    try {
      Get.put(ProductController());
      TLoggerHelper.info("ProductController initialize (outside auth check)");
    } catch (e) {
      TLoggerHelper.info("Error initializing ProductController: $e");
    }
    Get.put(VendorRepository());
    try {
      Get.put(VendorController());
      TLoggerHelper.info("VendorController initialize (outside auth check)");
    } catch (e) {
      TLoggerHelper.info("Error initializing VendorController: $e");
    }

    try {
      Get.put(CategoryController());
      TLoggerHelper.info("CategoryController initialize (outside auth check)");
    } catch (e) {
      TLoggerHelper.info("Error initializing CategoryController: $e");
    }

    // Order matters
    if (Supabase.instance.client.auth.currentUser != null) {
      Get.put(NetworkManager());
      TLoggerHelper.info("net work initialize");
      Get.put(CategoryRepository());

      try {
        Get.put(SavedController());
        TLoggerHelper.info("SavedController initialize (outside auth check)");
      } catch (e) {
        TLoggerHelper.info("Error initializing SavedController: $e");
      }

      try {
        Get.put(FavoriteProductsController());
        TLoggerHelper.info(
          "FavoriteProductsController initialize (outside auth check)",
        );
      } catch (e) {
        TLoggerHelper.info("Error initializing FavoriteProductsController: $e");
      }

      TLoggerHelper.info("CategoryRepository initialize");
      Get.put(BannerController());

      TLoggerHelper.info("BannerControllerinitialize");
      TLoggerHelper.info("SaveForLaterController initialize");
      Get.put(SaveForLaterController());
      Get.put(OrderController());

      //SaveForLaterController
      TLoggerHelper.info("ProductController initialize");
      Get.put(EditProductController());
      Get.put(AlbumController());
      Get.put(PhotoController());
      Get.put(FollowController());
      TLoggerHelper.info("EditProductController initialize");

      TLoggerHelper.info("VendorController initialize");

      //
      TLoggerHelper.info("CartController initialize");
      Get.put(CartController());
      TLoggerHelper.info("SectorController initialize");
      Get.put(EditCategoryController());

      TLoggerHelper.info("EditCategoryController initialize");

      Get.put(AddressService());
      TLoggerHelper.info("AddressService initialize");
    }
  }

  // دالة للتحقق من أن جميع المتحكمات المطلوبة جاهزة
  static bool areControllersReady() {
    // التحقق من المتحكمات الأساسية
    if (!Get.isRegistered<SavedController>()) {
      TLoggerHelper.info("SavedController is not ready");
      return false;
    }

    if (!Get.isRegistered<FavoriteProductsController>()) {
      TLoggerHelper.info("FavoriteProductsController is not ready");
      return false;
    }

    if (!Get.isRegistered<ProductController>()) {
      TLoggerHelper.info("ProductController is not ready");
      return false;
    }

    if (!Get.isRegistered<VendorController>()) {
      TLoggerHelper.info("VendorController is not ready");
      return false;
    }

    if (!Get.isRegistered<CategoryController>()) {
      TLoggerHelper.info("CategoryController is not ready");
      return false;
    }

    // التحقق من المتحكمات التي تتطلب تسجيل دخول
    if (Supabase.instance.client.auth.currentUser != null) {
      if (!Get.isRegistered<NetworkManager>()) {
        TLoggerHelper.info("NetworkManager is not ready");
        return false;
      }

      if (!Get.isRegistered<CategoryRepository>()) {
        TLoggerHelper.info("CategoryRepository is not ready");
        return false;
      }

      if (!Get.isRegistered<BannerController>()) {
        TLoggerHelper.info("BannerController is not ready");
        return false;
      }

      if (!Get.isRegistered<SaveForLaterController>()) {
        TLoggerHelper.info("SaveForLaterController is not ready");
        return false;
      }

      if (!Get.isRegistered<OrderController>()) {
        TLoggerHelper.info("OrderController is not ready");
        return false;
      }

      if (!Get.isRegistered<EditProductController>()) {
        TLoggerHelper.info("EditProductController is not ready");
        return false;
      }

      if (!Get.isRegistered<AlbumController>()) {
        TLoggerHelper.info("AlbumController is not ready");
        return false;
      }

      if (!Get.isRegistered<PhotoController>()) {
        TLoggerHelper.info("PhotoController is not ready");
        return false;
      }

      if (!Get.isRegistered<FollowController>()) {
        TLoggerHelper.info("FollowController is not ready");
        return false;
      }

      if (!Get.isRegistered<CartController>()) {
        TLoggerHelper.info("CartController is not ready");
        return false;
      }

      if (!Get.isRegistered<EditCategoryController>()) {
        TLoggerHelper.info("EditCategoryController is not ready");
        return false;
      }

      if (!Get.isRegistered<AddressService>()) {
        TLoggerHelper.info("AddressService is not ready");
        return false;
      }
    }

    return true;
  }

  // دالة للانتظار حتى تكون جميع المتحكمات جاهزة
  static Future<void> waitForControllers() async {
    while (!areControllersReady()) {
      await Future.delayed(Duration(milliseconds: 50));
    }
    TLoggerHelper.info("All controllers are ready!");
  }
}
