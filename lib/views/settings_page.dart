import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/image_edit_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/translations/translations.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/storage_management_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'settings.title'.tr, isBackButtonExist: true),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Settings Section
            _buildSection(
              title: 'settings.profile_settings'.tr,
              children: [
                _buildSettingsItem(
                  icon: Icons.person,
                  title: 'settings.personal_information'.tr,
                  subtitle: 'settings.personal_information_subtitle'.tr,
                  onTap: () => _showPersonalInfoDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.photo_camera,
                  title: 'settings.profile_photo'.tr,
                  subtitle: 'settings.profile_photo_subtitle'.tr,
                  onTap: () => _showProfilePhotoDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.photo_library,
                  title: 'settings.cover_photo'.tr,
                  subtitle: 'settings.cover_photo_subtitle'.tr,
                  onTap: () => _showCoverPhotoDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.description,
                  title: 'settings.bio_description'.tr,
                  subtitle: 'settings.bio_description_subtitle'.tr,
                  onTap: () => _showBioDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Account Settings Section
            _buildSection(
              title: 'settings.account_settings'.tr,
              children: [
                _buildSettingsItem(
                  icon: Icons.email,
                  title: 'settings.email_password'.tr,
                  subtitle: 'settings.email_password_subtitle'.tr,
                  onTap: () => _showEmailPasswordDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.phone,
                  title: 'settings.phone_number'.tr,
                  subtitle: 'settings.phone_number_subtitle'.tr,
                  onTap: () => _showPhoneDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.location_on,
                  title: 'settings.location'.tr,
                  subtitle: 'settings.location_subtitle'.tr,
                  onTap: () => _showLocationDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.business,
                  title: 'settings.business_account'.tr,
                  subtitle:
                      authController.currentUser.value?.accountType == 1
                          ? 'settings.business_account_subtitle_vendor'.tr
                          : 'settings.business_account_subtitle_user'.tr,
                  onTap: () => _showBusinessAccountDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Privacy & Security Section
            _buildSection(
              title: 'settings.privacy_security'.tr,
              children: [
                _buildSettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'settings.privacy_settings'.tr,
                  subtitle: 'settings.privacy_settings_subtitle'.tr,
                  onTap: () => _showPrivacyDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.security,
                  title: 'settings.security'.tr,
                  subtitle: 'settings.security_subtitle'.tr,
                  onTap: () => _showSecurityDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.notifications,
                  title: 'settings.notifications'.tr,
                  subtitle: 'settings.notifications_subtitle'.tr,
                  onTap: () => _showNotificationsDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.block,
                  title: 'settings.blocked_users'.tr,
                  subtitle: 'settings.blocked_users_subtitle'.tr,
                  onTap: () => _showBlockedUsersDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // App Settings Section
            _buildSection(
              title: 'settings.app_settings'.tr,
              children: [
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'settings.language'.tr,
                  subtitle: 'settings.language_subtitle'.tr,
                  onTap: () => _showLanguageDialog(),
                ),
                Obx(() {
                  final currencyController = Get.find<CurrencyController>();
                  final currentCurrency =
                      currencyController.userCurrency.value.isNotEmpty
                          ? currencyController.userCurrency.value
                          : 'USD';

                  return _buildSettingsItem(
                    icon: Icons.currency_exchange,
                    title: 'settings.currency'.tr,
                    subtitle: 'settings.currency_subtitle'.tr,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        currentCurrency,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    onTap: () => _showCurrencyDialog(),
                  );
                }),
                _buildSettingsItem(
                  icon: Icons.palette,
                  title: 'settings.theme'.tr,
                  subtitle: 'settings.theme_subtitle'.tr,
                  onTap: () => _showThemeDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.storage,
                  title: 'settings.storage'.tr,
                  subtitle: 'settings.storage_subtitle'.tr,
                  onTap: () => _showStorageDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.update,
                  title: 'settings.app_updates'.tr,
                  subtitle: 'settings.app_updates_subtitle'.tr,
                  onTap: () => _showUpdatesDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Support Section
            _buildSection(
              title: 'settings.support'.tr,
              children: [
                _buildSettingsItem(
                  icon: Icons.help,
                  title: 'settings.help_center'.tr,
                  subtitle: 'settings.help_center_subtitle'.tr,
                  onTap: () => _showHelpDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.feedback,
                  title: 'settings.send_feedback'.tr,
                  subtitle: 'settings.send_feedback_subtitle'.tr,
                  onTap: () => _showFeedbackDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.info,
                  title: 'settings.about'.tr,
                  subtitle: 'settings.about_subtitle'.tr,
                  onTap: () => _showAboutDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.contact_support,
                  title: 'settings.contact_us'.tr,
                  subtitle: 'settings.contact_us_subtitle'.tr,
                  onTap: () => _showContactDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Danger Zone
            _buildSection(
              title: 'settings.danger_zone'.tr,
              children: [
                _buildSettingsItem(
                  icon: Icons.delete_forever,
                  title: 'settings.delete_account'.tr,
                  subtitle: 'settings.delete_account_subtitle'.tr,
                  onTap: () => _showDeleteAccountDialog(),
                  isDestructive: true,
                ),
                _buildSettingsItem(
                  icon: Icons.logout,
                  title: 'settings.sign_out'.tr,
                  subtitle: 'settings.sign_out_subtitle'.tr,
                  onTap: () => _showSignOutDialog(authController),
                  isDestructive: true,
                ),
              ],
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        ...children,
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
                    : Colors.black.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.black, // جميع الأيقونات سوداء
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
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
        onTap: onTap,
      ),
    );
  }

  // Dialog Methods
  void _showPersonalInfoDialog() {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;

    if (currentUser == null) {
      Get.snackbar(
        'error'.tr,
        'settings.user_not_found'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    // Initialize text controllers with current values
    final nameController = TextEditingController(text: currentUser.name);
    final usernameController = TextEditingController(
      text: currentUser.username ?? '',
    );
    final phoneController = TextEditingController(
      text: currentUser.phoneNumber ?? '',
    );

    final formKey = GlobalKey<FormState>();
    final RxBool isSaving = false.obs;

    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person, color: Colors.blue),
              SizedBox(width: 10),
              Text('settings.personal_information'.tr),
            ],
          ),
          content: Obx(
            () => SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'settings.name'.tr,
                        hintText: 'settings.enter_your_name'.tr,
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'settings.name_required'.tr;
                        }
                        if (value.trim().length < 2) {
                          return 'settings.name_too_short'.tr;
                        }
                        return null;
                      },
                      enabled: !isSaving.value,
                    ),
                    SizedBox(height: 16),

                    // Username Field
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'settings.username'.tr,
                        hintText: 'settings.enter_username'.tr,
                        prefixIcon: Icon(Icons.alternate_email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 3) {
                          return 'settings.username_too_short'.tr;
                        }
                        return null;
                      },
                      enabled: !isSaving.value,
                    ),
                    SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'settings.phone'.tr,
                        hintText: 'settings.enter_phone'.tr,
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !GetUtils.isPhoneNumber(value)) {
                          return 'settings.phone_invalid'.tr;
                        }
                        return null;
                      },
                      enabled: !isSaving.value,
                    ),
                    SizedBox(height: 16),

                    // Email Field (Read-only)
                    TextFormField(
                      initialValue: currentUser.email ?? '',
                      decoration: InputDecoration(
                        labelText: 'settings.email'.tr,
                        prefixIcon: Icon(Icons.email_outlined),
                        suffixIcon: Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      enabled: false,
                    ),
                    SizedBox(height: 8),

                    // Email note
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'settings.email_cannot_be_changed'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Loading indicator
                    if (isSaving.value) ...[
                      SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              'settings.saving_changes'.tr,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!isSaving.value) {
                  Navigator.of(context).pop();
                  nameController.dispose();
                  usernameController.dispose();
                  phoneController.dispose();
                }
              },
              child: Text('settings.cancel'.tr),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    isSaving.value
                        ? null
                        : () async {
                          if (formKey.currentState!.validate()) {
                            isSaving.value = true;

                            try {
                              // Prepare updates
                              final updates = <String, dynamic>{};
                              if (nameController.text.trim() !=
                                  currentUser.name) {
                                updates['name'] = nameController.text.trim();
                              }
                              if (usernameController.text.trim() !=
                                      (currentUser.username ?? '') &&
                                  usernameController.text.trim().isNotEmpty) {
                                updates['username'] =
                                    usernameController.text.trim();
                              }
                              if (phoneController.text.trim() !=
                                      (currentUser.phoneNumber ?? '') &&
                                  phoneController.text.trim().isNotEmpty) {
                                updates['phone_number'] =
                                    phoneController.text.trim();
                              }

                              if (updates.isEmpty) {
                                Get.snackbar(
                                  'settings.no_changes'.tr,
                                  'settings.no_changes_message'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange.shade100,
                                  colorText: Colors.orange.shade800,
                                  duration: Duration(seconds: 2),
                                );
                                isSaving.value = false;
                                return;
                              }

                              // Update in database
                              await authController.updateProfile(
                                name: updates['name'],
                                username: updates['username'],
                                phoneNumber: updates['phone_number'],
                              );

                              Get.snackbar(
                                'success'.tr,
                                'settings.personal_info_updated'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade800,
                                duration: Duration(seconds: 2),
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              );

                              Navigator.of(context).pop();
                              nameController.dispose();
                              usernameController.dispose();
                              phoneController.dispose();
                            } catch (e) {
                              print('Error updating personal info: $e');
                              Get.snackbar(
                                'error'.tr,
                                'settings.update_failed'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade800,
                                duration: Duration(seconds: 3),
                              );
                            } finally {
                              isSaving.value = false;
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  'settings.save_changes'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProfilePhotoDialog() {
    final imageController = Get.put(ImageEditController());
    imageController.showImageSourceDialog(
      title: 'settings.select_profile_photo_source'.tr,
      onCamera: () async {
        await imageController.pickFromCamera(isProfile: true);
        if (imageController.profileImage != null) {
          await imageController.saveProfileImageToDatabase(
            imageController.profileImage!,
          );
        }
      },
      onGallery: () async {
        await imageController.pickFromGallery(isProfile: true);
        if (imageController.profileImage != null) {
          await imageController.saveProfileImageToDatabase(
            imageController.profileImage!,
          );
        }
      },
    );
  }

  void _showCoverPhotoDialog() {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;

    // Check if user is a vendor (business account)
    if (currentUser?.accountType != 1) {
      Get.snackbar(
        'settings.business_account_required'.tr,
        'settings.cover_photo_vendor_only'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.info, color: Colors.orange),
      );
      return;
    }

    final imageController = Get.put(ImageEditController());
    imageController.showImageSourceDialog(
      title: 'settings.select_cover_photo_source'.tr,
      onCamera: () async {
        await imageController.pickFromCamera(isProfile: false);
        if (imageController.coverImage != null) {
          await imageController.saveCoverImageToDatabase(
            imageController.coverImage!,
          );
        }
      },
      onGallery: () async {
        await imageController.pickFromGallery(isProfile: false);
        if (imageController.coverImage != null) {
          await imageController.saveCoverImageToDatabase(
            imageController.coverImage!,
          );
        }
      },
    );
  }

  void _showBioDialog() {
    _showComingSoonDialog('Bio & Description');
  }

  void _showEmailPasswordDialog() {
    _showComingSoonDialog('Email & Password');
  }

  void _showPhoneDialog() {
    _showComingSoonDialog('Phone Number');
  }

  void _showLocationDialog() {
    _showComingSoonDialog('Location');
  }

  void _showBusinessAccountDialog() {
    _showComingSoonDialog('Business Account');
  }

  void _showPrivacyDialog() {
    _showComingSoonDialog('Privacy Settings');
  }

  void _showSecurityDialog() {
    _showComingSoonDialog('Security');
  }

  void _showNotificationsDialog() {
    _showComingSoonDialog('Notifications');
  }

  void _showBlockedUsersDialog() {
    _showComingSoonDialog('Blocked Users');
  }

  void _showLanguageDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings.select_language'.tr),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppLanguages.languages.length,
              itemBuilder: (context, index) {
                final language = AppLanguages.languages[index];
                final languageCode = language['code']!;
                final languageName = language['nativeName']!;
                final isSelected = Get.locale?.languageCode == languageCode;

                return ListTile(
                  leading: Icon(
                    Icons.language,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    languageName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                  onTap: () {
                    Get.updateLocale(Locale(languageCode));
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'settings.language'.tr,
                      'language_changed'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.green.shade800,
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.all(10),
                      borderRadius: 8,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('settings.cancel'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showCurrencyDialog() {
    final currencyController = Get.find<CurrencyController>();
    final authController = Get.find<AuthController>();
    final currentCurrency =
        currencyController.userCurrency.value.isNotEmpty
            ? currencyController.userCurrency.value
            : 'USD';

    final List<Map<String, String>> currencies = [
      {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'ر.س'},
      {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ'},
      {'code': 'EGP', 'name': 'Egyptian Pound', 'symbol': 'ج.م'},
      {'code': 'JOD', 'name': 'Jordanian Dinar', 'symbol': 'د.ا'},
      {'code': 'KWD', 'name': 'Kuwaiti Dinar', 'symbol': 'د.ك'},
      {'code': 'QAR', 'name': 'Qatari Riyal', 'symbol': 'ر.ق'},
    ];

    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
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
              Row(
                children: [
                  Icon(Icons.currency_exchange, color: Colors.black),
                  SizedBox(width: 12),
                  Text(
                    'settings.select_currency'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'settings.currency_description'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),

              // قائمة العملات
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        currencies.map((currency) {
                          final isSelected =
                              currentCurrency == currency['code'];

                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? TColors.primary.withOpacity(0.1)
                                      : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? TColors.primary
                                        : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? TColors.primary
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    currency['symbol']!,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                currency['name']!,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  color:
                                      isSelected
                                          ? TColors.primary
                                          : Colors.grey.shade800,
                                ),
                              ),
                              subtitle: Text(
                                currency['code']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? Icon(
                                        Icons.check_circle,
                                        color: TColors.primary,
                                        size: 28,
                                      )
                                      : null,
                              onTap: () async {
                                try {
                                  // تحديث العملة المحلية
                                  currencyController.userCurrency.value =
                                      currency['code']!;

                                  // تحديث في قاعدة البيانات
                                  final userId =
                                      authController.currentUser.value?.userId;
                                  if (userId != null) {
                                    await SupabaseService.client
                                        .from('user_profiles')
                                        .update({
                                          'default_currency': currency['code']!,
                                        })
                                        .eq('user_id', userId);

                                    debugPrint(
                                      '✅ Currency updated to: ${currency['code']}',
                                    );
                                  }

                                  Navigator.pop(context);

                                  Get.snackbar(
                                    'success'.tr,
                                    '${'settings.currency_updated'.tr} ${currency['name']}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green.shade100,
                                    colorText: Colors.green.shade800,
                                    duration: Duration(seconds: 2),
                                  );
                                } catch (e) {
                                  debugPrint('❌ Error updating currency: $e');

                                  Get.snackbar(
                                    'error'.tr,
                                    'settings.currency_update_failed'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade800,
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    _showComingSoonDialog('Theme');
  }

  void _showStorageDialog() {
    Get.to(
      () => const StorageManagementPage(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 900),
    );
  }

  void _showUpdatesDialog() {
    _showComingSoonDialog('App Updates');
  }

  void _showHelpDialog() {
    _showComingSoonDialog('Help Center');
  }

  void _showFeedbackDialog() {
    _showComingSoonDialog('Send Feedback');
  }

  void _showAboutDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings.about_app'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settings.app_name'.tr),
              SizedBox(height: 8),
              Text('settings.version'.tr),
              SizedBox(height: 8),
              Text('settings.build'.tr),
              SizedBox(height: 8),
              Text('settings.developer'.tr),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'settings.ok'.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog() {
    _showComingSoonDialog('Contact Us');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings.delete_account_confirm'.tr),
          content: Text('settings.delete_account_message'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('settings.cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoonDialog('settings.delete_account'.tr);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'settings.delete'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(AuthController authController) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings.sign_out_confirm'.tr),
          content: Text('settings.sign_out_message'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('settings.cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'settings.sign_out'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    Get.snackbar(
      feature,
      '$feature ${'settings.coming_soon_feature'.tr}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: Duration(seconds: 2),
    );
  }
}
