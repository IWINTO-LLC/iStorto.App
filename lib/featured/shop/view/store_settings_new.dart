import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/social-link.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class VendorSettingsPageNew extends StatelessWidget {
  const VendorSettingsPageNew({
    super.key,
    required this.fromBage,
    required this.vendorId,
  });

  final String fromBage;
  final String vendorId;

  static final RxBool hasChanges = false.obs;

  @override
  Widget build(BuildContext context) {
    final VendorController controller = VendorController.instance;

    // Initialize the controller with vendor data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.vendorData.value.userId != vendorId) {
        controller.fetchVendorData(vendorId);
      }
      hasChanges.value = false;
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'settings.title'.tr,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed:
                      hasChanges.value
                          ? () async {
                            await controller.saveVendorUpdates(vendorId);
                            TLoader.successSnackBar(
                              title: "",
                              message: 'store_settings_saved'.tr,
                            );
                            hasChanges.value = false;
                          }
                          : null,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(80, 30),
                    backgroundColor:
                        hasChanges.value
                            ? Colors.black
                            : Colors.grey.withValues(alpha: 0.3),
                    foregroundColor:
                        hasChanges.value ? Colors.white : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child:
                      controller.isUpdate.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'store_settings_save'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color:
                                  hasChanges.value ? Colors.white : Colors.grey,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final vendorData = controller.vendorData.value;

        if (vendorData.userId?.isEmpty == true) {
          return const Center(child: CircularProgressIndicator());
        }

        // Initialize controllers if needed
        if (vendorData.userId?.isNotEmpty == true) {
          try {
            if (controller.organizationBioController.text.isEmpty ||
                controller.organizationNameController.text.isEmpty) {
              controller.initializeFromProfile(vendorData, vendorId);
            }
          } catch (e) {
            controller.initializeFromProfile(vendorData, vendorId);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              _buildSettingsCard(
                icon: Icons.store,
                title: 'store_settings_basic_info'.tr,
                children: [
                  _buildTextField(
                    label: 'store_settings_organization_name'.tr,
                    controller: controller.organizationNameController,
                    onChanged: (val) {
                      controller.organizationName.value = val;
                      hasChanges.value = true;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'store_settings_brief'.tr,
                    controller: controller.briefController,
                    maxLines: 2,
                    onChanged: (val) {
                      hasChanges.value = true;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'store_settings_organization_bio'.tr,
                    controller: controller.organizationBioController,
                    maxLines: 3,
                    onChanged: (val) {
                      controller.organizationBio.value = val;
                      hasChanges.value = true;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payment Settings Card
              _buildSettingsCard(
                icon: Icons.payment,
                title: 'store_settings_payment'.tr,
                children: [
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('store_settings_cod_hint'.tr),
                      value: controller.enableCOD.value,
                      onChanged: (val) {
                        controller.enableCOD.value = val;
                        hasChanges.value = true;
                      },
                      activeColor: Colors.black,
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('store_settings_enable_iwinto_wallet'.tr),
                      value: controller.enableIwintoPayment.value,
                      onChanged: (val) {
                        controller.enableIwintoPayment.value = val;
                        hasChanges.value = true;
                      },
                      activeColor: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Social Links Card
              _buildSocialLinksCard(controller),

              const SizedBox(height: 16),

              // Phones Card
              _buildPhonesCard(controller),

              const SizedBox(height: 16),

              // Store Status Card
              _buildStoreStatusCard(controller),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinksCard(VendorController controller) {
    return Obx(() {
      final socialLink =
          controller.profileData.value.socialLink ?? const SocialLink();

      return _buildSettingsCard(
        icon: Icons.share,
        title:
            Get.locale?.languageCode == 'ar'
                ? 'روابط السوشال ميديا'
                : 'Social Media Links',
        children: [
          _buildSocialLinkField(
            icon: Icons.language,
            label: 'Website',
            hint: 'example.com',
            value: socialLink.website,
            visible: socialLink.visibleWebsite,
            onChanged: (val) {
              final updated = socialLink.copyWith(website: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleWebsite: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.facebook,
            label: 'Facebook',
            hint: 'username',
            value: socialLink.facebook,
            visible: socialLink.visibleFacebook,
            onChanged: (val) {
              final updated = socialLink.copyWith(facebook: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleFacebook: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.camera_alt,
            label: 'Instagram',
            hint: '@username',
            value: socialLink.instagram,
            visible: socialLink.visibleInstagram,
            onChanged: (val) {
              final updated = socialLink.copyWith(instagram: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleInstagram: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.chat,
            label: 'WhatsApp',
            hint: '+965 12345678',
            value: socialLink.whatsapp,
            visible: socialLink.visibleWhatsapp,
            onChanged: (val) {
              final updated = socialLink.copyWith(whatsapp: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleWhatsapp: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.music_note,
            label: 'TikTok',
            hint: '@username',
            value: socialLink.tiktok,
            visible: socialLink.visibleTiktok,
            onChanged: (val) {
              final updated = socialLink.copyWith(tiktok: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleTiktok: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.play_circle,
            label: 'YouTube',
            hint: 'channel/username',
            value: socialLink.youtube,
            visible: socialLink.visibleYoutube,
            onChanged: (val) {
              final updated = socialLink.copyWith(youtube: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleYoutube: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.flutter_dash,
            label: 'X (Twitter)',
            hint: '@username',
            value: socialLink.x,
            visible: socialLink.visibleX,
            onChanged: (val) {
              final updated = socialLink.copyWith(x: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleX: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.business,
            label: 'LinkedIn',
            hint: 'in/username',
            value: socialLink.linkedin,
            visible: socialLink.visibleLinkedin,
            onChanged: (val) {
              final updated = socialLink.copyWith(linkedin: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              final updated = socialLink.copyWith(visibleLinkedin: val);
              _updateSocialLink(controller, updated);
            },
          ),
          const SizedBox(height: 12),
          _buildSocialLinkField(
            icon: Icons.location_on,
            label: Get.locale?.languageCode == 'ar' ? 'الموقع' : 'Location',
            hint: 'https://maps.google.com/...',
            value: socialLink.location,
            visible: true, // Always visible
            onChanged: (val) {
              final updated = socialLink.copyWith(location: val);
              _updateSocialLink(controller, updated);
            },
            onVisibilityChanged: (val) {
              // Location is always visible
            },
          ),
        ],
      );
    });
  }

  Widget _buildSocialLinkField({
    required IconData icon,
    required String label,
    required String hint,
    required String value,
    required bool visible,
    required Function(String) onChanged,
    required Function(bool) onVisibilityChanged,
  }) {
    final textController = TextEditingController(text: value);
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: textController,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.black),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Text(
              Get.locale?.languageCode == 'ar' ? 'إظهار' : 'Show',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Switch(
              value: visible,
              onChanged: onVisibilityChanged,
              activeColor: Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  void _updateSocialLink(VendorController controller, SocialLink updated) {
    controller.profileData.value = controller.profileData.value.copyWith(
      socialLink: updated,
    );
    controller.vendorData.value = controller.vendorData.value.copyWith(
      socialLink: updated,
    );
    hasChanges.value = true;
  }

  Widget _buildPhonesCard(VendorController controller) {
    return Obx(() {
      final socialLink =
          controller.profileData.value.socialLink ?? const SocialLink();
      final phoneNumbers = socialLink.phones;

      return _buildSettingsCard(
        icon: Icons.phone,
        title:
            Get.locale?.languageCode == 'ar'
                ? 'أرقام الهواتف'
                : 'Phone Numbers',
        children: [
          // Show Phones Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Get.locale?.languageCode == 'ar'
                    ? 'إظهار الهواتف'
                    : 'Show Phones',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Switch(
                value: socialLink.visiblePhones,
                onChanged: (val) {
                  final updated = socialLink.copyWith(visiblePhones: val);
                  _updateSocialLink(controller, updated);
                },
                activeColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone Numbers List
          if (phoneNumbers.isNotEmpty)
            ...phoneNumbers.asMap().entries.map((entry) {
              final index = entry.key;
              final phone = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Icon(
                        Icons.phone,
                        size: 26,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: FlutterPhoneNumberField(
                          dropdownTextStyle: titilliumRegular.copyWith(
                            fontSize: 16,
                            fontFamily: numberFonts,
                          ),
                          style: titilliumRegular.copyWith(
                            fontSize: 16,
                            fontFamily: numberFonts,
                          ),
                          initialValue: phone,
                          focusNode: null,
                          textAlign: TextAlign.left,
                          pickerDialogStyle: PickerDialogStyle(
                            countryFlagStyle: const TextStyle(fontSize: 17),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                '${Get.locale?.languageCode == 'ar' ? 'رقم الهاتف' : 'Phone Number'} ${index + 1}',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          languageCode: Get.locale?.languageCode ?? 'en',
                          onChanged: (phoneNumber) {
                            final updatedPhones = List<String>.from(
                              phoneNumbers,
                            );
                            updatedPhones[index] = phoneNumber.completeNumber;

                            final updatedSocial = socialLink.copyWith(
                              phones: updatedPhones,
                            );
                            _updateSocialLink(controller, updatedSocial);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: IconButton(
                        icon: const Icon(
                          CupertinoIcons.xmark_circle,
                          size: 26,
                          color: Colors.black,
                        ),
                        tooltip:
                            Get.locale?.languageCode == 'ar'
                                ? 'حذف الرقم'
                                : 'Delete Phone',
                        onPressed: () {
                          final updatedPhones = List<String>.from(phoneNumbers)
                            ..removeAt(index);
                          final updatedSocial = socialLink.copyWith(
                            phones: updatedPhones,
                          );
                          _updateSocialLink(controller, updatedSocial);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),

          // Add Phone Button
          TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.black),
            label: Text(
              Get.locale?.languageCode == 'ar'
                  ? 'إضافة رقم هاتف'
                  : 'Add Phone Number',
              style: const TextStyle(color: Colors.black),
            ),
            onPressed: () {
              final updatedPhones = List<String>.from(phoneNumbers)..add('');
              final updatedSocial = socialLink.copyWith(phones: updatedPhones);
              _updateSocialLink(controller, updatedSocial);
            },
          ),
        ],
      );
    });
  }

  Widget _buildStoreStatusCard(VendorController controller) {
    return Obx(
      () => _buildSettingsCard(
        icon: Icons.toggle_on,
        title: 'store_settings_activate_store'.tr,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              controller.organizationActivated.value
                  ? 'store_settings_store_active_message'.tr
                  : 'store_settings_store_inactive_message'.tr,
            ),
            value: controller.organizationActivated.value,
            onChanged: (val) {
              controller.organizationActivated.value = val;
              hasChanges.value = true;
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
