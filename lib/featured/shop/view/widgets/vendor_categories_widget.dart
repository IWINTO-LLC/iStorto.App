import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/controllers/vendor_categories_controller.dart';
import 'package:istoreto/featured/shop/view/widgets/category_priority_management_page.dart';
import 'package:istoreto/views/vendor/vendor_categories_management_page.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/catrgory_shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorCategoriesWidget extends StatelessWidget {
  final bool editMode;
  final String vendorId;

  const VendorCategoriesWidget({
    super.key,
    required this.editMode,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    // تهيئة الـ controller
    final controller = Get.put(VendorCategoriesController());

    // تحميل الفئات عند البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVendorCategories(vendorId);
    });

    return Stack(
      children: [
        Column(
          children: [
            // عنوان القسم مع زر إدارة الترتيب
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'categories'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // زر إدارة الترتيب (يظهر فقط إذا كان هناك أكثر من فئتين وفي وضع التحرير)
                  if (editMode)
                    TextButton.icon(
                      onPressed:
                          () => _openPriorityManagement(controller.categories),
                      icon: Icon(Icons.sort, size: 16, color: TColors.primary),
                      label: Text(
                        'manage_order'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const TCategoryShummer(itemCount: 8);
              }

              // عرض فئات التاجر
              final categories = controller.categories.take(8).toList();

              if (categories.isEmpty) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'no_items_yet'.tr,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 140, // ارتفاع ثابت مثل major_category_section
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + (editMode ? 1 : 0),
                  itemBuilder: (context, index) {
                    // زر إضافة فئة جديدة في وضع التحرير
                    if (editMode && index == categories.length) {
                      return _buildAddCategoryButton();
                    }

                    final category = categories[index];
                    return _buildCategoryItem(category, context);
                  },
                ),
              );
            }),
            const SizedBox(height: 20), // مساحة للزر العائم
          ],
        ),
        // زر عائم لإدارة الفئات
        if (editMode)
          Positioned(
            bottom: 15,
            right: TranslationController.instance.isRTL ? null : 7,
            left: TranslationController.instance.isRTL ? 7 : null,
            child: CustomFloatActionButton(
              onTap: () => _showCategoryManagementOptions(context),
              icon: Icons.settings,
            ),
          ),
      ],
    );
  }

  /// عنصر الفئة الجديد مثل major_category_section
  Widget _buildCategoryItem(dynamic category, BuildContext context) {
    // Add null safety checks
    if (category.title?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 110, // نفس العرض مثل major_category_section
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _onCategoryTap(category),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  _getCategoryImage(category) != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          _getCategoryImage(category)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCategoryIcon(category);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildCategoryIcon(category);
                          },
                        ),
                      )
                      : _buildCategoryIcon(category),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            category.title ?? '',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // عرض حالة الفئة إذا لم تكن نشطة
          if (!category.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'inactive'.tr,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// أيقونة الفئة
  Widget _buildCategoryIcon(dynamic category) {
    return TRoundedContainer(
      radius: BorderRadius.circular(25),
      enableShadow: true,
      showBorder: true,
      borderWidth: 3,
      child:
          _getCategoryImage(category) != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  _getCategoryImage(category)!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.category);
                  },
                ),
              )
              : Icon(Icons.category),
    );
  }

  /// يحاول قراءة رابط الصورة من أي موديل محتمل (image أو icon)
  String? _getCategoryImage(dynamic category) {
    try {
      final dynamic candidate = (category as dynamic).image;
      if (candidate is String && candidate.isNotEmpty) return candidate;
    } catch (_) {}
    try {
      final dynamic candidate = (category as dynamic).icon;
      if (candidate is String && candidate.isNotEmpty) return candidate;
    } catch (_) {}
    return null;
  }

  /// زر إضافة فئة جديدة
  Widget _buildAddCategoryButton() {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: _navigateToCreateCategory,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  color: TColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'add_category'.tr,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// التنقل إلى صفحة إنشاء فئة
  void _navigateToCreateCategory() {
    var controller = Get.put(CreateCategoryController());
    controller.deleteTempItems();
    Get.toNamed('/create-category', arguments: {'vendorId': vendorId});
  }

  /// عند النقر على فئة
  void _onCategoryTap(dynamic category) {
    final productController = ProductController.instance;
    productController.selectCategory(category, vendorId);
  }

  /// فتح صفحة إدارة الأولويات
  void _openPriorityManagement(List<dynamic> categories) {
    final controller = Get.find<VendorCategoriesController>();

    Get.to(
      () => CategoryPriorityManagementPage(
        categories: categories,
        vendorId: vendorId,
      ),
    )?.then((_) {
      // إعادة تحميل الفئات بعد العودة من صفحة إدارة الأولويات
      controller.refreshAfterPriorityChange();
    });
  }

  /// عرض خيارات إدارة الفئات
  void _showCategoryManagementOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'manage_categories'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Add new category
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.black),
                  ),
                  title: Text('add_new_category'.tr),
                  subtitle: Text('create_new_vendor_category'.tr),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateCategory();
                  },
                ),
                // Manage category order
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sort, color: Colors.black),
                  ),
                  title: Text('manage_order'.tr),
                  subtitle: Text('reorder_categories_by_priority'.tr),
                  onTap: () {
                    Navigator.pop(context);
                    final controller = Get.find<VendorCategoriesController>();
                    _openPriorityManagement(controller.categories);
                  },
                ),
                // View all categories
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.list, color: Colors.black),
                  ),
                  title: Text('view_all_categories'.tr),
                  subtitle: Text('see_all_vendor_categories'.tr),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(
                      () => VendorCategoriesManagementPage(vendorId: vendorId),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
