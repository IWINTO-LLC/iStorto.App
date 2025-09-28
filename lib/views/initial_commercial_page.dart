import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/initial_commercial_controller.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:sizer/sizer.dart';

class InitialCommercialPage extends StatelessWidget {
  const InitialCommercialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InitialCommercialController());

    return Scaffold(
      appBar: AppBar(
        title: Text('create_commercial_account'.tr),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(controller, 0, 'basic_info'.tr),
                Expanded(child: _buildStepLine(controller, 0)),
                _buildStepIndicator(controller, 1, 'images'.tr),
                Expanded(child: _buildStepLine(controller, 1)),
                _buildStepIndicator(controller, 2, 'save'.tr),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: [
                _buildStep1(controller),
                _buildStep2(controller),
                _buildStep3(controller),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Obx(
                  () =>
                      controller.canGoPrevious
                          ? Expanded(
                            child: ElevatedButton(
                              onPressed: controller.previousStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'previous'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
                Obx(
                  () =>
                      controller.canGoPrevious
                          ? const SizedBox(width: 16)
                          : const SizedBox.shrink(),
                ),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isLastStep
                              ? controller.saveCommercialAccount
                              : controller.nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          controller.isLoading.value
                              ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (controller.isUploading.value)
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'uploading'.tr +
                                              ' ${(controller.uploadProgress.value * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                ],
                              )
                              : Text(
                                controller.nextButtonText,
                                style: const TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    InitialCommercialController controller,
    int step,
    String title,
  ) {
    return Obx(
      () => Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color:
                  controller.currentStep.value >= step
                      ? TColors.primary
                      : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color:
                  controller.currentStep.value >= step
                      ? TColors.primary
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(InitialCommercialController controller, int step) {
    return Obx(
      () => Container(
        height: 2,
        color:
            controller.currentStep.value > step
                ? TColors.primary
                : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStep1(InitialCommercialController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'basic_information'.tr,
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtWsections),

              // Organization Name
              TextFormField(
                controller: controller.organizationNameController,
                decoration: InputDecoration(
                  labelText: 'organization_name'.tr + ' *',
                  hintText: 'enter_organization_name'.tr,
                  border: const OutlineInputBorder(),
                ),
                validator: controller.validateOrganizationName,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              // Slug
              TextFormField(
                controller: controller.slugnController,
                decoration: InputDecoration(
                  labelText: 'organization_slug'.tr + ' *',
                  hintText: 'slug_example'.tr,
                  border: const OutlineInputBorder(),
                ),
                validator: controller.validateSlug,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              // Organization Bio
              TextFormField(
                controller: controller.organizationBioController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'organization_bio'.tr,
                  hintText: 'organization_bio_hint'.tr,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2(InitialCommercialController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'organization_images'.tr,
              style: Theme.of(
                Get.context!,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtWsections),

            // Organization Logo
            _buildLogoSelector(controller),
            const SizedBox(height: TSizes.spaceBtWsections),

            // Organization Cover
            _buildCoverSelector(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSelector(InitialCommercialController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'organization_logo'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasImage = controller.organizationLogo.isNotEmpty;

          return Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                hasImage
                    ? Stack(
                      children: [
                        Center(
                          child: TRoundedContainer(
                            radius: BorderRadius.circular(100),
                            showBorder: true,
                            borderWidth: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                File(controller.organizationLogo.first.path),
                                width: 40.w,
                                height: 40.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => controller.removeLogo(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'tap_to_select_image'.tr,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => controller.showLogoSourceDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'select'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          );
        }),
      ],
    );
  }

  Widget _buildCoverSelector(InitialCommercialController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'organization_cover'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasImage = controller.organizationCover.isNotEmpty;

          return Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                hasImage
                    ? Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 60.w,
                            height: 45.w, // 4:3 ratio
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: TColors.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.file(
                                File(controller.organizationCover.first.path),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => controller.removeCover(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'tap_to_select_image'.tr,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => controller.showCoverSourceDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'select'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3(InitialCommercialController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'category_selection_title'.tr,
              style: Theme.of(
                Get.context!,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'category_selection_subtitle'.tr,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: TSizes.spaceBtWsections),

            // Category Selection Grid
            Obx(() {
              if (controller.isLoadingCategories.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.availableCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.availableCategories[index];
                  final isSelected = controller.selectedCategories.contains(
                    category.id,
                  );

                  return GestureDetector(
                    onTap:
                        () => controller.toggleCategorySelection(category.id!),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? TColors.primary.withOpacity(0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? TColors.primary
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category Icon/Image
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? TColors.primary
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.category,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Category Name
                          Text(
                            category.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? TColors.primary : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Selection Indicator
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: TSizes.spaceBtWsections),

            // Selected Categories Summary
            Obx(() {
              if (controller.selectedCategories.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'category_selection_warning'.tr,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'selected_categories'.tr,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          controller.selectedCategories.map((categoryId) {
                            final category = controller.availableCategories
                                .firstWhere((cat) => cat.id == categoryId);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: TSizes.spaceBtWsections),

            // Terms and Conditions
            Row(
              children: [
                Icon(Icons.info_outline, color: TColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'terms_conditions_agreement'.tr,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
