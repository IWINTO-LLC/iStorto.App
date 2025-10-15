import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/data/models/major_category_model.dart';
import 'package:istoreto/data/repositories/major_category_repository.dart';
import 'package:istoreto/services/supabase_service.dart';

class AdminCategoriesController extends GetxController {
  // Observable variables
  final RxList<MajorCategoryModel> categories = <MajorCategoryModel>[].obs;
  final RxList<MajorCategoryModel> filteredCategories =
      <MajorCategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // Filter tracking
  final RxString currentFilter = 'all'.obs;

  // Form controllers
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final arabicNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Image handling
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxString imageUrl = ''.obs;

  // Category editing
  final Rx<MajorCategoryModel?> editingCategory = Rx<MajorCategoryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    arabicNameController.dispose();
    super.onClose();
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final loadedCategories = await MajorCategoryRepository.getAllCategories();
      categories.value = loadedCategories;
      filteredCategories.value = loadedCategories;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search categories
  void searchCategories(String query) {
    if (query.isEmpty) {
      filteredCategories.value = categories;
    } else {
      filteredCategories.value =
          categories.where((category) {
            return category.name.toLowerCase().contains(query.toLowerCase()) ||
                (category.arabicName?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }
  }

  // Filter by status
  void filterByStatus(String status) {
    currentFilter.value = status;

    switch (status) {
      case 'active':
        filteredCategories.value =
            categories.where((c) => c.status == 1).toList();
        break;
      case 'pending':
        // الفئات المعلقة تشمل: status = 2 (معلق) و status = 3 (معطل مؤقتاً)
        filteredCategories.value =
            categories.where((c) => c.status == 2 || c.status == 3).toList();
        break;
      case 'inactive':
        // الفئات المعطلة نهائياً: status = 0 أو أي حالة أخرى
        filteredCategories.value =
            categories.where((c) => c.status == 0).toList();
        break;
      default:
        filteredCategories.value = categories;
    }
  }

  // Get current filter display name
  String get currentFilterName {
    switch (currentFilter.value) {
      case 'active':
        return 'admin_active_categories'.tr;
      case 'pending':
        return 'admin_pending_categories'.tr;
      case 'inactive':
        return 'admin_inactive_categories'.tr;
      default:
        return 'admin_all_categories'.tr;
    }
  }

  // Get current filter icon
  IconData get currentFilterIcon {
    switch (currentFilter.value) {
      case 'active':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'inactive':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }

  // Get current filter color
  Color get currentFilterColor {
    switch (currentFilter.value) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Show add category dialog
  void showAddCategoryDialog() {
    editingCategory.value = null;
    _clearForm();
    _showCategoryDialog();
  }

  // Show edit category dialog
  void showEditCategoryDialog(MajorCategoryModel category) {
    editingCategory.value = category;
    _fillForm(category);
    _showCategoryDialog();
  }

  // Show category dialog
  void _showCategoryDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      editingCategory.value == null ? Icons.add : Icons.edit,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      editingCategory.value == null
                          ? 'add_category'.tr
                          : 'edit_category'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Image
                        Center(child: _buildImageSelector()),
                        const SizedBox(height: 20),

                        // Category Name (English)
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: '${'category_name_en'.tr} *',
                            hintText: 'enter_category_name_en'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'category_name_required'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category Name (Arabic)
                        TextFormField(
                          controller: arabicNameController,
                          decoration: InputDecoration(
                            labelText: 'category_name_ar'.tr,
                            hintText: 'enter_category_name_ar'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('cancel'.tr),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed:
                                      isUploading.value ? null : _saveCategory,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      isUploading.value
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text('admin_saving'.tr),
                                            ],
                                          )
                                          : Text(
                                            editingCategory.value == null
                                                ? 'add'.tr
                                                : 'admin_update'.tr,
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build image selector
  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'admin_category_image'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasImage =
              selectedImage.value != null || imageUrl.value.isNotEmpty;

          return Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child:
                  hasImage
                      ? Stack(
                        children: [
                          ClipOval(
                            child:
                                selectedImage.value != null
                                    ? Image.file(
                                      File(selectedImage.value!.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.network(
                                      imageUrl.value,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.category,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
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
                      )
                      : GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'admin_add_image'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          );
        }),
      ],
    );
  }

  // Show image source dialog
  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('admin_select_image_source'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                _selectImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                _selectImageFromGallery();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        ],
      ),
    );
  }

  // Select image from camera
  Future<void> _selectImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        await _cropImage(image);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Select image from gallery
  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        await _cropImage(image);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Crop image to circle
  Future<void> _cropImage(XFile image) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 for circle
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Category Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Edit Category Image',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImage.value = XFile(croppedFile.path);
        imageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to crop image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove image
  void _removeImage() {
    selectedImage.value = null;
    imageUrl.value = '';
  }

  // Fill form with category data
  void _fillForm(MajorCategoryModel category) {
    nameController.text = category.name;
    arabicNameController.text = category.arabicName ?? '';
    imageUrl.value = category.image ?? '';
    selectedImage.value = null;
  }

  // Clear form
  void _clearForm() {
    nameController.clear();
    arabicNameController.clear();
    imageUrl.value = '';
    selectedImage.value = null;
  }

  // Save category
  Future<void> _saveCategory() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      String? finalImageUrl = imageUrl.value;

      // Upload new image if selected
      if (selectedImage.value != null) {
        uploadProgress.value = 0.3;
        final bytes = await selectedImage.value!.readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.value!.name}';
        final path = 'category-images/$fileName';

        final result = await _supabaseService.uploadImageToStorage(bytes, path);
        if (result['success']) {
          finalImageUrl = result['url'];
        } else {
          throw Exception(result['message'] ?? 'Failed to upload image');
        }
        uploadProgress.value = 0.6;
      }

      // Create or update category
      final categoryData = {
        'name': nameController.text.trim(),
        'arabic_name':
            arabicNameController.text.trim().isEmpty
                ? null
                : arabicNameController.text.trim(),
        'image': finalImageUrl,
        'is_feature': false,
        'status': 1, // Active
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (editingCategory.value == null) {
        // Add new category
        categoryData['created_at'] = DateTime.now().toIso8601String();
        final newCategory = await MajorCategoryRepository.createCategory(
          categoryData,
        );

        // إضافة الفئة الجديدة إلى القائمة محلياً
        _addCategoryToList(newCategory);

        Get.snackbar(
          'Success',
          'Category added successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Update existing category
        final updatedCategory = await MajorCategoryRepository.updateCategory(
          editingCategory.value!.id!,
          categoryData,
        );

        // تحديث الفئة في القائمة محلياً
        _updateCategoryInList(editingCategory.value!.id!, updatedCategory);

        Get.snackbar(
          'Success',
          'Category updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      uploadProgress.value = 1.0;
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Toggle feature status
  Future<void> toggleFeatureStatus(MajorCategoryModel category) async {
    try {
      final newFeatureStatus = !category.isFeature;
      await MajorCategoryRepository.updateCategory(category.id!, {
        'is_feature': newFeatureStatus,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // تحديث القائمة محلياً
      _updateCategoryFeatureInList(category.id!, newFeatureStatus);

      Get.snackbar(
        'Success',
        category.isFeature
            ? 'Category removed from featured'
            : 'Category added to featured',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update feature status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle status
  Future<void> toggleStatus(MajorCategoryModel category) async {
    try {
      final newStatus =
          category.status == 1 ? 2 : 1; // Toggle between active and pending
      await MajorCategoryRepository.updateCategory(category.id!, {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // تحديث القائمة محلياً بدلاً من إعادة التحميل
      _updateCategoryStatusInList(category.id!, newStatus);

      Get.snackbar(
        'Success',
        newStatus == 1 ? 'Category activated' : 'Category suspended',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تحديث حالة فئة في القائمة محلياً
  void _updateCategoryStatusInList(String categoryId, int newStatus) {
    // البحث عن الفئة في القائمة الرئيسية
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      // تحديث الحالة
      categories[categoryIndex] = categories[categoryIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // تحديث القائمة المفلترة
      _applyCurrentFilter();
    }
  }

  // تحديث حالة المميز للفئة في القائمة محلياً
  void _updateCategoryFeatureInList(String categoryId, bool newFeatureStatus) {
    // البحث عن الفئة في القائمة الرئيسية
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      // تحديث حالة المميز
      categories[categoryIndex] = categories[categoryIndex].copyWith(
        isFeature: newFeatureStatus,
        updatedAt: DateTime.now(),
      );

      // تحديث القائمة المفلترة
      _applyCurrentFilter();
    }
  }

  // تطبيق الفلتر الحالي على القائمة
  void _applyCurrentFilter() {
    filterByStatus(currentFilter.value);
  }

  // حذف فئة من القائمة محلياً
  void _removeCategoryFromList(String categoryId) {
    // حذف الفئة من القائمة الرئيسية
    categories.removeWhere((c) => c.id == categoryId);

    // تحديث القائمة المفلترة
    _applyCurrentFilter();
  }

  // إضافة فئة جديدة إلى القائمة محلياً
  void _addCategoryToList(MajorCategoryModel newCategory) {
    // إضافة الفئة الجديدة إلى بداية القائمة
    categories.insert(0, newCategory);

    // تحديث القائمة المفلترة
    _applyCurrentFilter();
  }

  // تحديث فئة كاملة في القائمة محلياً
  void _updateCategoryInList(
    String categoryId,
    MajorCategoryModel updatedCategory,
  ) {
    // البحث عن الفئة في القائمة الرئيسية
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      // استبدال الفئة بالنسخة المحدثة
      categories[categoryIndex] = updatedCategory;

      // تحديث القائمة المفلترة
      _applyCurrentFilter();
    }
  }

  // Show delete confirmation
  void showDeleteConfirmation(MajorCategoryModel category) {
    Get.dialog(
      AlertDialog(
        title: Text('admin_delete_category'.tr),
        content: Text('delete_category_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              deleteCategory(category);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  // Delete category
  Future<void> deleteCategory(MajorCategoryModel category) async {
    try {
      await MajorCategoryRepository.deleteCategory(category.id!);

      // حذف الفئة من القائمة محلياً
      _removeCategoryFromList(category.id!);

      Get.snackbar(
        'Success',
        'Category deleted successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
