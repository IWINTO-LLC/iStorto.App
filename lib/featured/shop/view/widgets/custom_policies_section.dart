import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/policy_controller.dart';
import 'package:istoreto/utils/common/styles/styles.dart';

class CustomPoliciesSection extends StatelessWidget {
  const CustomPoliciesSection({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Get.locale?.languageCode == 'ar'
                      ? "السياسات المخصصة"
                      : "Custom Policies",
                  style: titilliumBold.copyWith(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
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
            const SizedBox(height: 16),

            // نموذج إضافة سياسة جديدة
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: controller.showAddPolicyForm.value ? null : 0,
                child: AnimatedOpacity(
                  opacity: controller.showAddPolicyForm.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? "إضافة سياسة جديدة"
                              : "Add New Policy",
                          style: titilliumBold.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: controller.newPolicyTitleTx,
                          onChanged:
                              (value) =>
                                  controller.newPolicyTitle.value = value,
                          decoration: InputDecoration(
                            labelText:
                                Get.locale?.languageCode == 'ar'
                                    ? "عنوان السياسة"
                                    : "Policy Title",
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? "محتوى السياسة (اختياري)"
                              : "Policy Content (Optional)",
                          style: titilliumRegular.copyWith(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.newPolicyContentTx,
                          onChanged:
                              (value) =>
                                  controller.newPolicyContent.value = value,
                          decoration: InputDecoration(
                            labelText:
                                Get.locale?.languageCode == 'ar'
                                    ? "محتوى السياسة"
                                    : "Policy Content",
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 8,
                        ),
                        const SizedBox(height: 16),

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
                          controller: controller.newPolicyLinkTx,
                          onChanged:
                              (value) => controller.newPolicyLink.value = value,
                          decoration: InputDecoration(
                            labelText:
                                Get.locale?.languageCode == 'ar'
                                    ? "رابط ويب"
                                    : "Web Link",
                            hintText:
                                Get.locale?.languageCode == 'ar'
                                    ? "https://example.com"
                                    : "https://example.com",
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: controller.toggleAddPolicyForm,
                              child: Text(
                                Get.locale?.languageCode == 'ar'
                                    ? "إلغاء"
                                    : "Cancel",
                              ),
                            ),
                            const SizedBox(width: 8),
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

            const SizedBox(height: 16),

            // عرض السياسات المخصصة الموجودة
            Obx(
              () => Column(
                children:
                    controller.customPolicies.map((policy) {
                      final policyId = policy['id'] as String;
                      final title = policy['title'] as String;
                      final content = policy['content'] as String;
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
                  Expanded(
                    child: Text(
                      title,
                      style: titilliumBold.copyWith(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.deleteCustomPolicy(policyId),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                        color: Colors.grey[600],
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
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content.isNotEmpty) ...[
                        Text(
                          content,
                          style: titilliumRegular.copyWith(fontSize: 14),
                        ),
                        if (link.isNotEmpty) const SizedBox(height: 16),
                      ],
                      if (link.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.link,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                link,
                                style: titilliumRegular.copyWith(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
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
}
