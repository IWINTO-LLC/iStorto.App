import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controllers/category_priority_controller.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class CategoryPriorityManagementPage extends StatelessWidget {
  final List<dynamic> categories;
  final String vendorId;

  const CategoryPriorityManagementPage({
    super.key,
    required this.categories,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(CategoryPriorityController());
    controller.initialize(categories, vendorId);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'manage_category_priority'.tr,
        centerTitle: true,
        fontSize: 18.sp,
        iconColor: Colors.black,
        isBackButtonExist: true,
      ),
      body: Column(
        children: [
          // تعليمات الاستخدام
          _buildInstructions(),

          // قائمة الفئات القابلة للسحب
          Expanded(child: _buildDraggableList(controller)),

          // أزرار التحكم
          _buildControlButtons(controller),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  /// تعليمات الاستخدام
  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.black.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.drag_indicator, size: 24.sp),
          const SizedBox(height: 8),
          Text(
            'drag_drop_instructions'.tr,
            style: titilliumRegular.copyWith(
              fontSize: 14.sp,

              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// قائمة الفئات القابلة للسحب
  Widget _buildDraggableList(CategoryPriorityController controller) {
    return Obx(
      () => ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        onReorder: controller.reorderCategories,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _buildDraggableCategoryItem(category, index);
        },
      ),
    );
  }

  /// عنصر الفئة القابل للسحب
  Widget _buildDraggableCategoryItem(dynamic category, int index) {
    return Container(
      key: ValueKey(category.id ?? index),
      margin: const EdgeInsets.only(bottom: 12),
      child: TRoundedContainer(
        showBorder: true,
        borderColor: Colors.grey.shade300,
        backgroundColor: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: _buildPriorityIndicator(index + 1),
          title: Text(
            category.title ?? 'Unknown Category',
            style: titilliumRegular.copyWith(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${'priority_level'.tr}: ${index + 1}',
            style: titilliumRegular.copyWith(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة السحب
              Icon(
                Icons.drag_indicator,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
              const SizedBox(width: 8),
              // أيقونة الفئة
              if (category.icon != null && category.icon.isNotEmpty)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(category.icon),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category,
                    color: TColors.primary,
                    size: 16.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// مؤشر الأولوية
  Widget _buildPriorityIndicator(int priority) {
    Color priorityColor = Colors.black;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: priorityColor, width: 2),
      ),
      child: Center(
        child: Text(
          priority.toString(),
          style: titilliumBold.copyWith(fontSize: 16.sp, color: priorityColor),
        ),
      ),
    );
  }

  /// أزرار التحكم
  Widget _buildControlButtons(CategoryPriorityController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الإلغاء
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'cancel'.tr,
                style: titilliumRegular.copyWith(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // زر الحفظ
          Expanded(
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : controller.savePriorityOrder,
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: TColors.primary,
                //   foregroundColor: Colors.white,
                //   padding: const EdgeInsets.symmetric(vertical: 12),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                // ),
                child: Text(
                  controller.isLoading.value ? 'saving'.tr : 'save_changes'.tr,
                  style: titilliumRegular.copyWith(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
