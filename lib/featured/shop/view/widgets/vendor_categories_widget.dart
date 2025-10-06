import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/controllers/vendor_categories_controller.dart';
import 'package:istoreto/featured/shop/view/widgets/category_priority_management_page.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

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

    return Obx(() {
      // إذا كان في حالة تحميل أو لا توجد فئات
      if (controller.isLoading.value || !controller.hasCategories) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض الفئات مع حالة التحميل أو عدم وجود فئات
            SizedBox(
              height: _getCategoriesContainerHeight(),
              child:
                  controller.isLoading.value
                      ? _buildLoadingState()
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }

      // إذا وجدت فئات، اعرض القسم كاملاً
      debugPrint(
        '📌 Showing categories section with ${controller.categoriesCount} categories',
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم مع زر إدارة الترتيب
          _buildSectionHeaderWithManageButton(controller.categories),

          // عرض الفئات
          Container(
            height: _getCategoriesContainerHeight(),
            child: _buildCategoriesList(controller.categories),
          ),

          const SizedBox(height: 16),
        ],
      );
    });
  }

  /// الحصول على ارتفاع الحاوية المتجاوب
  double _getCategoriesContainerHeight() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      // هواتف صغيرة
      return 100;
    } else if (screenWidth < 900) {
      // هواتف كبيرة أو تابلت صغير
      return 120;
    } else {
      // تابلت أو شاشات كبيرة
      return 140;
    }
  }

  /// الحصول على حجم الفئة المتجاوب
  double _getCategorySize() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      // هواتف صغيرة
      return 70;
    } else if (screenWidth < 900) {
      // هواتف كبيرة أو تابلت صغير
      return 80;
    } else {
      // تابلت أو شاشات كبيرة
      return 90;
    }
  }

  /// الحصول على المسافة بين العناصر المتجاوبة
  double _getItemSpacing() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      return 12.0;
    } else if (screenWidth < 900) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// الحصول على الحشو المتجاوب
  EdgeInsets _getPadding() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (screenWidth < 900) {
      return const EdgeInsets.symmetric(horizontal: 20.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    }
  }

  /// حالة التحميل مع تأثير الشيمر
  Widget _buildLoadingState() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: _getPadding(),
      itemCount: _getShimmerItemCount(),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: _getItemSpacing()),
          child: _buildCategoryShimmer(),
        );
      },
    );
  }

  /// عنصر شيمر للفئة
  Widget _buildCategoryShimmer() {
    final categorySize = _getCategorySize();
    return TShimmerEffect(
      width: categorySize,
      height: categorySize,
      raduis: BorderRadius.circular(categorySize / 2), // دائري مثل الفئات
    );
  }

  /// الحصول على عدد عناصر الشيمر المتجاوب
  int _getShimmerItemCount() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      return 6; // هواتف صغيرة
    } else if (screenWidth < 900) {
      return 8; // هواتف كبيرة أو تابلت صغير
    } else {
      return 10; // تابلت أو شاشات كبيرة
    }
  }

  /// عنوان القسم مع زر إدارة الترتيب
  Widget _buildSectionHeaderWithManageButton(List<dynamic> categories) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getPadding().left),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان القسم
          Text(
            'categories'.tr,
            style: TextStyle(
              fontSize: _getTitleFontSize(),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // زر إدارة الترتيب (يظهر فقط إذا كان هناك أكثر من فئتين)
          if (categories.length > 2) ...[
            TextButton.icon(
              onPressed: () => _openPriorityManagement(categories),
              icon: Icon(Icons.sort, size: 16, color: TColors.primary),
              label: Text(
                'manage_order'.tr,
                style: TextStyle(
                  color: TColors.primary,
                  fontSize: _getButtonFontSize(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// قائمة الفئات
  Widget _buildCategoriesList(List<dynamic> categories) {
    final productController = ProductController.instance;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: _getPadding(),
      itemCount: categories.length + (editMode ? 1 : 0),
      itemBuilder: (context, index) {
        // زر إضافة فئة جديدة في وضع التحرير
        if (editMode && index == categories.length) {
          return Padding(
            padding: EdgeInsets.only(right: _getItemSpacing()),
            child: _buildAddCategoryButton(index),
          );
        }

        try {
          final category = categories[index];

          if (category.id?.isEmpty ?? true) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.only(right: _getItemSpacing()),
            child: GestureDetector(
              onTap: () => _onCategoryTap(category),
              child: Obx(
                () => TCategoryGridItem(
                  category: category,
                  editMode: editMode,
                  selected:
                      productController.selectedCategory.value == category,
                ),
              ),
            ),
          );
        } catch (e) {
          debugPrint('Error building category item at index $index: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// زر إضافة فئة جديدة
  Widget _buildAddCategoryButton(int index) {
    final categorySize = _getCategorySize();
    return Stack(
      alignment: Alignment.center,
      children: [
        InkWell(
          onTap: _navigateToCreateCategory,
          child: TRoundedContainer(
            showBorder: false,
            width: categorySize,
            height: categorySize,
            radius: BorderRadius.circular(categorySize),
            enableShadow: true,
            child: Center(
              child: Icon(
                CupertinoIcons.add,
                color: TColors.primary,
                size: _getAddIconSize(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// الحصول على حجم أيقونة الإضافة المتجاوب
  double _getAddIconSize() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      return 24.0;
    } else if (screenWidth < 900) {
      return 28.0;
    } else {
      return 32.0;
    }
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

  /// الحصول على حجم خط العنوان المتجاوب
  double _getTitleFontSize() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      return 16.sp;
    } else if (screenWidth < 900) {
      return 18.sp;
    } else {
      return 20.sp;
    }
  }

  /// الحصول على حجم خط الزر المتجاوب
  double _getButtonFontSize() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 600) {
      return 12.sp;
    } else if (screenWidth < 900) {
      return 14.sp;
    } else {
      return 16.sp;
    }
  }
}
