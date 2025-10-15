import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/policy_controller.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class BasicPoliciesSection extends StatelessWidget {
  const BasicPoliciesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PolicyController>();

    return Padding(
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
              Get.locale?.languageCode == 'ar' ? "🔹من نحن" : "🔹About Us",
              controller.aboutUs,
              controller.aboutUsLink,
              controller.aboutUsTx,
              controller.aboutUsLinkTx,
              "aboutUs",
              controller,
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            _buildTextFieldWithImagesAndPDF(
              Get.locale?.languageCode == 'ar' ? "🔹التراخيص" : "🔹Licenses",
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
                    const SizedBox(height: 8),
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

                    const SizedBox(height: 16),

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
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText:
                            Get.locale?.languageCode == 'ar'
                                ? "https://example.com"
                                : "https://example.com",
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
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
                    const SizedBox(height: 8),
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

                    const SizedBox(height: 16),

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
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText:
                            Get.locale?.languageCode == 'ar'
                                ? "https://example.com"
                                : "https://example.com",
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => linkValue.value = value,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 16),

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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                      itemCount: images.length,
                                      itemBuilder: (context, index) {
                                        String imagePath = images[index];
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
                                                        : Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.image,
                                                            color:
                                                                Colors
                                                                    .grey[400],
                                                          ),
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
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                    : Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            color: Colors.grey[400],
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
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
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await controller.pickImages(images);
                            },
                            icon: const Icon(Icons.add_photo_alternate),
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

                    const SizedBox(height: 16),

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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                                        const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            pdfFile.value.split('/').last,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => pdfFile.value = '',
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.grey[400],
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
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
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // TODO: Implement PDF picker
                              pdfFile.value =
                                  'https://example.com/sample-document.pdf';
                            },
                            icon: const Icon(Icons.attach_file),
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
