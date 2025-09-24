import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/policy_repository.dart';
import 'package:istoreto/featured/shop/controller/policy_controller.dart';
import 'package:istoreto/featured/shop/view/widgets/basic_policies_section.dart';
import 'package:istoreto/featured/shop/view/widgets/custom_policies_section.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key, required this.vendorId});

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
              return const Center(child: TLoaderWidget());
            }

            // إنشاء الكنترولر وتحميل البيانات
            final PolicyController controller = Get.put(PolicyController());

            // تحميل البيانات إذا كانت موجودة
            if (snapshot.hasData && snapshot.data != null) {
              var data = snapshot.data!;
              controller.loadPolicyData(data);
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // السياسات الأساسية
                    const BasicPoliciesSection(),

                    const SizedBox(height: 32),

                    // قسم السياسات المخصصة
                    const CustomPoliciesSection(),

                    const SizedBox(height: 32),

                    // زر الحفظ
                    CustomButtonBlack(
                      onTap: () => controller.savePolicy(vendorId),
                      text: "حفظ",
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
