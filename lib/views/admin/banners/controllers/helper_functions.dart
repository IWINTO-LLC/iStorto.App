import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';

void showAddBannerDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'add_new_banner'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Gallery Option (First)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: Text(
                  'from_gallery'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('choose_from_gallery'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  Get.back();
                  try {
                    await BannerController.instance.addCompanyBanner('gallery');
                  } catch (e) {
                    Get.snackbar(
                      'error'.tr,
                      'Failed to add banner: ${e.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.red.shade800,
                    );
                  }
                },
              ),

              const SizedBox(height: 8),

              // Camera Option (Second)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.green),
                ),
                title: Text(
                  'from_camera'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('take_new_photo'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  Get.back();
                  try {
                    await BannerController.instance.addCompanyBanner('camera');
                  } catch (e) {
                    Get.snackbar(
                      'error'.tr,
                      'Failed to add banner: ${e.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.red.shade800,
                    );
                  }
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
  );
}

void showEditBannerDialog(BuildContext context, BannerModel banner) {
  final titleController = TextEditingController(text: banner.title ?? '');
  final descriptionController = TextEditingController(
    text: banner.description ?? '',
  );
  final targetScreenController = TextEditingController(
    text: banner.targetScreen,
  );
  final priorityController = TextEditingController(
    text: banner.priority?.toString() ?? '0',
  );
  bool isActive = banner.active;
  BannerScope scope = banner.scope;

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text('edit_banner'.tr),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'title'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'description'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Target Screen
                      TextFormField(
                        controller: targetScreenController,
                        decoration: InputDecoration(
                          labelText: 'target_screen'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority
                      TextFormField(
                        controller: priorityController,
                        decoration: InputDecoration(
                          labelText: 'priority'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Active Status
                      SwitchListTile(
                        title: Text('active'.tr),
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                      ),

                      // Scope (only for vendor banners)
                      if (banner.scope == BannerScope.vendor)
                        SwitchListTile(
                          title: Text('convert_to_company'.tr),
                          subtitle: Text('convert_to_company_description'.tr),
                          value: scope == BannerScope.company,
                          onChanged:
                              (value) => setState(
                                () =>
                                    scope =
                                        value
                                            ? BannerScope.company
                                            : BannerScope.vendor,
                              ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await updateBanner(
                        context,
                        banner,
                        titleController.text.trim(),
                        descriptionController.text.trim(),
                        targetScreenController.text.trim(),
                        int.tryParse(priorityController.text) ?? 0,
                        isActive,
                        scope,
                      );
                      Get.back();
                    },
                    child: Text('save'.tr),
                  ),
                ],
              ),
        ),
  );
}

Future<void> updateBanner(
  BuildContext context,
  BannerModel banner,
  String title,
  String description,
  String targetScreen,
  int priority,
  bool isActive,
  BannerScope scope,
) async {
  final bannerId = banner.id;
  if (bannerId == null || bannerId.isEmpty) {
    Get.snackbar(
      'error'.tr,
      'Invalid banner ID',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    return;
  }

  try {
    final BannerController controller = Get.find<BannerController>();
    await controller.updateBanner(
      bannerId,
      title: title,
      description: description,
      targetScreen: targetScreen,
      priority: priority,
      active: isActive,
      scope: scope,
    );

    Get.snackbar(
      'success'.tr,
      'banner_updated_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  } catch (e) {
    Get.snackbar(
      'error'.tr,
      'failed_to_update_banner'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
}

Future<void> toggleBannerStatus(
  BuildContext context,
  BannerModel banner,
) async {
  final bannerId = banner.id;
  if (bannerId == null || bannerId.isEmpty) {
    Get.snackbar(
      'error'.tr,
      'Invalid banner ID',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    return;
  }

  final newStatus = !banner.active;

  try {
    final BannerController controller = Get.find<BannerController>();
    await controller.toggleBannerActive(bannerId, newStatus);

    Get.snackbar(
      'success'.tr,
      newStatus
          ? 'banner_activated_successfully'.tr
          : 'banner_deactivated_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  } catch (e) {
    Get.snackbar(
      'error'.tr,
      'failed_to_update_banner'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
}

Future<void> convertToCompanyBanner(
  BuildContext context,
  BannerModel banner,
) async {
  final bannerId = banner.id;
  if (bannerId == null || bannerId.isEmpty) {
    Get.snackbar(
      'error'.tr,
      'Invalid banner ID',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    return;
  }

  // Show confirmation dialog
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text('confirm_conversion'.tr),
      content: Text('convert_to_company_banner_message'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text('convert'.tr),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final BannerController controller = Get.find<BannerController>();
    await controller.convertToCompanyBanner(banner);

    Get.snackbar(
      'success'.tr,
      'banner_converted_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  } catch (e) {
    Get.snackbar(
      'error'.tr,
      'failed_to_convert_banner'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
}

Future<void> deleteBanner(BuildContext context, BannerModel banner) async {
  final bannerId = banner.id;
  if (bannerId == null || bannerId.isEmpty) {
    Get.snackbar(
      'error'.tr,
      'Invalid banner ID',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    return;
  }

  // Show confirmation dialog
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text('confirm_deletion'.tr),
      content: Text('delete_banner_message'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('delete'.tr),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final BannerController controller = Get.find<BannerController>();
    await controller.deleteBannerAdmin(banner);

    Get.snackbar(
      'success'.tr,
      'banner_deleted_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  } catch (e) {
    Get.snackbar(
      'error'.tr,
      'failed_to_delete_banner'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
}
