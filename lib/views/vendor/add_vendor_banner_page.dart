import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/add_vendor_banner_controller.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';

class AddVendorBannerPage extends StatelessWidget {
  final String vendorId;

  const AddVendorBannerPage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddVendorBannerController(vendorId: vendorId));

    return Scaffold(
      appBar: CustomAppBar(title: 'vendor_add_new_banner'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معاينة الصورة
              Center(
                child: GestureDetector(
                  onTap: () => controller.showImageSourceDialog(),
                  child: Obx(
                    () => Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child:
                          controller.selectedImage.value != null
                              ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(
                                        controller.selectedImage.value!.path,
                                      ),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => controller.removeImage(),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate,
                                    size: 60,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'vendor_select_banner_image'.tr,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aspect Ratio: 0.5882:1',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // عنوان البانر
              TextFormField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'vendor_banner_title'.tr,
                  hintText: 'vendor_enter_banner_title'.tr,
                  prefixIcon: const Icon(Icons.title, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter banner title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // وصف البانر (اختياري)
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '${'Description'.tr} (${'optional'.tr})',
                  hintText: 'Enter banner description',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // رابط البانر (اختياري)
              TextFormField(
                controller: controller.linkController,
                decoration: InputDecoration(
                  labelText: '${'vendor_banner_link'.tr} (${'optional'.tr})',
                  hintText: 'vendor_enter_banner_link'.tr,
                  prefixIcon: const Icon(Icons.link, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // الأولوية
              TextFormField(
                controller: controller.priorityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  hintText: 'Enter priority (0-100)',
                  prefixIcon: const Icon(Icons.sort, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.updatePriority(value),
              ),
              const SizedBox(height: 16),

              // حالة النشاط
              Obx(
                () => SwitchListTile(
                  title: const Text('Active Banner'),
                  subtitle: Text(
                    controller.isActive.value
                        ? 'Banner will be visible immediately'
                        : 'Banner will be hidden',
                  ),
                  value: controller.isActive.value,
                  onChanged: (value) => controller.toggleActive(value),
                  activeColor: TColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // شريط التقدم
              Obx(
                () =>
                    controller.isUploading.value
                        ? Column(
                          children: [
                            LinearProgressIndicator(
                              value: controller.uploadProgress.value,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                TColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(controller.uploadProgress.value * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                        : const SizedBox(),
              ),

              // أزرار الحفظ والإلغاء
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            controller.isUploading.value
                                ? null
                                : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            controller.isUploading.value
                                ? null
                                : () => controller.saveBanner(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            controller.isUploading.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text('add'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
