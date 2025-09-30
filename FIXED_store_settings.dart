import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';

import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/featured/shop/controller/delete_controller.dart';
import 'package:istoreto/featured/shop/data/social-link.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class VendorSettingsPage extends StatelessWidget {
  const VendorSettingsPage({
    super.key,
    required this.fromBage,
    required this.vendorId,
  });

  final String fromBage;
  final String vendorId;

  // عرض حوار تأكيد حذف المتجر
  void _showDeleteStoreDialog(BuildContext context, String vendorId) {
    final orderController = OrderController.instance;
    final controller = VendorController.instance;
    final TextEditingController messageController = TextEditingController();

    // عرض حوار التأكيد
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              'store_settings.delete_store_title'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('store_settings.delete_store_message'.tr),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'رسالة اختيارية تظهر في الصفحة الرئيسية...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // احفظ الرسالة في البروفايل
              controller.storeMessageController.text =
                  messageController.text.trim();
              controller.profileData.value = controller.profileData.value
                  .copyWith(storeMessage: messageController.text.trim());
              _showDeleteProgressDialog(context, vendorId);
            },
            child: Text('store_settings.delete_store_confirm'.tr),
          ),
        ],
      ),
    );
  }

  // عرض نافذة تقدم الحذف
  void _showDeleteProgressDialog(BuildContext context, String vendorId) {
    // تهيئة DeleteController
    final deleteController = Get.put(DeleteController());

    // بدء عملية الحذف
    deleteController.startStoreDeletion(vendorId).then((success) {
      if (success) {
        // إغلاق النافذة بعد ثانيتين
        Future.delayed(const Duration(seconds: 2), () {
          if (Get.isDialogOpen == true) {
            Navigator.pop(context);
          }

          // عرض رسالة النجاح
          deleteController.showSuccessMessage();

          // العودة إلى الصفحة السابقة
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      const Scaffold(body: Center(child: Text('Home'))),
            ),
            (route) => false,
          );
        });
      } else {
        // إغلاق النافذة وعرض رسالة الخطأ
        if (Get.isDialogOpen == true) {
          Navigator.pop(context);
        }
        deleteController.showErrorMessage();
      }
    });

    // عرض نافذة التقدم
    Get.dialog(
      _DeleteProgressDialog(vendorId: vendorId),
      barrierDismissible: false,
    );
  }

  // متغيرات Accordion
  static final RxBool showSocialLinks = false.obs;
  static final RxBool showBasicInfo = false.obs;
  static final RxBool showPayment = false.obs;
  static final RxBool showPhones = false.obs;
  static final RxBool showMore = false.obs;

  // متغير لتتبع التغييرات
  static final RxBool hasChanges = false.obs;

  // دالة مساعدة لتحديث حالة التغييرات بشكل آمن
  static void _safeUpdateChanges() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasChanges.value = true;
    });
  }

  // دالة مساعدة لتحديث حالة التغييرات بشكل آمن مع معامل
  static void _safeUpdateChangesWithValue(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasChanges.value = value;
    });
  }

  // دالة لتحديث حالة التغييرات
  static void updateChangesStatus(VendorController controller) {
    bool hasAnyChanges = false;

    // التحقق من تغييرات في المعلومات الأساسية
    if (controller.organizationNameController.text.isNotEmpty ||
        controller.organizationBioController.text.isNotEmpty ||
        controller.storeMessageController.text.isNotEmpty) {
      hasAnyChanges = true;
    }

    // التحقق من تغييرات في إعدادات الدفع
    if (controller.enableCOD.value != false ||
        controller.enableIwintoPayment.value != false) {
      hasAnyChanges = true;
    }

    // التحقق من تغييرات في حالة المتجر
    if (controller.organizationActivated.value != true) {
      hasAnyChanges = true;
    }

    // التحقق من تغييرات في روابط السوشال ميديا
    final socialLink = controller.profileData.value.socialLink;
    if (socialLink != null) {
      if (socialLink.website.isNotEmpty ||
          socialLink.facebook.isNotEmpty ||
          socialLink.instagram.isNotEmpty ||
          socialLink.whatsapp.isNotEmpty ||
          socialLink.location.isNotEmpty) {
        hasAnyChanges = true;
      }
    }

    // إضافة تأخير بسيط لضمان تحديث الواجهة
    Future.delayed(const Duration(milliseconds: 100), () {
      hasChanges.value = hasAnyChanges;
    });
  }

  @override
  Widget build(BuildContext context) {
    final VendorController controller = VendorController.instance;
    final orderController = OrderController.instance;

    // Initialize the controller with vendor data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.vendorData.value.userId != vendorId) {
        controller.fetchVendorData(vendorId);
      }
      // استدعاء جلب حالة الطلبات عند فتح الصفحة
      if (!orderController.vendorHasOrders.value &&
          !orderController.isLoading.value) {
        orderController.hasOrders(vendorId);
      }
      // تهيئة حالة التغييرات
      VendorSettingsPage.hasChanges.value = false;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MarketPlaceManagment(
                      editMode: false,
                      vendorId: vendorId,
                    ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'settings.title'.tr,
          style: titilliumBold.copyWith(fontSize: 18, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed:
                      VendorSettingsPage.hasChanges.value
                          ? () async {
                            await controller.saveVendorUpdates(vendorId);
                            TLoader.successSnackBar(
                              title: "",
                              message: 'store_settings.saved'.tr,
                            );
                            // إعادة تعيين حالة التغييرات بعد الحفظ
                            VendorSettingsPage.hasChanges.value = false;
                          }
                          : null,
                  style: TextButton.styleFrom(
                    minimumSize: Size(80, 30),
                    backgroundColor:
                        VendorSettingsPage.hasChanges.value
                            ? Colors.black
                            : Colors.grey.withOpacity(0.3),
                    foregroundColor:
                        VendorSettingsPage.hasChanges.value
                            ? Colors.white
                            : Colors.grey,
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
                          ? Container(
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
                            'store_settings.save'.tr,
                            style: titilliumBold.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color:
                                  VendorSettingsPage.hasChanges.value
                                      ? Colors.white
                                      : Colors.grey,
                            ),
                          ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MarketPlaceManagment(
                      vendorId: vendorId,
                      editMode: true,
                    ),
              ),
              (route) => false,
            );
          }
        },
        child: SafeArea(
          child: Obx(() {
            final vendorData = controller.vendorData.value;

            // Initialize controllers if they haven't been initialized yet
            if (vendorData.userId?.isNotEmpty == true) {
              // Ensure controllers are initialized
              try {
                if (controller.organizationBioController.text.isEmpty ||
                    controller.organizationNameController.text.isEmpty) {
                  controller.initializeFromProfile(vendorData, vendorId);
                }
              } catch (e) {
                debugPrint("Error accessing text controllers: $e");
                // Re-initialize controllers if they are null
                controller.initializeFromProfile(vendorData, vendorId);
              }
            }

            // Show loading if vendor data is not loaded yet or controllers are not ready
            if (vendorData.userId?.isEmpty == true ||
                controller.organizationBioController == null ||
                controller.organizationNameController == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: ListView(
                children: [
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Accordion: المعلومات الأساسية
                  GestureDetector(
                    onTap: () => showBasicInfo.value = !showBasicInfo.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'store_settings.basic_info'.tr,
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(
                          () => Icon(
                            showBasicInfo.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () =>
                        showBasicInfo.value
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),
                                Text(
                                  'store_settings.organization_name'.tr,
                                  style: titilliumBold.copyWith(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields / 2,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText:
                                        'store_settings.organization_name_hint'
                                            .tr,
                                  ),
                                  controller:
                                      controller.organizationNameController,
                                  onChanged: (val) {
                                    controller.organizationName.value = val;
                                    VendorSettingsPage.updateChangesStatus(
                                      controller,
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),
                                Text(
                                  'store_settings.organization_bio'.tr,
                                  style: titilliumBold.copyWith(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields / 2,
                                ),
                                TextFormField(
                                  controller:
                                      controller.organizationBioController,
                                  maxLines: 3,
                                  onChanged: (val) {
                                    controller.organizationBio.value = val;
                                    VendorSettingsPage.updateChangesStatus(
                                      controller,
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: TSizes.spaceBtWsections),

                  // Accordion: الدفع
                  GestureDetector(
                    onTap: () => showPayment.value = !showPayment.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'store_settings.payment'.tr,
                          style: titilliumBold.copyWith(fontSize: 18),
                        ),
                        Obx(
                          () => Icon(
                            showPayment.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () =>
                        showPayment.value
                            ? Column(
                              children: [
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields / 2,
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "store_settings.cod_hint".tr,
                                    style: titilliumBold.copyWith(fontSize: 18),
                                  ),
                                  value: controller.enableCOD.value,
                                  onChanged: (val) {
                                    controller.enableCOD.value = val;
                                    VendorSettingsPage.updateChangesStatus(
                                      controller,
                                    );
                                  },
                                  activeColor: TColors.primary,
                                  activeTrackColor: TColors.primary.withOpacity(
                                    0.4,
                                  ),
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      "store_settings.enable_iwinto_wallet".tr,
                                      style: titilliumBold.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  value: controller.enableIwintoPayment.value,
                                  onChanged: (val) {
                                    controller.enableIwintoPayment.value = val;
                                    VendorSettingsPage.updateChangesStatus(
                                      controller,
                                    );
                                  },
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: TSizes.spaceBtWsections),

                  // Accordion: الهواتف
                  GestureDetector(
                    onTap: () => showPhones.value = !showPhones.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'store_settings.phones'.tr,
                          style: titilliumBold.copyWith(fontSize: 16),
                        ),
                        Obx(
                          () => Icon(
                            showPhones.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () =>
                        showPhones.value
                            ? Obx(() {
                              final socialLink =
                                  controller.profileData.value.socialLink ??
                                  const SocialLink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: TSizes.spaceBtwInputFields / 2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'store_settings.show_on_store_page'.tr,
                                        style: titilliumBold.copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Switch(
                                        value: socialLink.visiblePhones,
                                        onChanged: (val) {
                                          controller.updateSocialLinkVisibility(
                                            'phones',
                                            val,
                                          );
                                          VendorSettingsPage._safeUpdateChangesWithValue(
                                            true,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: TSizes.spaceBtwInputFields,
                                  ),
                                  // عرض الهواتف الموجودة
                                  ...socialLink.phones.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: TSizes.spaceBtwInputFields,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 26,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: FlutterPhoneNumberField(
                                                pickerDialogStyle:
                                                    PickerDialogStyle(), // Added required parameter
                                                initialValue:
                                                    socialLink.phones[index],
                                                decoration: InputDecoration(
                                                  hintText:
                                                      '${'store_settings.phone_hint'.tr} ${index + 1}',
                                                ),
                                                onChanged: (phone) {
                                                  final updatedPhones =
                                                      List<String>.from(
                                                        socialLink.phones,
                                                      );
                                                  updatedPhones[index] =
                                                      phone.completeNumber;
                                                  controller.updatePhones(
                                                    updatedPhones,
                                                  );
                                                  VendorSettingsPage._safeUpdateChangesWithValue(
                                                    true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.xmark_circle,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                            tooltip:
                                                'store_settings.delete_phone'
                                                    .tr,
                                            onPressed: () {
                                              final updatedPhones =
                                                  List<String>.from(
                                                    socialLink.phones,
                                                  )..removeAt(index);
                                              controller.updatePhones(
                                                updatedPhones,
                                              );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  TextButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: Text('store_settings.add_phone'.tr),
                                    onPressed: () {
                                      final updatedPhones = List<String>.from(
                                        socialLink.phones,
                                      )..add('');
                                      controller.updatePhones(updatedPhones);
                                      VendorSettingsPage._safeUpdateChanges();
                                    },
                                  ),
                                ],
                              );
                            })
                            : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: TSizes.spaceBtWsections),

                  // Accordion: روابط السوشال ميديا
                  GestureDetector(
                    onTap: () => showSocialLinks.value = !showSocialLinks.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? 'روابط السوشال ميديا'
                              : 'Social Media Links',
                          style: titilliumBold.copyWith(fontSize: 18),
                        ),
                        Obx(
                          () => Icon(
                            showSocialLinks.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () =>
                        showSocialLinks.value
                            ? _buildSocialLinksSection(controller)
                            : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: TSizes.spaceBtWsections),

                  // Accordion: المزيد
                  GestureDetector(
                    onTap: () => showMore.value = !showMore.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Get.locale?.languageCode == 'ar' ? 'المزيد' : 'More',
                          style: titilliumBold.copyWith(fontSize: 18),
                        ),
                        Obx(
                          () => Icon(
                            showMore.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () =>
                        showMore.value
                            ? _buildMoreSection(controller, vendorId)
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection(VendorController controller) {
    return Obx(() {
      final socialLink =
          controller.profileData.value.socialLink ?? const SocialLink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Website
          _buildSocialLinkField(
            controller: controller,
            title:
                Get.locale?.languageCode == 'ar'
                    ? 'الموقع الإلكتروني'
                    : 'Website',
            hintText: 'https://example.com',
            icon: Icons.language,
            value: socialLink.website,
            visible: socialLink.visibleWebsite,
            onChanged: (val) => controller.updateSocialLink('website', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('website', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Facebook
          _buildSocialLinkField(
            controller: controller,
            title: 'Facebook',
            hintText: 'https://facebook.com/username',
            icon: Icons.facebook,
            value: socialLink.facebook,
            visible: socialLink.visibleFacebook,
            onChanged: (val) => controller.updateSocialLink('facebook', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('facebook', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Instagram
          _buildSocialLinkField(
            controller: controller,
            title: 'Instagram',
            hintText: 'https://instagram.com/username',
            icon: Icons.camera_alt,
            value: socialLink.instagram,
            visible: socialLink.visibleInstagram,
            onChanged: (val) => controller.updateSocialLink('instagram', val),
            onVisibilityChanged:
                (val) =>
                    controller.updateSocialLinkVisibility('instagram', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // WhatsApp
          _buildSocialLinkField(
            controller: controller,
            title: 'WhatsApp',
            hintText: '+965 12345678',
            icon: Icons.chat,
            value: socialLink.whatsapp,
            visible: socialLink.visibleWhatsapp,
            onChanged: (val) => controller.updateSocialLink('whatsapp', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('whatsapp', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // TikTok
          _buildSocialLinkField(
            controller: controller,
            title: 'TikTok',
            hintText: 'https://tiktok.com/@username',
            icon: Icons.music_note,
            value: socialLink.tiktok,
            visible: socialLink.visibleTiktok,
            onChanged: (val) => controller.updateSocialLink('tiktok', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('tiktok', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // YouTube
          _buildSocialLinkField(
            controller: controller,
            title: 'YouTube',
            hintText: 'https://youtube.com/channel/...',
            icon: Icons.play_circle,
            value: socialLink.youtube,
            visible: socialLink.visibleYoutube,
            onChanged: (val) => controller.updateSocialLink('youtube', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('youtube', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // X (Twitter)
          _buildSocialLinkField(
            controller: controller,
            title: 'X (Twitter)',
            hintText: 'https://x.com/username',
            icon: Icons.flutter_dash,
            value: socialLink.x,
            visible: socialLink.visibleX,
            onChanged: (val) => controller.updateSocialLink('x', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('x', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // LinkedIn
          _buildSocialLinkField(
            controller: controller,
            title: 'LinkedIn',
            hintText: 'https://linkedin.com/in/username',
            icon: Icons.business,
            value: socialLink.linkedin,
            visible: socialLink.visibleLinkedin,
            onChanged: (val) => controller.updateSocialLink('linkedin', val),
            onVisibilityChanged:
                (val) => controller.updateSocialLinkVisibility('linkedin', val),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Location
          _buildSocialLinkField(
            controller: controller,
            title: Get.locale?.languageCode == 'ar' ? 'الموقع' : 'Location',
            hintText:
                Get.locale?.languageCode == 'ar'
                    ? 'رابط موقع على الخريطة'
                    : 'Map location link',
            icon: Icons.location_on,
            value: socialLink.location,
            visible: true, // Location is always visible
            onChanged: (val) => controller.updateSocialLink('location', val),
            onVisibilityChanged: null, // No visibility toggle for location
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),
        ],
      );
    });
  }

  Widget _buildSocialLinkField({
    required VendorController controller,
    required String title,
    required String hintText,
    required IconData icon,
    required String value,
    required bool visible,
    required Function(String) onChanged,
    Function(bool)? onVisibilityChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titilliumBold.copyWith(fontSize: 16)),
              const SizedBox(height: TSizes.spaceBtwInputFields / 2),
              TextFormField(
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: Icon(icon),
                ),
                controller: TextEditingController(text: value),
                onChanged: (val) {
                  onChanged(val);
                  VendorSettingsPage._safeUpdateChangesWithValue(true);
                },
              ),
            ],
          ),
        ),
        if (onVisibilityChanged != null) ...[
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                Get.locale?.languageCode == 'ar' ? 'إظهار' : 'Show',
                style: titilliumRegular.copyWith(fontSize: 14),
              ),
              Switch(
                value: visible,
                onChanged: (val) {
                  onVisibilityChanged(val);
                  VendorSettingsPage._safeUpdateChangesWithValue(true);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMoreSection(VendorController controller, String vendorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TSizes.spaceBtwInputFields),

        // تفعيل/إلغاء تفعيل المتجر
        Obx(
          () => GestureDetector(
            onTap: () {
              final isCurrentlyActive = controller.organizationActivated.value;
              final actionText =
                  isCurrentlyActive
                      ? "store_settings.deactivate_store".tr
                      : "store_settings.activate_store".tr;

              Get.dialog(
                AlertDialog(
                  title: Row(
                    children: [
                      Icon(
                        isCurrentlyActive
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: isCurrentlyActive ? Colors.red : Colors.green,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        actionText,
                        style: TextStyle(
                          color: isCurrentlyActive ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    isCurrentlyActive
                        ? "store_settings.deactivate_confirm_message".tr
                        : "store_settings.activate_confirm_message".tr,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(Get.context!),
                      child: Text('common.cancel'.tr),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[800],
                      ),
                      onPressed: () {
                        Navigator.pop(Get.context!);
                        controller.organizationActivated.value =
                            !controller.organizationActivated.value;
                        VendorSettingsPage._safeUpdateChangesWithValue(true);

                        TLoader.successSnackBar(
                          title: "",
                          message:
                              isCurrentlyActive
                                  ? "store_settings.store_deactivated".tr
                                  : "store_settings.store_activated".tr,
                        );
                      },
                      child: Text(actionText),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "store_settings.activate_store".tr,
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        controller.organizationActivated.value
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color:
                            controller.organizationActivated.value
                                ? Colors.red
                                : Colors.green,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.organizationActivated.value
                        ? "store_settings.store_active_message".tr
                        : "store_settings.store_inactive_message".tr,
                    style: titilliumRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtWsections),

        // حذف المتجر
        Obx(() {
          final vendorController = VendorController.instance;

          // إذا كان المتجر محذوف، أظهر زر الاستعادة
          if (vendorController.organizationDeleted.value == true) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'store_settings.restore_store'.tr,
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final TextEditingController messageController =
                          TextEditingController();
                      await Get.dialog(
                        AlertDialog(
                          title: const Text('رسالة اختيارية'),
                          content: TextField(
                            controller: messageController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText:
                                  'رسالة تظهر في الصفحة الرئيسية بعد الاستعادة...',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(Get.context!),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(Get.context!),
                              child: const Text('تأكيد'),
                            ),
                          ],
                        ),
                      );
                      vendorController.organizationDeleted.value = false;
                      vendorController.storeMessageController.text =
                          messageController.text.trim();
                      vendorController.profileData.value = vendorController
                          .profileData
                          .value
                          .copyWith(
                            storeMessage: messageController.text.trim(),
                          );
                      await vendorController.saveVendorUpdates(vendorId);
                      TLoader.successSnackBar(
                        title: "",
                        message: 'store_settings.restored'.tr,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restore, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'store_settings.restore_store'.tr,
                          style: titilliumBold.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'store_settings.restore_store_message'.tr,
                    style: titilliumRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // زر الحذف
          return GestureDetector(
            onTap: () => _showDeleteStoreDialog(Get.context!, vendorId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'store_settings.delete_store'.tr,
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.delete_forever,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'store_settings.delete_store_warning'.tr,
                    style: titilliumRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: TSizes.spaceBtwInputFields),
      ],
    );
  }
}

// نافذة تقدم الحذف باستخدام GetX
class _DeleteProgressDialog extends GetView<DeleteController> {
  final String vendorId;

  const _DeleteProgressDialog({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              'store_settings.delete_progress_title'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.isDeleting.value) ...[
              // مؤشر التقدم مع النسبة المئوية
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: controller.progressPercentage.value / 100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.red,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    '${controller.progressPercentage.value.toInt()}%',
                    style: titilliumBold.copyWith(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                controller.currentStep.value,
                style: titilliumRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ] else if (controller.isCompleted.value) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text(
                controller.successMessage,
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
