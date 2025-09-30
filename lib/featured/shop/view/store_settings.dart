import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
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
    final controller = VendorController.instance;
    final TextEditingController messageController = TextEditingController();
    // التحقق من وجود طلبات باستخدام GetX
    // if (orderController.vendorHasOrders.value) {
    //   // عرض رسالة تحذير إذا كان هناك طلبات
    //   Get.snackbar(
    //     AppLocalizations.of(context)
    //         .translate('store_settings_store_has_orders'),
    //     AppLocalizations.of(context)
    //         .translate('store_settings_store_has_orders_message'),
    //     backgroundColor: Colors.orange.withOpacity(0.1),
    //     colorText: Colors.orange,
    //     duration: const Duration(seconds: 4),
    //     snackPosition: SnackPosition.TOP,
    //   );
    //   return;
    // }

    // عرض حوار التأكيد إذا لم تكن هناك طلبات
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              'store_settings_delete_store_title'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('store_settings_delete_store_message'.tr),
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
            child: Text('store_settings_delete_store_confirm'.tr),
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

  // متغير حالة لفتح/إغلاق السوشال (يجب أن يكون RxBool)
  static final RxBool showSocialLinks = false.obs;

  // متغيرات Accordion
  static final RxBool showBasicInfo = false.obs;
  static final RxBool showPayment = false.obs; // جديد: Accordion الدفع
  static final RxBool showPhones = false.obs; // جديد: Accordion الهواتف
  static final RxBool showMore = false.obs; // جديد: Accordion المزيد

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

    // التحقق من تغييرات في الهواتف
    final currentPhones = controller.vendorData.value.socialLink?.phones ?? [];
    if (currentPhones.isNotEmpty) {
      // التحقق من أن الهواتف تحتوي على أرقام صحيحة
      for (String phone in currentPhones) {
        if (phone.isNotEmpty && phone.length > 5) {
          hasAnyChanges = true;
          break;
        }
      }
    }

    // التحقق من تغييرات في روابط السوشال ميديا
    final socialLink = controller.profileData.value.socialLink;
    if (socialLink != null) {
      if (socialLink.website.isNotEmpty == true ||
          socialLink.facebook.isNotEmpty == true ||
          socialLink.instagram.isNotEmpty == true ||
          socialLink.whatsapp.isNotEmpty == true ||
          socialLink.location.isNotEmpty == true) {
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
                              message: 'store_settings_saved'.tr,
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
                            'store_settings_save'.tr,
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
            if (vendorData.userId?.isEmpty == true) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: ListView(
                children: [
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  Row(
                    children: [
                      Text(
                        "store_settings_currency".tr,
                        style: titilliumBold.copyWith(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      // changeCurrency(context, vendorId),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement locale toggle
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "store_settings_language".tr,
                          style: titilliumBold.copyWith(fontSize: 18),
                        ),
                        const SizedBox(width: 20),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Icon(Icons.language),
                        ),
                        SizedBox(width: 16),
                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? 'English'
                              : 'العربية',
                          style: titilliumBold.copyWith(fontSize: 18),
                        ),
                        const SizedBox(width: TSizes.spaceBtwInputFields),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtWsections),
                  // Accordion: المعلومات الأساسية
                  GestureDetector(
                    onTap: () => showBasicInfo.value = !showBasicInfo.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'store_settings_basic_info'.tr,
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // const SizedBox(width: 8),
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
                                  'store_settings_organization_name'.tr,
                                  style: titilliumBold.copyWith(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields / 2,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText:
                                        'store_settings_organization_name_hint'
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
                                  'store_settings_brief'.tr,
                                  style: titilliumBold.copyWith(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields / 2,
                                ),
                                TextFormField(
                                  controller: controller.briefController,
                                  maxLines: 2,
                                  onChanged: (val) {
                                    VendorSettingsPage.updateChangesStatus(
                                      controller,
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),
                                Text(
                                  'store_settings_organization_bio'.tr,
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
                          'store_settings_payment'.tr,
                          style: titilliumBold.copyWith(fontSize: 18),
                        ),
                        //const SizedBox(width: 8),
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
                                    "store_settings_cod_hint".tr,
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
                                      "store_settings_enable_iwinto_wallet".tr,
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
                          'store_settings_phones'.tr,
                          style: titilliumBold.copyWith(fontSize: 16),
                        ),
                        // const SizedBox(width: 8),
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
                                  SocialLink();
                              if (socialLink.phones.isNotEmpty ||
                                  socialLink.visiblePhones) {
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
                                          'store_settings_show_on_store_page'
                                              .tr,
                                          style: titilliumBold.copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                        Switch(
                                          value: socialLink.visiblePhones,
                                          onChanged: (val) {
                                            final updated = socialLink.copyWith(
                                              visiblePhones: val,
                                            );
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            // تحديث فوري لحالة التغييرات
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

                                    // باقي الحقول بنفس التنسيق السابق
                                    ...socialLink.phones.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      // final phone = entry.value;
                                      // final phoneController =
                                      //     TextEditingController(text: phone);

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: TSizes.spaceBtwInputFields,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16.0,
                                              ),
                                              child: Icon(
                                                Icons.phone,
                                                size: 26,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Directionality(
                                                textDirection:
                                                    TextDirection.ltr,
                                                child: FlutterPhoneNumberField(
                                                  dropdownTextStyle:
                                                      titilliumRegular.copyWith(
                                                        fontSize: 16,
                                                        fontFamily: numberFonts,
                                                      ),

                                                  style: titilliumRegular
                                                      .copyWith(
                                                        fontSize: 16,
                                                        fontFamily: numberFonts,
                                                      ),

                                                  initialValue:
                                                      socialLink.phones[index],
                                                  focusNode:
                                                      null, // إزالة FocusNode لمنع انتقال التركيز
                                                  textAlign: TextAlign.left,
                                                  pickerDialogStyle:
                                                      PickerDialogStyle(
                                                        countryFlagStyle:
                                                            const TextStyle(
                                                              fontSize: 17,
                                                            ),
                                                      ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        '${'store_settings_phone_hint'.tr} ${index + 1}',
                                                  ),
                                                  languageCode:
                                                      Get
                                                          .locale
                                                          ?.languageCode ??
                                                      'en',
                                                  onChanged: (phone) {
                                                    final updatedPhones =
                                                        List<String>.from(
                                                          socialLink.phones,
                                                        );
                                                    updatedPhones[index] =
                                                        phone.completeNumber;

                                                    final updatedSocial =
                                                        socialLink.copyWith(
                                                          phones: updatedPhones,
                                                        );
                                                    controller
                                                        .profileData
                                                        .value = controller
                                                        .profileData
                                                        .value
                                                        .copyWith(
                                                          socialLink:
                                                              updatedSocial,
                                                        );
                                                    // تحديث فوري لحالة التغييرات
                                                    VendorSettingsPage._safeUpdateChangesWithValue(
                                                      true,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16.0,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  CupertinoIcons.xmark_circle,
                                                  size: 26,
                                                  color: Colors.black,
                                                ),
                                                tooltip:
                                                    'store_settings_delete_phone'
                                                        .tr,
                                                onPressed: () {
                                                  final updatedPhones =
                                                      List<String>.from(
                                                        socialLink.phones,
                                                      )..removeAt(index);
                                                  final updatedSocial =
                                                      socialLink.copyWith(
                                                        phones: updatedPhones,
                                                      );
                                                  controller
                                                      .profileData
                                                      .value = controller
                                                      .profileData
                                                      .value
                                                      .copyWith(
                                                        socialLink:
                                                            updatedSocial,
                                                      );
                                                  // تحديث فوري لحالة التغييرات
                                                  VendorSettingsPage._safeUpdateChangesWithValue(
                                                    true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    TextButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: Text(
                                        'store_settings_add_phone'.tr,
                                      ),
                                      onPressed: () {
                                        final updatedPhones = List<String>.from(
                                          socialLink.phones,
                                        )..add('');
                                        final updatedSocial = socialLink
                                            .copyWith(phones: updatedPhones);
                                        controller
                                            .profileData
                                            .value = controller
                                            .profileData
                                            .value
                                            .copyWith(
                                              socialLink: updatedSocial,
                                            );
                                        // تحديث فوري لحالة التغييرات
                                        VendorSettingsPage._safeUpdateChanges();
                                      },
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
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
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // Website
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Get.locale?.languageCode == 'ar'
                                                ? 'الموقع الإلكتروني'
                                                : 'Website',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'https://example.com',
                                              prefixIcon: const Icon(
                                                Icons.language,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.website ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(website: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleWebsite ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(visibleWebsite: val);
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // Facebook
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Facebook',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'https://facebook.com/username',
                                              prefixIcon: const Icon(
                                                Icons.facebook,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.facebook ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(facebook: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleFacebook ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(
                                                  visibleFacebook: val,
                                                );
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // Instagram
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Instagram',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'https://instagram.com/username',
                                              prefixIcon: const Icon(
                                                Icons.camera_alt,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.instagram ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(instagram: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleInstagram ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(
                                                  visibleInstagram: val,
                                                );
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // WhatsApp
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'WhatsApp',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: '+965 12345678',
                                              prefixIcon: const Icon(
                                                Icons.chat,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.whatsapp ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(whatsapp: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleWhatsapp ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(
                                                  visibleWhatsapp: val,
                                                );
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // TikTok
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TikTok',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'https://tiktok.com/@username',
                                              prefixIcon: const Icon(
                                                Icons.music_note,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.tiktok ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(tiktok: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleTiktok ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(visibleTiktok: val);
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // YouTube
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'YouTube',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'https://youtube.com/channel/...',
                                              prefixIcon: const Icon(
                                                Icons.play_circle,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.youtube ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(youtube: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleYoutube ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(visibleYoutube: val);
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // X (Twitter)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'X (Twitter)',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'https://x.com/username',
                                              // prefixIcon: const Icon(Icons.flutter_dash),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.x ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(x: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleX ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(visibleX: val);
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // LinkedIn
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LinkedIn',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'https://linkedin.com/in/username',
                                              // prefixIcon: Icon(Icons.business)
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.linkedin ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(linkedin: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? 'إظهار'
                                              : 'Show',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.visibleLinkedin ??
                                              false,
                                          onChanged: (val) {
                                            final updated = controller
                                                .profileData
                                                .value
                                                .socialLink
                                                ?.copyWith(
                                                  visibleLinkedin: val,
                                                );
                                            controller
                                                .profileData
                                                .value = controller
                                                .profileData
                                                .value
                                                .copyWith(socialLink: updated);
                                            VendorSettingsPage._safeUpdateChangesWithValue(
                                              true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // Location
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Get.locale?.languageCode == 'ar'
                                                ? 'الموقع'
                                                : 'Location',
                                            style: titilliumBold.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                TSizes.spaceBtwInputFields / 2,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  Get.locale?.languageCode ==
                                                          'ar'
                                                      ? 'رابط موقع على الخريطة'
                                                      : 'Map location link',
                                              prefixIcon: const Icon(
                                                Icons.location_on,
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text:
                                                  controller
                                                      .profileData
                                                      .value
                                                      .socialLink
                                                      ?.location ??
                                                  '',
                                            ),
                                            onChanged: (val) {
                                              final updated = controller
                                                  .profileData
                                                  .value
                                                  .socialLink
                                                  ?.copyWith(location: val);
                                              controller
                                                  .profileData
                                                  .value = controller
                                                  .profileData
                                                  .value
                                                  .copyWith(
                                                    socialLink: updated,
                                                  );
                                              VendorSettingsPage._safeUpdateChangesWithValue(
                                                true,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),
                              ],
                            )
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
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),

                                // تفعيل/إلغاء تفعيل المتجر
                                Obx(
                                  () => GestureDetector(
                                    onTap: () {
                                      // عرض رسالة تأكيد
                                      final isCurrentlyActive =
                                          controller
                                              .organizationActivated
                                              .value;
                                      final actionText =
                                          isCurrentlyActive
                                              ? "store_settings_deactivate_store"
                                                  .tr
                                              : "store_settings_activate_store"
                                                  .tr;

                                      Get.dialog(
                                        AlertDialog(
                                          title: Row(
                                            children: [
                                              Icon(
                                                isCurrentlyActive
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                color:
                                                    isCurrentlyActive
                                                        ? Colors.red
                                                        : Colors.green,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                actionText,
                                                style: TextStyle(
                                                  color:
                                                      isCurrentlyActive
                                                          ? Colors.red
                                                          : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Text(
                                            isCurrentlyActive
                                                ? "store_settings_deactivate_confirm_message"
                                                    .tr
                                                : "store_settings_activate_confirm_message"
                                                    .tr,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text('common.cancel'.tr),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey[200],
                                                foregroundColor:
                                                    Colors.grey[800],
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                controller
                                                    .organizationActivated
                                                    .value = !controller
                                                        .organizationActivated
                                                        .value;
                                                VendorSettingsPage._safeUpdateChangesWithValue(
                                                  true,
                                                );

                                                // عرض رسالة نجاح
                                                TLoader.successSnackBar(
                                                  title: "",
                                                  message:
                                                      isCurrentlyActive
                                                          ? "store_settings_store_deactivated"
                                                              .tr
                                                          : "store_settings_store_activated"
                                                              .tr,
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
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "store_settings_activate_store"
                                                      .tr,
                                                  style: titilliumBold.copyWith(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                controller
                                                        .organizationActivated
                                                        .value
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                color:
                                                    controller
                                                            .organizationActivated
                                                            .value
                                                        ? Colors.red
                                                        : Colors.green,
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            controller
                                                    .organizationActivated
                                                    .value
                                                ? "store_settings_store_active_message"
                                                    .tr
                                                : "store_settings_store_inactive_message"
                                                    .tr,
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

                                // 🗑️ حذف المتجر
                                Obx(() {
                                  final orderController =
                                      OrderController.instance;
                                  final vendorController =
                                      VendorController.instance;

                                  // التحقق من وجود طلبات عند تحميل الصفحة
                                  if (!orderController.vendorHasOrders.value &&
                                      !orderController.isLoading.value) {
                                    orderController.hasOrders(vendorId);
                                  }

                                  // if (orderController.isLoading.value) {
                                  //   return SizedBox(
                                  //     width: 60.w,
                                  //     child: Center(
                                  //       child: TShimmerEffect(
                                  //         height: 50,
                                  //         width: 200,
                                  //         raduis: BorderRadius.circular(10),
                                  //         baseColor: TColors.lightgrey,
                                  //       ),
                                  //     ),
                                  //   );
                                  // }

                                  // إذا كان المتجر محذوف، أظهر زر الاستعادة بدلاً من زر الحذف
                                  if (vendorController
                                          .organizationDeleted
                                          .value ==
                                      true) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'store_settings_restore_store'.tr,
                                            style: titilliumBold.copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    foregroundColor:
                                                        Colors.grey[800],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  onPressed: () async {
                                                    final TextEditingController
                                                    messageController =
                                                        TextEditingController();
                                                    await Get.dialog(
                                                      AlertDialog(
                                                        title: const Text(
                                                          'رسالة اختيارية',
                                                        ),
                                                        content: TextField(
                                                          controller:
                                                              messageController,
                                                          maxLines: 2,
                                                          decoration:
                                                              const InputDecoration(
                                                                hintText:
                                                                    'رسالة تظهر في الصفحة الرئيسية بعد الاستعادة...',
                                                              ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                            child: const Text(
                                                              'إلغاء',
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                            child: const Text(
                                                              'تأكيد',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    vendorController
                                                        .organizationDeleted
                                                        .value = false;
                                                    vendorController
                                                        .storeMessageController
                                                        .text = messageController
                                                            .text
                                                            .trim();
                                                    vendorController
                                                        .profileData
                                                        .value = vendorController
                                                        .profileData
                                                        .value
                                                        .copyWith(
                                                          storeMessage:
                                                              messageController
                                                                  .text
                                                                  .trim(),
                                                        );
                                                    await vendorController
                                                        .saveVendorUpdates(
                                                          vendorId,
                                                        );
                                                    TLoader.successSnackBar(
                                                      title: "",
                                                      message:
                                                          'store_settings_restored'
                                                              .tr,
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.restore,
                                                        color: Colors.grey,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'store_settings_restore_store'
                                                            .tr,
                                                        style: titilliumBold
                                                            .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors
                                                                      .grey[800],
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'store_settings_restore_store_message'
                                                .tr,
                                            style: titilliumRegular.copyWith(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // // // إخفاء زر الحذف إذا كان هناك طلبات
                                  // if (orderController.vendorHasOrders.value) {
                                  //   return Container(
                                  //     width: 60.w,
                                  //     padding: const EdgeInsets.all(16),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.orange.withOpacity(0.1),
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       border: Border.all(
                                  //         color: Colors.orange.withOpacity(0.3),
                                  //       ),
                                  //     ),
                                  //     child: Column(
                                  //       children: [
                                  //         const Icon(
                                  //           Icons.warning,
                                  //           color: Colors.orange,
                                  //           size: 24,
                                  //         ),
                                  //         const SizedBox(height: 8),
                                  //         Text(
                                  //           AppLocalizations.of(context)
                                  //               .translate('store_settings_store_has_orders'),
                                  //           style: titilliumBold.copyWith(
                                  //             fontSize: 14,
                                  //             color: Colors.orange,
                                  //           ),
                                  //           textAlign: TextAlign.center,
                                  //         ),
                                  //         const SizedBox(height: 4),
                                  //         Text(
                                  //
                                  //               'store_settings_store_has_orders_message'),
                                  //           style: titilliumRegular.copyWith(
                                  //             fontSize: 12,
                                  //             color: Colors.orange.withOpacity(0.8),
                                  //           ),
                                  //           textAlign: TextAlign.center,
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   );
                                  // }

                                  return GestureDetector(
                                    onTap:
                                        () => _showDeleteStoreDialog(
                                          context,
                                          vendorId,
                                        ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'store_settings_delete_store'
                                                      .tr,
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
                                            'store_settings_delete_store_warning'
                                                .tr,
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

                                const SizedBox(
                                  height: TSizes.spaceBtwInputFields,
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),

                  // حقل إدخال الرسالة الاختيارية للمتجر
                  //  const SizedBox(height: TSizes.spaceBtWsections),
                  // Text(
                  //   AppLocalizations.of(context)
                  //       .translate('store_settings_store_message_label'),
                  //   style: titilliumBold.copyWith(fontSize: 16),
                  // ),
                  // const SizedBox(height: TSizes.spaceBtwInputFields),
                  // TextFormField(
                  //   controller: controller.storeMessageController,
                  //   maxLines: 2,
                  //   decoration: InputDecoration(
                  //     hintText: AppLocalizations.of(context)
                  //         .translate('store_settings_store_message_hint'),
                  //   ),
                  //   onChanged: (val) {
                  //     VendorSettingsPage.updateChangesStatus(controller);
                  //   },
                  // ),
                ],
              ),
            );
          }),
        ),
      ),
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
              'store_settings_delete_progress_title'.tr,
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
