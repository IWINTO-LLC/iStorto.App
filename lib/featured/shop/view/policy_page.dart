import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/policy_repository.dart';
import 'package:istoreto/featured/shop/controller/policy_controller.dart';
import 'package:istoreto/featured/shop/view/widgets/basic_policies_section.dart';
import 'package:istoreto/featured/shop/view/widgets/custom_policies_section.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class PolicyPage extends StatelessWidget {
  PolicyPage({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "إدارة السياسات"),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: PolicyRepository().getPolicyByVendorId(vendorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: TLoaderWidget());
            }

            // إنشاء الكنترولر وتحميل البيانات
            final PolicyController controller = Get.put(PolicyController());

            // تحميل البيانات إذا كانت موجودة
            if (snapshot.hasData && snapshot.data != null) {
              var data = snapshot.data!;

              // تعيين القيم للكنترولر
              controller.aboutUsTx.text = data['about_us'] ?? '';
              controller.termsTx.text = data['terms'] ?? '';
              controller.privacyTx.text = data['privacy'] ?? '';
              controller.returnPolicyTx.text = data['return_policy'] ?? '';
              controller.certificateTx.text = data['certificate'] ?? '';
              controller.licenseTx.text = data['license'] ?? '';

              controller.aboutUsLinkTx.text = data['about_us_link'] ?? '';
              controller.termsLinkTx.text = data['terms_link'] ?? '';
              controller.privacyLinkTx.text = data['privacy_link'] ?? '';
              controller.returnPolicyLinkTx.text =
                  data['return_policy_link'] ?? '';
              controller.certificateLinkTx.text =
                  data['certificate_link'] ?? '';
              controller.licenseLinkTx.text = data['license_link'] ?? '';

              // تحديث القيم التفاعلية
              controller.aboutUs.value = data['about_us'] ?? '';
              controller.terms.value = data['terms'] ?? '';
              controller.privacy.value = data['privacy'] ?? '';
              controller.returnPolicy.value = data['return_policy'] ?? '';
              controller.certificate.value = data['certificate'] ?? '';
              controller.license.value = data['license'] ?? '';

              controller.aboutUsLink.value = data['about_us_link'] ?? '';
              controller.termsLink.value = data['terms_link'] ?? '';
              controller.privacyLink.value = data['privacy_link'] ?? '';
              controller.returnPolicyLink.value =
                  data['return_policy_link'] ?? '';
              controller.certificateLink.value = data['certificate_link'] ?? '';
              controller.licenseLink.value = data['license_link'] ?? '';

              // تحميل السياسات المخصصة
              if (data['custom_policies'] != null) {
                var customPoliciesData = data['custom_policies'] as List;
                controller.customPolicies.value =
                    customPoliciesData
                        .map((policy) => policy as Map<String, dynamic>)
                        .toList();

                // تهيئة حالات الأكورديون للسياسات المخصصة
                for (var policy in controller.customPolicies) {
                  final policyId = policy['id']?.toString();
                  if (policyId != null && policyId.isNotEmpty) {
                    controller.customPoliciesExpanded[policyId] = false;
                  }
                }
              }

              // تحميل الصور وملفات PDF
              if (data['certificate_images'] != null) {
                controller.certificateImages.value = List<String>.from(
                  data['certificate_images'],
                );
              }
              controller.certificatePDF.value = data['certificate_pdf'] ?? '';

              if (data['license_images'] != null) {
                controller.licenseImages.value = List<String>.from(
                  data['license_images'],
                );
              }
              controller.licensePDF.value = data['license_pdf'] ?? '';
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // السياسات الأساسية
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                        textDirection:
                            Get.locale?.languageCode == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextFieldWithLink(
                              Get.locale?.languageCode == 'ar'
                                  ? "🔹من نحن"
                                  : "🔹About Us",
                              controller.aboutUs,
                              controller.aboutUsLink,
                              controller.aboutUsTx,
                              controller.aboutUsLinkTx,
                              "aboutUs",
                              controller,
                            ),
                            SizedBox(height: 16),

                            _buildTextFieldWithLink(
                              Get.locale?.languageCode == 'ar'
                                  ? "🔹شروط الخدمة"
                                  : "🔹Terms & Conditions",
                              controller.terms,
                              controller.termsLink,
                              controller.termsTx,
                              controller.termsLinkTx,
                              "terms",
                              controller,
                            ),
                            SizedBox(height: 16),

                            _buildTextFieldWithLink(
                              Get.locale?.languageCode == 'ar'
                                  ? "🔹سياسة الخصوصية"
                                  : "🔹Privacy Policy",
                              controller.privacy,
                              controller.privacyLink,
                              controller.privacyTx,
                              controller.privacyLinkTx,
                              "privacy",
                              controller,
                            ),
                            SizedBox(height: 16),

                            _buildTextFieldWithLink(
                              Get.locale?.languageCode == 'ar'
                                  ? "🔹سياسة الإعادة"
                                  : "🔹Return Policy",
                              controller.returnPolicy,
                              controller.returnPolicyLink,
                              controller.returnPolicyTx,
                              controller.returnPolicyLinkTx,
                              "returnPolicy",
                              controller,
                            ),
                            SizedBox(height: 16),

                            _buildTextFieldWithImagesAndPDF(
                              Get.locale?.languageCode == 'ar'
                                  ? "🔹الشهادات"
                                  : "🔹Certificates",
                              controller.certificate,
                              controller.certificateLink,
                              controller.certificateTx,
                              controller.certificateLinkTx,
                              controller.certificateImages,
                              controller.certificatePDF,
                              "certificate",
                              controller,
                            ),
                            SizedBox(height: 16),

                            _buildTextFieldWithImagesAndPDF(
                              Get.locale?.languageCode == 'ar'
                                  ? "🔹التراخيص"
                                  : "🔹Licenses",
                              controller.license,
                              controller.licenseLink,
                              controller.licenseTx,
                              controller.licenseLinkTx,
                              controller.licenseImages,
                              controller.licensePDF,
                              "license",
                              controller,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // قسم السياسات المخصصة
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                        textDirection:
                            Get.locale?.languageCode == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Get.locale?.languageCode == 'ar'
                                      ? "السياسات المخصصة"
                                      : "Custom Policies",
                                ),
                                Obx(
                                  () => IconButton(
                                    onPressed: controller.toggleAddPolicyForm,
                                    icon: Icon(
                                      controller.showAddPolicyForm.value
                                          ? Icons.remove
                                          : Icons.add,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // نموذج إضافة سياسة جديدة
                            Obx(
                              () => AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height:
                                    controller.showAddPolicyForm.value
                                        ? null
                                        : 0,
                                child: AnimatedOpacity(
                                  opacity:
                                      controller.showAddPolicyForm.value
                                          ? 1.0
                                          : 0.0,
                                  duration: Duration(milliseconds: 300),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? "إضافة سياسة جديدة"
                                              : "Add New Policy",
                                        ),
                                        SizedBox(height: 16),

                                        TextFormField(
                                          controller:
                                              controller.newPolicyTitleTx,
                                          onChanged:
                                              (value) =>
                                                  controller
                                                      .newPolicyTitle
                                                      .value = value,
                                          decoration: InputDecoration(
                                            labelText:
                                                Get.locale?.languageCode == 'ar'
                                                    ? "عنوان السياسة"
                                                    : "Policy Title",
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 16),

                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? "محتوى السياسة (اختياري)"
                                              : "Policy Content (Optional)",
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller:
                                              controller.newPolicyContentTx,
                                          onChanged:
                                              (value) =>
                                                  controller
                                                      .newPolicyContent
                                                      .value = value,
                                          decoration: InputDecoration(
                                            labelText:
                                                Get.locale?.languageCode == 'ar'
                                                    ? "محتوى السياسة"
                                                    : "Policy Content",
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                          maxLines: 8,
                                        ),
                                        SizedBox(height: 16),

                                        Text(
                                          Get.locale?.languageCode == 'ar'
                                              ? "رابط ويب (اختياري)"
                                              : "Web Link (Optional)",
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          controller:
                                              controller.newPolicyLinkTx,
                                          onChanged:
                                              (value) =>
                                                  controller
                                                      .newPolicyLink
                                                      .value = value,
                                          decoration: InputDecoration(
                                            labelText:
                                                Get.locale?.languageCode == 'ar'
                                                    ? "رابط ويب"
                                                    : "Web Link",
                                            hintText:
                                                Get.locale?.languageCode == 'ar'
                                                    ? "https://example.com"
                                                    : "https://example.com",
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 16),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed:
                                                  controller
                                                      .toggleAddPolicyForm,
                                              child: Text(
                                                Get.locale?.languageCode == 'ar'
                                                    ? "إلغاء"
                                                    : "Cancel",
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                controller.addCustomPolicy();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text(
                                                Get.locale?.languageCode == 'ar'
                                                    ? "إضافة"
                                                    : "Add",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // عرض السياسات المخصصة الموجودة
                            Obx(
                              () => Column(
                                children:
                                    controller.customPolicies.map((policy) {
                                      final policyId = policy['id'] as String;
                                      final title = policy['title'] as String;
                                      final content =
                                          policy['content'] as String;
                                      final link = policy['link'] as String;

                                      return _buildCustomPolicyField(
                                        title,
                                        content,
                                        link,
                                        policyId,
                                        controller,
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),
                    CustomButtonBlack(
                      onTap: () => controller.savePolicy(vendorId),
                      text: "حفظ",
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFieldWithLink(
    String label,
    RxString controllerValue,
    RxString linkValue,
    TextEditingController textController,
    TextEditingController linkController,
    String fieldKey,
    PolicyController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with arrow
          InkWell(
            onTap: () => controller.toggleAccordion(fieldKey),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: Text(label)),
                  Obx(
                    () => AnimatedRotation(
                      turns: controller.getAccordionState(fieldKey) ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: TColors.darkerGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Accordion content
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.getAccordionState(fieldKey) ? null : 0,
              child: AnimatedOpacity(
                opacity: controller.getAccordionState(fieldKey) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    const SizedBox(height: TSizes.spaceBtWItems),

                    // حقل المحتوى
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "محتوى السياسة"
                          : "Policy Content",
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText:
                            Get.locale?.languageCode == 'ar'
                                ? "أدخل محتوى السياسة هنا..."
                                : "Enter policy content here...",
                      ),
                      onChanged: (value) => controllerValue.value = value,
                      maxLines: 10,
                    ),

                    SizedBox(height: 16),

                    // حقل الرابط
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "رابط ويب (اختياري)"
                          : "Web Link (Optional)",
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText:
                            Get.locale?.languageCode == 'ar'
                                ? "https://example.com"
                                : "https://example.com",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => linkValue.value = value,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    RxString controllerValue,
    String fieldKey,
    PolicyController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with arrow
          InkWell(
            onTap: () => controller.toggleAccordion(fieldKey),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: titilliumBold.copyWith(fontSize: 18),
                    ),
                  ),
                  Obx(
                    () => AnimatedRotation(
                      turns: controller.getAccordionState(fieldKey) ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: TColors.darkerGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Accordion content
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.getAccordionState(fieldKey) ? null : 0,
              child: AnimatedOpacity(
                opacity: controller.getAccordionState(fieldKey) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    const SizedBox(height: TSizes.spaceBtWItems),
                    TextFormField(
                      initialValue: controllerValue.value,

                      onChanged: (value) => controllerValue.value = value,
                      maxLines: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPolicyField(
    String title,
    String content,
    String link,
    String policyId,
    PolicyController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with arrow and delete button
          InkWell(
            onTap: () => controller.toggleAccordion(policyId),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: Text(title)),
                  IconButton(
                    onPressed: () => controller.deleteCustomPolicy(policyId),
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip:
                        Get.locale?.languageCode == 'ar'
                            ? "حذف السياسة"
                            : "Delete Policy",
                  ),
                  Obx(
                    () => AnimatedRotation(
                      turns: controller.getAccordionState(policyId) ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Accordion content
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.getAccordionState(policyId) ? null : 0,
              child: AnimatedOpacity(
                opacity: controller.getAccordionState(policyId) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content.isNotEmpty) ...[
                        if (link.isNotEmpty) SizedBox(height: 16),
                      ],
                      if (link.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.link, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Builder(
                                builder:
                                    (context) => Text(
                                      link,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithImagesAndPDF(
    String label,
    RxString controllerValue,
    RxString linkValue,
    TextEditingController textController,
    TextEditingController linkController,
    RxList<String> images,
    RxString pdfFile,
    String fieldKey,
    PolicyController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with arrow
          InkWell(
            onTap: () => controller.toggleAccordion(fieldKey),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: titilliumBold.copyWith(fontSize: 18),
                    ),
                  ),
                  Obx(
                    () => AnimatedRotation(
                      turns: controller.getAccordionState(fieldKey) ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: TColors.darkerGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Accordion content
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.getAccordionState(fieldKey) ? null : 0,
              child: AnimatedOpacity(
                opacity: controller.getAccordionState(fieldKey) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    const SizedBox(height: TSizes.spaceBtWItems),

                    // حقل المحتوى
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "محتوى السياسة"
                          : "Policy Content",
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText:
                            Get.locale?.languageCode == 'ar'
                                ? "أدخل محتوى السياسة هنا..."
                                : "Enter policy content here...",
                      ),
                      onChanged: (value) => controllerValue.value = value,
                      maxLines: 10,
                    ),

                    SizedBox(height: 16),

                    // حقل الرابط
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "رابط ويب (اختياري)"
                          : "Web Link (Optional)",
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText:
                            Get.locale?.languageCode == 'ar'
                                ? "https://example.com"
                                : "https://example.com",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => linkValue.value = value,
                      maxLines: 1,
                    ),

                    SizedBox(height: 16),

                    // قسم الصور
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "الصور (اختياري)"
                          : "Images (Optional)",
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          // عرض الصور المضافة
                          Obx(
                            () =>
                                images.isNotEmpty
                                    ? GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                      itemCount: images.length,
                                      itemBuilder: (context, index) {
                                        String imagePath = images[index];
                                        bool isUploading =
                                            controller
                                                .uploadingImages[imagePath] ==
                                            true;
                                        bool isUploaded =
                                            controller
                                                .uploadedImages[imagePath]
                                                ?.isNotEmpty ==
                                            true;

                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child:
                                                    imagePath.startsWith('http')
                                                        ? Image.network(
                                                          imagePath,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color:
                                                                  Colors
                                                                      .grey[200],
                                                              child: Icon(
                                                                Icons.image,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                        : Image.file(
                                                          File(imagePath),
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color:
                                                                  Colors
                                                                      .grey[200],
                                                              child: Icon(
                                                                Icons.image,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                              ),
                                            ),

                                            // أيقونة الحالة (ساعة أثناء الرفع، صح عند اكتمال الرفع)
                                            if (isUploading || isUploaded)
                                              Positioned(
                                                top: 4,
                                                left: 4,
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isUploading
                                                            ? Colors.orange
                                                            : Colors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    isUploading
                                                        ? Icons.access_time
                                                        : Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),

                                            // زر الحذف
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap:
                                                    () =>
                                                        controller.removeImage(
                                                          images,
                                                          index,
                                                        ),
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // طبقة شفافة أثناء الرفع
                                            if (isUploading)
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    )
                                    : Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            color: Colors.grey[400],
                                            size: 48,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            Get.locale?.languageCode == 'ar'
                                                ? "لا توجد صور مضافة"
                                                : "No images added",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await controller.pickImages(images);
                            },
                            icon: Icon(Icons.add_photo_alternate),
                            label: Text(
                              Get.locale?.languageCode == 'ar'
                                  ? "إضافة صور"
                                  : "Add Images",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // قسم ملف PDF
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "ملف PDF (اختياري)"
                          : "PDF File (Optional)",
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Obx(
                            () =>
                                pdfFile.value.isNotEmpty
                                    ? Row(
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            pdfFile.value.split('/').last,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => pdfFile.value = '',
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.grey[400],
                                            size: 48,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            Get.locale?.languageCode == 'ar'
                                                ? "لا يوجد ملف PDF مرفق"
                                                : "No PDF file attached",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // اختيار ملف PDF
                              try {
                                // هنا يمكن إضافة منطق اختيار ملف PDF
                                // يمكن استخدام file_picker
                                // مثال:
                                // final result = await FilePicker.platform.pickFiles(
                                //   type: FileType.custom,
                                //   allowedExtensions: ['pdf'],
                                // );
                                // if (result != null) {
                                //   // رفع الملف إلى Firebase Storage
                                //   String pdfUrl = await uploadPDFToFirebase(result.files.first);
                                //   pdfFile.value = pdfUrl;
                                // }

                                // مؤقتاً: إضافة رابط PDF تجريبي
                                pdfFile.value =
                                    'https://example.com/sample-document.pdf';
                              } catch (e) {
                                print('Error picking PDF: $e');
                              }
                            },
                            icon: Icon(Icons.attach_file),
                            label: Text(
                              Get.locale?.languageCode == 'ar'
                                  ? "إضافة ملف PDF"
                                  : "Add PDF File",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
