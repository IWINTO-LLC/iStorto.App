import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/image_edit_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_image_controller.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/views/initial_commercial_page.dart';
import 'package:istoreto/views/admin/admin_zone_page.dart';
import 'package:istoreto/views/settings_page.dart';
import 'package:istoreto/views/edit_personal_info_page.dart';
import 'package:istoreto/featured/product/views/saved_products_list.dart';

/// مكون قائمة الملف الشخصي - يعرض خيارات الإعدادات والإجراءات
class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person,
            title: 'personal_information'.tr,
            subtitle: 'update_personal_details'.tr,
            onTap: () => _showEditProfileDialog(Get.context!),
          ),
          _buildMenuItem(
            icon: Icons.bookmark,
            title: 'saved_products'.tr,
            subtitle: 'view_your_saved_products'.tr,
            onTap: () => Get.to(() => SavedProductsPage()),
          ),
          _buildMenuItem(
            icon: Icons.business,
            title: 'business_account'.tr,
            subtitle:
                authController.currentUser.value?.accountType == 1
                    ? 'manage_your_business'.tr
                    : 'create_commercial_account'.tr,
            onTap: () => _handleBusinessAccount(authController),
          ),
          _buildMenuItem(
            icon: Icons.admin_panel_settings,
            title: 'admin_zone_title'.tr,
            subtitle: 'manage_categories_and_content'.tr,
            onTap: () => Get.to(() => const AdminZonePage()),
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'settings'.tr,
            subtitle: 'app_preferences_and_configuration'.tr,
            onTap: () => _showSettingsDialog(Get.context!),
          ),

          _buildMenuItem(
            icon: Icons.help,
            title: 'help_and_support'.tr,
            subtitle: 'get_help_and_contact_support'.tr,
            onTap: () => _showHelpDialog(Get.context!),
          ),

          SizedBox(height: 20),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'logout'.tr,
            subtitle: 'sign_out_of_your_account'.tr,
            onTap: () => _showLogoutDialog(Get.context!, authController),
            isDestructive: true,
          ),

          // مساحة إضافية في الأسفل للتمرير الأفضل
          SizedBox(height: 100),
        ],
      ),
    );
  }

  /// بناء عنصر القائمة
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  /// التعامل مع حساب الأعمال
  void _handleBusinessAccount(AuthController authController) {
    if (authController.currentUser.value?.accountType == 1) {
      Get.to(
        () => MarketPlaceView(
          editMode: true,
          vendorId: authController.currentUser.value!.vendorId!,
        ),
      );
    } else {
      Get.to(() => const InitialCommercialPage());
    }
  }

  /// عرض نافذة تعديل الملف الشخصي
  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شريط التحكم
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                // العنوان
                Text(
                  'edit_profile'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 20),

                // خيارات التعديل
                _buildEditOption(
                  icon: Icons.photo_camera,
                  title: 'edit_cover_photo'.tr,
                  subtitle: 'change_your_cover_image'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _editCoverPhoto();
                  },
                ),
                _buildEditOption(
                  icon: Icons.person,
                  title: 'edit_profile_photo'.tr,
                  subtitle: 'change_your_profile_picture'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _editProfilePhoto();
                  },
                ),
                _buildEditOption(
                  icon: Icons.info,
                  title: 'edit_personal_info'.tr,
                  subtitle: 'update_your_personal_details'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _editPersonalInfo();
                  },
                ),
                _buildEditOption(
                  icon: Icons.description,
                  title: 'edit_bio'.tr,
                  subtitle: 'update_your_biography'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _editBio();
                  },
                ),
                _buildEditOption(
                  icon: Icons.short_text,
                  title: 'edit_brief'.tr,
                  subtitle: 'update_your_brief_description'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _editBrief();
                  },
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بناء خيار التعديل
  Widget _buildEditOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  /// عرض نافذة الإعدادات
  void _showSettingsDialog(BuildContext context) {
    Get.to(() => SettingsPage());
  }

  /// عرض نافذة المساعدة
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('help_and_support'.tr),
          content: Text('help_and_support_coming_soon'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ok'.tr),
            ),
          ],
        );
      },
    );
  }

  /// عرض نافذة تسجيل الخروج
  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'logout'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// تعديل صورة الغلاف
  void _editCoverPhoto() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    // التحقق من أن المستخدم بائع
    if (user?.accountType != 1 || user?.vendorId == null) {
      Get.snackbar(
        'error'.tr,
        'feature_for_business_accounts_only'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    // تهيئة VendorImageController
    if (!Get.isRegistered<VendorImageController>()) {
      Get.put(VendorImageController());
    }

    // فتح محرر صورة الغلاف
    VendorImageController.instance.editVendorCoverImage(user!.vendorId!);
  }

  /// تعديل الصورة الشخصية
  void _editProfilePhoto() {
    // تهيئة ImageEditController
    if (!Get.isRegistered<ImageEditController>()) {
      Get.put(ImageEditController());
    }

    final imageController = ImageEditController.instance;

    // عرض نافذة اختيار مصدر الصورة
    imageController.showImageSourceDialog(
      title: 'edit_profile_photo'.tr,
      onCamera: () => imageController.pickFromCamera(isProfile: true),
      onGallery: () => imageController.pickFromGallery(isProfile: true),
    );
  }

  /// تعديل المعلومات الشخصية
  void _editPersonalInfo() {
    Get.to(() => EditPersonalInfoPage());
  }

  /// تعديل السيرة الذاتية
  void _editBio() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    // التحقق من أن المستخدم بائع
    if (user?.accountType != 1 || user?.vendorId == null) {
      Get.snackbar(
        'error'.tr,
        'feature_for_business_accounts_only'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    // الحصول على VendorController
    if (!Get.isRegistered<VendorController>()) {
      Get.put(VendorController());
    }

    final vendorController = VendorController.instance;
    final currentBio = vendorController.vendorData.value.organizationBio;
    final bioController = TextEditingController(text: currentBio);

    // عرض نافذة التعديل
    Get.dialog(
      AlertDialog(
        title: Text('edit_bio'.tr),
        content: TextField(
          controller: bioController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'enter_store_bio'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              final newBio = bioController.text.trim();
              if (newBio.isNotEmpty) {
                try {
                  // تحديث قاعدة البيانات
                  await vendorController.repository.updateField(
                    vendorId: user!.vendorId!,
                    fieldName: 'organization_bio',
                    newValue: newBio,
                  );

                  // تحديث البيانات المحلية
                  await vendorController.fetchVendorData(user.vendorId!);

                  Get.back();
                  Get.snackbar(
                    'success'.tr,
                    'bio_updated_successfully'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade800,
                  );
                } catch (e) {
                  Get.snackbar(
                    'error'.tr,
                    '${'update_failed'.tr}: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade800,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  /// تعديل الوصف المختصر
  void _editBrief() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    // التحقق من أن المستخدم بائع
    if (user?.accountType != 1 || user?.vendorId == null) {
      Get.snackbar(
        'error'.tr,
        'feature_for_business_accounts_only'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    // الحصول على VendorController
    if (!Get.isRegistered<VendorController>()) {
      Get.put(VendorController());
    }

    final vendorController = VendorController.instance;
    final currentBrief = vendorController.vendorData.value.brief;
    final briefController = TextEditingController(text: currentBrief);

    // عرض نافذة التعديل
    Get.dialog(
      AlertDialog(
        title: Text('edit_brief'.tr),
        content: TextField(
          controller: briefController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'enter_brief_description'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            helperText: 'brief_helper_text'.tr,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              final newBrief = briefController.text.trim();
              if (newBrief.isNotEmpty) {
                try {
                  // تحديث قاعدة البيانات
                  await vendorController.repository.updateField(
                    vendorId: user!.vendorId!,
                    fieldName: 'brief',
                    newValue: newBrief,
                  );

                  // تحديث البيانات المحلية
                  await vendorController.fetchVendorData(user.vendorId!);

                  Get.back();
                  Get.snackbar(
                    'success'.tr,
                    'brief_updated_successfully'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade800,
                  );
                } catch (e) {
                  Get.snackbar(
                    'error'.tr,
                    '${'update_failed'.tr}: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade800,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}
