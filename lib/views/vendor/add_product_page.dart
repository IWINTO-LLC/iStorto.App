import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/data/models/vendor_category_model.dart';
import 'package:istoreto/data/repositories/vendor_category_repository.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/services/image_upload_service.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'dart:io';

/// صفحة إضافة منتج جديد - تصميم حديث
class AddProductPage extends StatefulWidget {
  final String vendorId;

  const AddProductPage({super.key, required this.vendorId});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final ProductController _productController = Get.put(ProductController());
  final VendorCategoryRepository _categoryRepository = Get.put(
    VendorCategoryRepository(),
  );

  // Form state
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _minQuantityController = TextEditingController(text: '1');

  // Observables
  final RxList<XFile> _selectedImages = <XFile>[].obs;
  final Rx<VendorCategoryModel?> _selectedCategory = Rx<VendorCategoryModel?>(
    null,
  );
  final Rx<SectorModel?> _selectedSection = Rx<SectorModel?>(null);
  final RxList<VendorCategoryModel> _categories = <VendorCategoryModel>[].obs;
  final RxList<SectorModel> _sections = <SectorModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSaving = false.obs;

  // Upload progress
  final RxDouble _uploadProgress = 0.0.obs;
  final RxString _uploadStatus = ''.obs;

  // Currency
  final RxString _selectedCurrency = 'USD'.obs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _discountController.dispose();
    _minQuantityController.dispose();
    super.dispose();
  }

  /// تحميل البيانات الأولية
  Future<void> _loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        _loadCategories(),
        _loadSections(),
        _loadDefaultCurrency(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// تحميل العملة الافتراضية للتاجر
  Future<void> _loadDefaultCurrency() async {
    try {
      final authController = Get.find<AuthController>();
      final currencyController = Get.find<CurrencyController>();

      // جلب العملة الافتراضية للتاجر
      final vendor = authController.currentUser.value;
      if (vendor?.vendorId != null) {
        // يمكن إضافة منطق لجلب العملة من قاعدة البيانات
        _selectedCurrency.value =
            currencyController.userCurrency.value.isNotEmpty
                ? currencyController.userCurrency.value
                : 'USD';
      }
    } catch (e) {
      debugPrint('Error loading default currency: $e');
      _selectedCurrency.value = 'USD'; // قيمة افتراضية
    }
  }

  /// تحميل الفئات
  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getVendorCategories(
        widget.vendorId,
      );
      _categories.value = categories;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  /// تحميل الأقسام (Sections)
  Future<void> _loadSections() async {
    try {
      // هنا يمكن جلب الأقسام من قاعدة البيانات
      // أو استخدام قائمة افتراضية
      _sections.value = [
        SectorModel(
          name: 'all',
          englishName: 'All Products',
          vendorId: widget.vendorId,
        ),
        SectorModel(
          name: 'offers',
          englishName: 'Offers',
          vendorId: widget.vendorId,
        ),
        SectorModel(
          name: 'sales',
          englishName: 'Sales',
          vendorId: widget.vendorId,
        ),
        SectorModel(
          name: 'newArrival',
          englishName: 'New Arrival',
          vendorId: widget.vendorId,
        ),
        SectorModel(
          name: 'featured',
          englishName: 'Featured',
          vendorId: widget.vendorId,
        ),
      ];
    } catch (e) {
      debugPrint('Error loading sections: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'add_new_product'.tr,
        centerTitle: true,
        actions: [
          // زر الحفظ
          Obx(() {
            return TextButton.icon(
              onPressed: _isSaving.value ? null : () => _saveProduct(),
              icon: Icon(
                Icons.check,
                color: _isSaving.value ? Colors.grey : TColors.primary,
              ),
              label: Text(
                'save'.tr,
                style: TextStyle(
                  color: _isSaving.value ? Colors.grey : TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات أساسية
                _buildSectionTitle('basic_information'.tr, Icons.info_outline),
                const SizedBox(height: 16),
                _buildBasicInfoSection(),

                const SizedBox(height: 24),

                // التصنيف والقسم
                _buildSectionTitle(
                  'category_and_section'.tr,
                  Icons.category_outlined,
                ),
                const SizedBox(height: 16),
                _buildCategorySection(),

                const SizedBox(height: 24),

                // التسعير
                _buildSectionTitle('pricing'.tr, Icons.attach_money),
                const SizedBox(height: 16),
                _buildPricingSection(),

                const SizedBox(height: 24),

                // الصور
                _buildSectionTitle('product_images'.tr, Icons.image_outlined),
                const SizedBox(height: 16),
                _buildImagesSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      // زر الحفظ السفلي
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// عنوان القسم
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: TColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: titilliumBold.copyWith(
            fontSize: 18,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  /// قسم المعلومات الأساسية
  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // اسم المنتج
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'product_name'.tr,
              hintText: 'enter_product_name'.tr,
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'product_name_required'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // الوصف
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'product.description'.tr,
              hintText: 'enter_product_description'.tr,
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // الحد الأدنى للكمية
          TextFormField(
            controller: _minQuantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'product.minimum_quantity'.tr,
              hintText: '1',
              prefixIcon: const Icon(Icons.inventory_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'common.required'.tr;
              final num = int.tryParse(value);
              if (num == null || num < 1) return 'minimum_quantity_error'.tr;
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// قسم التصنيف والقسم
  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // اختيار التصنيف
          _buildCategoryDropdown(),
          const SizedBox(height: 16),

          // اختيار القسم
          _buildSectionDropdown(),
        ],
      ),
    );
  }

  /// قائمة التصنيفات المنسدلة
  Widget _buildCategoryDropdown() {
    return Obx(() {
      // إضافة خيار "بدون تصنيف"
      final allCategories = [
        VendorCategoryModel(
          id: 'no_category',
          vendorId: widget.vendorId,
          title: 'no_category'.tr,
        ),
        ..._categories,
      ];

      return DropdownButtonFormField<VendorCategoryModel>(
        value: _selectedCategory.value,
        decoration: InputDecoration(
          labelText: 'product.category'.tr,
          prefixIcon: const Icon(Icons.category_outlined),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => _createNewCategory(),
            tooltip: 'add_new_category'.tr,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items:
            allCategories.map((category) {
              return DropdownMenuItem<VendorCategoryModel>(
                value: category,
                child: Row(
                  children: [
                    if (category.id == 'no_category')
                      Icon(Icons.block, size: 18, color: Colors.grey)
                    else
                      Icon(Icons.folder, size: 18, color: TColors.primary),
                    const SizedBox(width: 12),
                    Text(category.title),
                  ],
                ),
              );
            }).toList(),
        onChanged: (value) {
          _selectedCategory.value = value;
        },
      );
    });
  }

  /// قائمة الأقسام المنسدلة
  Widget _buildSectionDropdown() {
    return Obx(() {
      return DropdownButtonFormField<SectorModel>(
        value: _selectedSection.value,
        decoration: InputDecoration(
          labelText: 'product.section'.tr,
          prefixIcon: const Icon(Icons.dashboard_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items:
            _sections.map((section) {
              return DropdownMenuItem<SectorModel>(
                value: section,
                child: Text(section.englishName),
              );
            }).toList(),
        onChanged: (value) {
          _selectedSection.value = value;
        },
      );
    });
  }

  /// قسم التسعير
  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // اختيار العملة
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    'currency'.tr,
                    style: titilliumBold.copyWith(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCurrency.value,
                        style: titilliumBold.copyWith(
                          fontSize: 16,
                          color: TColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showCurrencySelector,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // السعر الأساسي
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'product.sale_price'.tr,
              hintText: '0',
              suffixText: _selectedCurrency.value,
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'product.price_required'.tr;
              return null;
            },
            onChanged: (value) => _calculateDiscount(),
          ),
          const SizedBox(height: 16),

          // نسبة الخصم
          TextFormField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'product.discount_percentage'.tr,
              hintText: '0',
              suffixText: '%',
              prefixIcon: const Icon(Icons.percent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _calculateOldPrice(),
          ),
          const SizedBox(height: 16),

          // السعر القديم
          TextFormField(
            controller: _oldPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'original_price'.tr,
              hintText: '0',
              suffixText: _selectedCurrency.value,
              prefixIcon: const Icon(Icons.money_off),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _calculateDiscount(),
          ),
        ],
      ),
    );
  }

  /// قسم الصور
  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // عنوان قسم الصور مع عداد الصور
          Obx(() {
            if (_selectedImages.isNotEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'product_images'.tr,
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _openImagePreview(context),
                        icon: const Icon(Icons.fullscreen, size: 16),
                        label: Text(
                          'preview'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_selectedImages.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 16),

          // عرض الصور المحددة
          Obx(() {
            if (_selectedImages.isEmpty) {
              return _buildEmptyImagesState();
            }
            return _buildImagesList();
          }),
          const SizedBox(height: 16),

          // أزرار إضافة الصور
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImages(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text('camera'.tr),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImages(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: Text('gallery'.tr),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// حالة عدم وجود صور
  Widget _buildEmptyImagesState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'no_images_added'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'tap_buttons_below_to_add'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  /// قائمة الصور
  Widget _buildImagesList() {
    return SizedBox(
      height: 220, // زيادة الارتفاع لاستيعاب الأزرار
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openImagePreview(context, initialIndex: index),
            child: Stack(
              children: [
                Container(
                  width: 150, // العرض
                  height: 200, // الطول (نسبة 8:6 = 4:3)
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // زر المعاينة
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

                // زر الحذف
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _selectedImages.removeAt(index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// شريط الحفظ السفلي
  Widget _buildBottomBar() {
    return Obx(() {
      if (_isSaving.value) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // التقدم المئوي
              if (_uploadProgress.value > 0) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: _uploadProgress.value,
                        strokeWidth: 2,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          TColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${(_uploadProgress.value * 100).toInt()}% - ${_uploadStatus.value}',
                        style: titilliumBold.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // مؤشر التحميل العام
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    _uploadStatus.value.isNotEmpty
                        ? _uploadStatus.value
                        : 'saving_product'.tr,
                    style: titilliumBold.copyWith(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 100),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _saveProduct(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline),
                const SizedBox(width: 8),
                Text(
                  'save_product'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// اختيار الصور
  Future<void> _pickImages(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final List<XFile> images = await picker.pickMultiImage();
        _selectedImages.addAll(images);
      } else {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          _selectedImages.add(image);
        }
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_pick_images'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// حساب الخصم
  void _calculateDiscount() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final oldPrice = double.tryParse(_oldPriceController.text) ?? 0;

    if (price > 0 && oldPrice > price) {
      final discount = ((oldPrice - price) / oldPrice * 100).toInt();
      _discountController.text = discount.toString();
    }
  }

  /// حساب السعر القديم
  void _calculateOldPrice() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;

    if (price > 0 && discount > 0 && discount < 100) {
      final oldPrice = (price / (1 - discount / 100)).toInt();
      _oldPriceController.text = oldPrice.toString();
    }
  }

  /// إنشاء تصنيف جديد
  Future<void> _createNewCategory() async {
    final result = await Get.to(
      () => CreateCategory(vendorId: widget.vendorId),
    );

    if (result == true) {
      await _loadCategories();
    }
  }

  /// فتح معاينة الصور المرفوعة
  void _openImagePreview(BuildContext context, {int? initialIndex}) {
    if (_selectedImages.isEmpty) return;

    // تحويل XFile إلى File
    List<File> imageFiles =
        _selectedImages.map((xFile) => File(xFile.path)).toList();

    showFullscreenImage(
      context: context,
      images: imageFiles,
      initialIndex: initialIndex ?? 0,
      showDeleteButton: true,
      showEditButton: true,
      onDelete: (index) {
        // حذف الصورة من القائمة
        _selectedImages.removeAt(index);
        // إغلاق المعاينة بعد الحذف
        Navigator.pop(context);
      },
      onSave: (File processedFile, int index) {
        // استبدال الصورة الأصلية بالصورة المعدلة
        _selectedImages[index] = XFile(processedFile.path);
        // تحديث الواجهة لتعكس التغييرات
        _selectedImages.value = List.from(_selectedImages);
        // إظهار رسالة تأكيد الحفظ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'image_saved_successfully'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  /// عرض اختيار العملة
  void _showCurrencySelector() {
    final List<String> currencies = [
      'USD',
      'EUR',
      'SAR',
      'AED',
      'EGP',
      'JOD',
      'KWD',
      'QAR',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),

                Text(
                  'select_currency'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // قائمة العملات
                ...currencies.map((currency) {
                  final isSelected = _selectedCurrency.value == currency;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? TColors.primary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          currency,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      currency,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? TColors.primary : Colors.black87,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(Icons.check_circle, color: TColors.primary)
                            : null,
                    onTap: () async {
                      await _updateDefaultCurrency(currency);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// تحديث العملة الافتراضية للتاجر
  Future<void> _updateDefaultCurrency(String currency) async {
    try {
      final authController = Get.find<AuthController>();
      final currencyController = Get.find<CurrencyController>();

      // تحديث العملة المحلية
      _selectedCurrency.value = currency;

      // تحديث في CurrencyController
      currencyController.userCurrency.value = currency;

      // تحديث في قاعدة البيانات
      final userId = authController.currentUser.value?.userId;
      if (userId != null) {
        await SupabaseService.client
            .from('user_profiles')
            .update({'default_currency': currency})
            .eq('user_id', userId);

        debugPrint('✅ Default currency updated to: $currency');

        Get.snackbar(
          'success'.tr,
          'currency_updated_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating default currency: $e');

      Get.snackbar(
        'error'.tr,
        'failed_to_update_currency'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// حفظ المنتج
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'error'.tr,
        'please_fill_required_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_add_at_least_one_image'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    try {
      _isSaving.value = true;

      // تحضير البيانات مع logging مفصل
      final sectionType = _selectedSection.value?.name ?? 'all';

      debugPrint('=== SAVE PRODUCT DEBUG ===');
      debugPrint('Vendor ID: ${widget.vendorId}');
      debugPrint('Section Type: $sectionType');
      debugPrint('Title: ${_titleController.text.trim()}');
      debugPrint('Description: ${_descriptionController.text.trim()}');
      debugPrint(
        'Min Quantity: ${int.tryParse(_minQuantityController.text) ?? 1}',
      );
      debugPrint('Selected Category: ${_selectedCategory.value?.id}');
      debugPrint('Selected Section: ${_selectedSection.value?.name}');
      debugPrint('Images Count: ${_selectedImages.length}');

      // Log كل صورة
      for (int i = 0; i < _selectedImages.length; i++) {
        debugPrint('Image $i: ${_selectedImages[i].path}');
      }

      // تحقق من null values
      if (widget.vendorId.isEmpty) {
        throw Exception('Vendor ID is empty');
      }

      if (_titleController.text.trim().isEmpty) {
        throw Exception('Product title is empty');
      }

      // رفع الصور أولاً مع التقدم المئوي
      debugPrint('=== UPLOADING IMAGES ===');
      final List<String> imageUrls = [];
      _uploadProgress.value = 0.0;
      _uploadStatus.value = 'uploading_images'.tr;

      for (int i = 0; i < _selectedImages.length; i++) {
        try {
          debugPrint('Uploading image ${i + 1}/${_selectedImages.length}');
          _uploadStatus.value =
              'uploading_image'.tr + ' ${i + 1}/${_selectedImages.length}';

          // تحويل XFile إلى File
          final File imageFile = File(_selectedImages[i].path);

          // رفع الصورة
          final uploadResult = await ImageUploadService.instance.uploadImage(
            imageFile: imageFile,
            folderName: 'products',
            customFileName:
                'product_${DateTime.now().millisecondsSinceEpoch}_$i',
          );

          if (uploadResult['success'] == true) {
            imageUrls.add(uploadResult['url']);
            debugPrint(
              'Image ${i + 1} uploaded successfully: ${uploadResult['url']}',
            );
          } else {
            throw Exception(
              'Failed to upload image ${i + 1}: ${uploadResult['error']}',
            );
          }

          // تحديث التقدم
          _uploadProgress.value = (i + 1) / _selectedImages.length;
        } catch (e) {
          debugPrint('Error uploading image ${i + 1}: $e');
          throw Exception('Failed to upload image ${i + 1}: $e');
        }
      }

      debugPrint('All images uploaded successfully: $imageUrls');
      _uploadStatus.value = 'images_uploaded_successfully'.tr;

      // إنشاء المنتج
      await _productController.createProductFromAddPage(
        sectionType,
        widget.vendorId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        minQuantity: int.tryParse(_minQuantityController.text) ?? 1,
        price: double.tryParse(_priceController.text) ?? 0.0,
        oldPrice: double.tryParse(_oldPriceController.text),
        vendorCategoryId:
            _selectedCategory.value?.id == 'no_category'
                ? null
                : _selectedCategory.value?.id,
        imageUrls: imageUrls,
      );

      debugPrint('=== PRODUCT CREATED SUCCESSFULLY ===');

      Get.back(); // العودة للصفحة السابقة
      Get.snackbar(
        'success'.tr,
        'product_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERROR SAVING PRODUCT ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      // Log تفاصيل أكثر
      debugPrint('Error Type: ${e.runtimeType}');
      if (e.toString().contains('Null check operator used on a null value')) {
        debugPrint('NULL CHECK ERROR DETECTED');
        debugPrint('This usually means a required field is null');
        debugPrint('Check if all required parameters are provided');
      }

      Get.snackbar(
        'error'.tr,
        'failed_to_create_product'.tr + ': $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 5), // زيادة المدة لقراءة الخطأ
      );
    } finally {
      _isSaving.value = false;
    }
  }
}
