import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

class DeleteController extends GetxController {
  static DeleteController get instance => Get.find();

  // Observable Variables
  final isDeleting = false.obs;
  final currentStep = ''.obs;
  final isCompleted = false.obs;
  final errorMessage = ''.obs;
  final progressPercentage = 0.0.obs;

  // Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // Controllers
  final VendorController profileController = Get.find<VendorController>();
  final ProductController productController = Get.find<ProductController>();
  final OrderController orderController = Get.find<OrderController>();

  @override
  void onInit() {
    super.onInit();
    resetState();
  }

  // إعادة تعيين الحالة
  void resetState() {
    isDeleting.value = false;
    currentStep.value = '';
    isCompleted.value = false;
    errorMessage.value = '';
    progressPercentage.value = 0.0;
  }

  // بدء عملية الحذف
  Future<bool> startStoreDeletion(String vendorId) async {
    try {
      resetState();
      isDeleting.value = true;
      progressPercentage.value = 0.0;

      // التحقق من وجود طلبات
      final hasOrders = await orderController.hasOrders(vendorId);
      if (hasOrders) {
        errorMessage.value = 'store_settings_store_has_orders_message'.tr;
        return false;
      }

      // حذف الفئات
      await _deleteCategories(vendorId);
      progressPercentage.value = 16.67;

      // حذف المنتجات
      await _deleteProducts(vendorId);
      progressPercentage.value = 33.33;

      // حذف البنرات
      await _deleteBanners(vendorId);
      progressPercentage.value = 50.0;

      // حذف المتابعات
      await _deleteFollowers(vendorId);
      progressPercentage.value = 66.67;

      // حذف الطلبات
      await _deleteOrders(vendorId);
      progressPercentage.value = 83.33;

      // حذف الروابط الاجتماعية
      await _deleteSocialLinks(vendorId);
      progressPercentage.value = 91.67;

      // حذف الملف الشخصي
      await _deleteProfile(vendorId);
      progressPercentage.value = 100.0;

      // تحديث حالة المتجر
      await _updateStoreStatus(vendorId);

      isCompleted.value = true;
      return true;
    } catch (e) {
      errorMessage.value = 'Error deleting store: $e';
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // حذف الفئات
  Future<void> _deleteCategories(String vendorId) async {
    currentStep.value = 'حذف الفئات...';

    try {
      // حذف الفئات من Supabase
      await _client
          .from('vendor_categories')
          .delete()
          .eq('vendor_id', vendorId);

      // تحديث القوائم المحلية
      CategoryController.instance.allItems.clear();
      CategoryController.instance.featureCategories.clear();
      CategoryController.instance.felteredItems.clear();
      CategoryController.instance.productCount.value = 0;
      CategoryController.instance.categoryName.clear();
      CategoryController.instance.categoryArabicName.clear();
      CategoryController.instance.categoryImage.clear();
      CategoryController.instance.storeId.value = '';

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting categories: $e');
    }
  }

  // حذف المنتجات
  Future<void> _deleteProducts(String vendorId) async {
    currentStep.value = 'حذف المنتجات...';

    try {
      // حذف المنتجات من Supabase
      await _client.from('products').delete().eq('vendor_id', vendorId);

      // تحديث القوائم المحلية
      productController.allItems.clear();
      productController.tempProducts.clear();
      productController.spotList.clear();

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting products: $e');
    }
  }

  // حذف البنرات
  Future<void> _deleteBanners(String vendorId) async {
    currentStep.value = 'حذف البنرات...';

    try {
      // حذف البنرات من Supabase
      await _client.from('banners').delete().eq('vendor_id', vendorId);

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting banners: $e');
    }
  }

  // حذف المتابعات
  Future<void> _deleteFollowers(String vendorId) async {
    currentStep.value = 'حذف المتابعات...';

    try {
      // حذف المتابعات من Supabase
      await _client.from('user_follows').delete().eq('vendor_id', vendorId);

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting followers: $e');
    }
  }

  // حذف الطلبات
  Future<void> _deleteOrders(String vendorId) async {
    currentStep.value = 'حذف الطلبات...';

    try {
      // حذف الطلبات من Supabase
      await _client.from('orders').delete().eq('vendor_id', vendorId);

      // تحديث القوائم المحلية
      orderController.orders.clear();

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting orders: $e');
    }
  }

  // حذف الروابط الاجتماعية
  Future<void> _deleteSocialLinks(String vendorId) async {
    currentStep.value = 'حذف الروابط الاجتماعية...';

    try {
      // حذف الروابط الاجتماعية من Supabase
      // ملاحظة: الروابط الاجتماعية قد تكون جزء من جدول vendors
      // أو جدول منفصل حسب التصميم
      await _client
          .from('vendors')
          .update({
            'website': '',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', vendorId);

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting social links: $e');
    }
  }

  // profileController.instance.socialLink.clear();
  // profileController.instance.socialLinkAr.clear();
  // profileController.instance.socialLinkUrl.clear();
  // profileController.instance.organizationName.clear();
  // profileController.instance.organizationBio.clear();
  // profileController.instance.organizationLogo.clear();
  // profileController.instance.organizationCover.clear();
  // profileController.instance.brief = '';

  // حذف الملف الشخصي
  Future<void> _deleteProfile(String vendorId) async {
    currentStep.value = 'حذف الملف الشخصي...';

    try {
      // حذف بيانات المتجر من Supabase
      await _client.from('vendors').delete().eq('user_id', vendorId);

      // تصفير حقول المتجر في ملف المستخدم
      await _clearOrganizationFields(vendorId);

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error deleting profile: $e');
    }
  }

  // تصفير حقول المتجر في ملف المستخدم
  Future<void> _clearOrganizationFields(String vendorId) async {
    try {
      await _client
          .from('users')
          .update({
            'organization_name': '',
            'organization_bio': '',
            'organization_logo': '',
            'organization_cover': '',
            'is_organization': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);
    } catch (e) {
      debugPrint('Error clearing organization fields: $e');
    }
  }

  // تحديث حالة المتجر
  Future<void> _updateStoreStatus(String vendorId) async {
    try {
      // تحديث حالة المتجر في Supabase
      await _client
          .from('users')
          .update({
            'organization_deleted': true,
            'organization_activated': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      // تحديث VendorController
      profileController.organizationDeleted.value = true;
      profileController.organizationActivated.value = false;
    } catch (e) {
      debugPrint('Error updating store status: $e');
    }
  }

  // الحصول على رسالة النجاح
  String get successMessage {
    return 'تم حذف المتجر بنجاح';
  }

  // الحصول على رسالة الخطأ
  String get errorMessageText {
    return errorMessage.value.isNotEmpty
        ? errorMessage.value
        : 'حدث خطأ أثناء حذف المتجر';
  }

  // عرض رسالة النجاح
  void showSuccessMessage() {
    Get.snackbar(
      'نجح',
      successMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // عرض رسالة الخطأ
  void showErrorMessage() {
    Get.snackbar(
      'خطأ',
      errorMessageText,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
