import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:istoreto/services/image_upload_service.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/data/models/vendor_category_model.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/loader/loaders.dart';
import 'package:uuid/uuid.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  //Variable
  final isLoading = false.obs;
  final hasChanges = false.obs;
  final productRepository = Get.put(ProductRepository());
  List<ProductModel> saleProduct = [];
  final RxList<ProductModel> allItems = <ProductModel>[].obs;
  RxList<ProductModel> tempProducts = <ProductModel>[].obs;
  RxList<ProductModel> spotList = <ProductModel>[].obs;
  final RxList<ProductModel> productCategory = <ProductModel>[].obs;
  final title = TextEditingController();
  final arabicTitle = TextEditingController();
  final description = TextEditingController();
  final arabicDescription = TextEditingController();
  final minQuantityController = TextEditingController(text: '1');
  final price = TextEditingController();
  var oldPrice = TextEditingController();
  var salePrice = 00.0.obs;
  final saleprecentage = TextEditingController();
  final formKey = GlobalKey<FormState>();
  CategoryModel category = CategoryModel.empty();
  VendorCategoryModel? vendorCategory;
  RxList<String> images = <String>[].obs;
  RxString message = ''.obs;
  final searchTextController = TextEditingController();

  // Check if form has any changes
  void checkForChanges() {
    hasChanges.value =
        title.text.trim().isNotEmpty ||
        description.text.trim().isNotEmpty ||
        price.text.trim().isNotEmpty ||
        selectedImage.isNotEmpty;
  }

  void deleteTempItems() => tempProducts = <ProductModel>[].obs;

  String t = "";
  String a = "";
  var discountPercentage = 10.0.obs;

  /// إنشاء منتج جديد من صفحة الإضافة
  Future<void> createProductFromAddPage(
    String type,
    String vendorId, {
    required String title,
    required String description,
    int minQuantity = 1,
    double? price,
    double? oldPrice,
    String? vendorCategoryId,
    List<String>? imageUrls,
  }) async {
    try {
      debugPrint('=== CREATE PRODUCT FROM ADD PAGE ===');
      debugPrint('Type: $type');
      debugPrint('Vendor ID: $vendorId');
      debugPrint('Title: $title');
      debugPrint('Description: $description');
      debugPrint('Min Quantity: $minQuantity');
      debugPrint('Price: $price');
      debugPrint('Old Price: $oldPrice');
      debugPrint('Vendor Category ID: $vendorCategoryId');
      debugPrint('Image URLs: $imageUrls');

      if (title.isEmpty) {
        throw Exception('Product title is required');
      }

      if (price == null || price <= 0) {
        throw Exception('Product price is required and must be greater than 0');
      }

      if (imageUrls == null || imageUrls.isEmpty) {
        throw Exception('At least one image is required');
      }

      if (vendorId.isEmpty) {
        throw Exception('Vendor ID is required');
      }

      showProgressBar('product.saving_now'.tr);
      message.value = 'product.sending_data'.tr;

      final product = ProductModel(
        id: Uuid().v4(),
        vendorId: vendorId,
        title: title,
        description: description,
        price: price,
        oldPrice: oldPrice ?? 0.0,
        images: imageUrls,
        isFeature: false,
        category: CategoryModel.empty(), // سيتم تحديثها لاحقاً إذا لزم الأمر
        vendorCategoryId: vendorCategoryId,
        productType: type,
        minQuantity: minQuantity,
      );

      debugPrint('Product created: ${product.toJson()}');

      await productRepository.createProduct(product);

      debugPrint('Product saved to database successfully');

      message.value = "everything done";

      allItems.insert(0, product);
      tempProducts.insert(0, product);

      var product1 = ProductModel.fromJson(product.toJson());
      if (type == 'offers') offerDynamic.insert(0, product1);
      if (type == 'all') allDynamic.insert(0, product1);
      if (type == 'all1') allLine1Dynamic.insert(0, product1);
      if (type == 'all2') allLine2Dynamic.insert(0, product1);
      if (type == 'all3') allLine3Dynamic.insert(0, product1);
      if (type == 'sales') salesDynamic.insert(0, product1);
      if (type == 'foryou') foryouDynamic.insert(0, product1);
      if (type == 'mixone') mixoneDynamic.insert(0, product1);
      if (type == 'mixlin1') mixline1Dynamic.insert(0, product1);
      if (type == 'mixlin2') mixline2Dynamic.insert(0, product1);
      if (type == 'mostdeamand') mostdeamandDynamic.insert(0, product1);
      if (type == 'newArrival') newArrivalDynamic.insert(0, product1);

      Get.closeCurrentSnackbar();
      message.value = "";

      debugPrint('Product created successfully');
    } catch (e, stackTrace) {
      debugPrint('=== ERROR IN CREATE PRODUCT FROM ADD PAGE ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      Get.closeCurrentSnackbar();
      message.value = "";
      rethrow;
    }
  }

  /// تحديث منتج موجود
  Future<void> updateProduct({
    required String productId,
    required String type,
    required String vendorId,
    required String title,
    required String description,
    int minQuantity = 1,
    double? price,
    double? oldPrice,
    String? vendorCategoryId,
    List<String>? imageUrls,
  }) async {
    try {
      debugPrint('=== UPDATE PRODUCT ===');
      debugPrint('Product ID: $productId');
      debugPrint('Type: $type');
      debugPrint('Title: $title');
      debugPrint('Price: $price');
      debugPrint('Image URLs Count: ${imageUrls?.length}');

      if (title.isEmpty) {
        throw Exception('Product title is required');
      }

      if (price == null || price <= 0) {
        throw Exception('Product price is required and must be greater than 0');
      }

      if (imageUrls == null || imageUrls.isEmpty) {
        throw Exception('At least one image is required');
      }

      showProgressBar('updating_product'.tr);

      final updatedProduct = ProductModel(
        id: productId,
        vendorId: vendorId,
        title: title,
        description: description,
        price: price,
        oldPrice: oldPrice ?? 0.0,
        images: imageUrls,
        isFeature: false,
        category: CategoryModel.empty(),
        vendorCategoryId: vendorCategoryId,
        productType: type,
        minQuantity: minQuantity,
      );

      await productRepository.updateProduct(updatedProduct);

      debugPrint('Product updated successfully in database');

      // تحديث في القوائم المحلية
      final index = allItems.indexWhere((p) => p.id == productId);
      if (index != -1) {
        allItems[index] = updatedProduct;
      }

      final tempIndex = tempProducts.indexWhere((p) => p.id == productId);
      if (tempIndex != -1) {
        tempProducts[tempIndex] = updatedProduct;
      }

      // تحديث في القوائم الديناميكية حسب النوع
      _updateDynamicLists(productId, updatedProduct, type);

      Get.closeCurrentSnackbar();

      debugPrint('Product updated successfully');
    } catch (e, stackTrace) {
      debugPrint('=== ERROR IN UPDATE PRODUCT ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      Get.closeCurrentSnackbar();
      rethrow;
    }
  }

  /// تحديث القوائم الديناميكية
  void _updateDynamicLists(
    String productId,
    ProductModel product,
    String type,
  ) {
    void updateList(RxList<ProductModel> list) {
      final index = list.indexWhere((p) => p.id == productId);
      if (index != -1) {
        list[index] = ProductModel.fromJson(product.toJson());
      }
    }

    if (type == 'offers') updateList(offerDynamic);
    if (type == 'all') updateList(allDynamic);
    if (type == 'all1') updateList(allLine1Dynamic);
    if (type == 'all2') updateList(allLine2Dynamic);
    if (type == 'all3') updateList(allLine3Dynamic);
    if (type == 'sales') updateList(salesDynamic);
    if (type == 'foryou') updateList(foryouDynamic);
    if (type == 'mixone') updateList(mixoneDynamic);
    if (type == 'mixlin1') updateList(mixline1Dynamic);
    if (type == 'mixlin2') updateList(mixline2Dynamic);
    if (type == 'mostdeamand') updateList(mostdeamandDynamic);
    if (type == 'newArrival') updateList(newArrivalDynamic);
  }

  Future<void> createProduct(
    String type,
    String vendorId, {
    required String title,
    required String description,
    int minQuantity = 1,
  }) async {
    if (title.isEmpty) {
      TLoader.warningSnackBar(
        title: '',
        message: 'product.please_add_title'.tr,
      );
      return;
    }

    if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    }
    if (selectedImage.isEmpty) {
      isLoading.value = false;
      TLoader.warningSnackBar(
        title: '',
        message: 'product.please_add_image'.tr,
      );
      return;
    } else if (category == CategoryModel.empty()) {
      isLoading.value = false;
      TLoader.warningSnackBar(
        title: '',
        message: 'product.please_select_category'.tr,
      );
      Get.closeCurrentSnackbar();
      return;
    }
    var salePriceNumber = double.parse(
      price.text.replaceAll(RegExp(r'[,.]'), ''),
    );
    var oldPriceNumber =
        double.tryParse(oldPrice.text.replaceAll(RegExp(r'[,.]'), '')) ?? 0.00;

    if (oldPriceNumber < salePriceNumber && oldPriceNumber > 0.00) {
      TLoader.warningSnackBar(
        title: '',
        message: 'product.sale_price_less_than_price'.tr,
      );
      return;
    } else {
      showProgressBar('product.saving_now'.tr);
      message.value = 'product.uploading_images'.tr;
      images.value = await uploadImages(selectedImage);
      message.value = 'product.sending_data'.tr;

      final product = ProductModel(
        id: Uuid().v4(),
        vendorId: vendorId,
        title: title,
        description: description,
        price: salePriceNumber,
        oldPrice: oldPriceNumber,
        images: images,
        isFeature: true,
        category: category,
        vendorCategoryId: vendorCategory?.id,
        productType: type,
        minQuantity: minQuantity,
      );
      try {
        if (vendorId.isEmpty) {
          Get.closeCurrentSnackbar();
          throw 'Unable to find user information. try again later';
        }
        message.value = 'product.sending_data'.tr;
        await productRepository.createProduct(product);
        message.value = "evry thing done";

        allItems.insert(0, product);
        tempProducts.insert(0, product);
        var product1 = ProductModel.fromJson(product.toJson());
        if (type == 'offers') offerDynamic.insert(0, product1);
        if (type == 'all') allDynamic.insert(0, product1);
        if (type == 'all1') allLine1Dynamic.insert(0, product1);
        if (type == 'all2') allLine2Dynamic.insert(0, product1);
        if (type == 'all3') allLine3Dynamic.insert(0, product1);
        if (type == 'sales') salesDynamic.insert(0, product1);
        if (type == 'foryou') foryouDynamic.insert(0, product1);
        if (type == 'mixone') mixoneDynamic.insert(0, product1);
        if (type == 'mixlin1') mixline1Dynamic.insert(0, product1);
        if (type == 'mixlin2') mixline2Dynamic.insert(0, product1);
        if (type == 'mostdeamand') mostdeamandDynamic.insert(0, product1);
        if (type == 'newArrival') newArrivalDynamic.insert(0, product1);
        resetFields();
        Get.closeCurrentSnackbar();
        message.value = "";
        selectedImage.value = [];
        TLoader.successSnackBar(
          title: '',
          message: 'product.data_inserted_successfully'.tr,
        );
      } catch (e) {
        Get.closeCurrentSnackbar();
        throw 'product.something_went_wrong'.tr;
      }
    }
  }

  static Text getArabicText(String s, double size, int maxLines, bool isBold) {
    return Text(
      s,
      style: titilliumSemiBold.copyWith(
        fontSize: size,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      maxLines: maxLines,
      textAlign: TextAlign.start,
    );
  }

  static Text getEnglishText(String s, double size, int maxLines, bool isBold) {
    return Text(
      s,
      style: titilliumSemiBold.copyWith(
        fontSize: size + 2,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      maxLines: maxLines,
      textAlign: TextAlign.start,
    );
  }

  // تحديث دوال العرض لتستخدم النظام الجديد
  static Text getTitle(
    ProductModel product,
    double size,
    int maxLines,
    bool isBold,
  ) {
    final title = product.title;
    return Text(
      title,
      style: titilliumSemiBold.copyWith(
        fontSize: size,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      maxLines: maxLines,
      textAlign: TextAlign.start,
    );
  }

  static String getTitleString(ProductModel product) {
    return product.title;
  }

  //final NumberFormat formatter = NumberFormat("#,##0", "en_US");

  Future<int> getUserProductCount(String userId) async {
    var productCount = productRepository.getUserProductCount(userId);
    return productCount; // عدد المنتجات الخاصة بالمستخدم
  }

  void resetFields() {
    isLoading(false);
    title.clear();
    // images.clear();
    arabicTitle.clear();
    description.clear();
    arabicDescription.clear();
    price.clear();
    oldPrice.clear();
    selectedImage.value = [];
    minQuantityController.text = '1';
  }

  Future<void> fetchdata(String vendorId) async {
    try {
      var fetchedItem = await productRepository.getProductsByVendor(vendorId);

      // Filter out deleted products
      allItems.value =
          fetchedItem.where((product) => !(product.isDeleted)).toList();

      // saleProduct = getSaleProduct();
      if (kDebugMode) {
        print("============product length ${allItems.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  RxList<ProductModel> offerDynamic = <ProductModel>[].obs;
  RxList<ProductModel> allDynamic = <ProductModel>[].obs;
  RxList<ProductModel> allLine1Dynamic = <ProductModel>[].obs;
  RxList<ProductModel> allLine2Dynamic = <ProductModel>[].obs;
  RxList<ProductModel> allLine3Dynamic = <ProductModel>[].obs;
  RxList<ProductModel> salesDynamic = <ProductModel>[].obs;
  RxList<ProductModel> foryouDynamic = <ProductModel>[].obs;
  RxList<ProductModel> mixoneDynamic = <ProductModel>[].obs;
  RxList<ProductModel> mixline1Dynamic = <ProductModel>[].obs;
  RxList<ProductModel> mixline2Dynamic = <ProductModel>[].obs; //Most Demanded
  RxList<ProductModel> mostdeamandDynamic = <ProductModel>[].obs;
  RxList<ProductModel> newArrivalDynamic = <ProductModel>[].obs;
  RxList<ProductModel> fetchedTypeItem = <ProductModel>[].obs;

  void fetchOffersData(String vendorId, String type) async {
    resetDynamicLists(vendorId);
    // تأجيل تحديث حالة التحميل إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoading.value = true;
    });

    try {
      var fetchedItem = await productRepository.getProductsByType(
        vendorId,
        type,
      );

      // Filter out deleted products
      var filteredItems =
          fetchedItem.where((product) => !(product.isDeleted)).toList();

      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (type == 'offers') offerDynamic.value = filteredItems;
        if (type == 'all') allDynamic.value = filteredItems;
        if (type == 'all1') allLine1Dynamic.value = filteredItems;
        if (type == 'all2') allLine2Dynamic.value = filteredItems;
        if (type == 'all3') allLine3Dynamic.value = filteredItems;
        if (type == 'sales') salesDynamic.value = filteredItems;
        if (type == 'foryou') foryouDynamic.value = filteredItems;
        if (type == 'mixone') mixoneDynamic.value = filteredItems;
        if (type == 'mostdeamand') mixoneDynamic.value = filteredItems;
        if (type == 'mixlin1') mixline1Dynamic.value = filteredItems;
        if (type == 'mixlin2') mixline2Dynamic.value = filteredItems;
        if (type == 'newArrival') {
          newArrivalDynamic.value = filteredItems; //newArrival
        }
      });

      // تأجيل تحديث حالة التحميل إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
        // تأجيل تحديث حالة التحميل إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isLoading.value = false;
        });
      }
    }
  }

  Future<List<ProductModel>> fetchListData(String vendorId, String type) async {
    try {
      var fetchedItem = await productRepository.getProductsByTypeForVendor(
        vendorId,
        type,
      );

      // Filter out deleted products
      var filteredItems =
          fetchedItem.where((product) => !(product.isDeleted)).toList();

      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (type == 'offers') offerDynamic.value = filteredItems;
        if (type == 'all') allDynamic.value = filteredItems;
        if (type == 'all1') allLine1Dynamic.value = filteredItems;
        if (type == 'all2') allLine2Dynamic.value = filteredItems;
        if (type == 'sales') salesDynamic.value = filteredItems;
        if (type == 'foryou') foryouDynamic.value = filteredItems;
        if (type == 'mixone') mixoneDynamic.value = filteredItems;
        if (type == 'mostdeamand') mixoneDynamic.value = filteredItems;
        if (type == 'mixlin1') mixline1Dynamic.value = filteredItems;
        if (type == 'mixlin2') mixline2Dynamic.value = filteredItems;
        if (type == 'newArrival') {
          newArrivalDynamic.value = filteredItems; //newArrival
        }

        fetchedTypeItem.value = filteredItems;
      });

      return filteredItems;
    } catch (e) {
      if (kDebugMode) {
        print(e);
        // تأجيل تحديث حالة التحميل إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isLoading.value = false;
        });
        return [];
      }
    }
    return [];
  }

  Future<List<ProductModel>> fetchAllData(String vendorId) async {
    // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء

    allItems.value = [];

    try {
      var allProduct = await productRepository.getProducts(vendorId);

      // Filter out deleted products
      var filteredProducts =
          allProduct.where((product) => !(product.isDeleted)).toList();

      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allItems.assignAll(filteredProducts);
      });

      return filteredProducts;
    } catch (e) {
      if (kDebugMode) {
        print(e);
        return [];
      }
      return [];
    }
  }

  /// جلب جميع المنتجات بدون تحديد تاجر معين
  /// Fetch all products without vendor ID parameter
  Future<List<ProductModel>> fetchAllProductsWithoutVendor() async {
    try {
      // تأجيل تحديث حالة التحميل إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = true;
      });

      var allProduct = await productRepository.getAllProductsWithoutVendor();

      // Filter out deleted products
      var filteredProducts =
          allProduct.where((product) => !(product.isDeleted)).toList();

      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allItems.assignAll(filteredProducts);
        allDynamic.assignAll(filteredProducts);
        isLoading.value = false;
      });

      return filteredProducts;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في جلب جميع المنتجات: $e');
      }

      // تأجيل تحديث حالة التحميل إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });

      return [];
    }
  }

  RxList<XFile> selectedImage = <XFile>[].obs;
  RxString localThumbnail = ''.obs;

  RxString thumbnailUrl = ''.obs;
  var rotationAngle = 0.0.obs; // زاوية التدوير

  Future<List<XFile>> selectImages() async {
    List<XFile> list = [];

    list = await ImagePicker().pickMultiImage();

    if (list.isNotEmpty) {
      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedImage.addAll(list);
      });

      return list;
    }
    return [];
  }

  void updateRotation(double angle) {
    rotationAngle.value = angle;
  }

  var scaleFactor = 1.0.obs;
  void updateScale(double scale) {
    scaleFactor.value = scale;
  }

  Future<void> cropImage(String imagePath) async {
    if (imagePath == "") return;
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 600, ratioY: 800),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'product.image'.tr,
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'product.image'.tr),
      ],
    );
    if (croppedFile != null) {
      var i = selectedImage.indexWhere((img) => img.path == imagePath);
      selectedImage.removeWhere((img) => img.path == imagePath);

      selectedImage.insert(i, XFile(croppedFile.path));
    }
  }

  // وظيفة للتحقق من حجم الصورة وإظهار تنبيه إذا كانت كبيرة
  Future<bool> _checkImageSizeAndShowWarning(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      // إذا كان حجم الصورة أكبر من 5 ميجابايت
      if (fileSizeInMB > 5.0) {
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: Text(
              'product.warning_large_image'.tr,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'product.selected_image_size'.tr.replaceAll(
                    '{size}',
                    fileSizeInMB.toStringAsFixed(1),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'product.large_image_warning'.tr,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'product.compress_tip'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'common.cancel'.tr,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('common.continue'.tr),
              ),
            ],
          ),
        );

        return result ?? false;
      }

      return true; // إذا كان الحجم مقبول
    } catch (e) {
      print('Error checking image size: $e');
      return true; // في حالة الخطأ، نسمح بالصورة
    }
  }

  void takeCameraImages() async {
    var tackenImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (tackenImage != null) {
      // التحقق من حجم الصورة قبل الإضافة
      final shouldAddImage = await _checkImageSizeAndShowWarning(tackenImage);

      if (shouldAddImage) {
        selectedImage.add(tackenImage);
      }
    }
  }

  Future<void> uploadThumbnail() async {
    message.value = "uploading img";
    if (localThumbnail.value == "") return;
    File img = File(localThumbnail.value);
    if (kDebugMode) {
      print("================= befor ==upload category=======");
      print(img.path);
    }

    try {
      final result = await ImageUploadService.instance.uploadImage(
        imageFile: img,
        folderName: 'products',
      );

      if (result['success'] == true) {
        thumbnailUrl.value = result['url'] ?? '';
        if (kDebugMode) {
          print("uploading url===${thumbnailUrl.value}");
          message.value = "uploading url====${thumbnailUrl.value}";
        }
      } else {
        if (kDebugMode) {
          print("Upload failed: ${result['error']}");
        }
        message.value = "Upload failed: ${result['error']}";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Upload error: $e");
      }
      message.value = "Upload error: $e";
    }
    return;
  }

  Future<List<String>> uploadImages(List<XFile> localImages) async {
    try {
      List<String> uploadedUrls = [];
      if (localImages.isEmpty) return uploadedUrls;

      for (var image in localImages) {
        File img = File(image.path);

        final result = await ImageUploadService.instance.uploadImage(
          imageFile: img,
          folderName: 'products',
        );

        if (result['success'] == true) {
          final url = result['url'] ?? '';
          uploadedUrls.add(url);
          if (kDebugMode) {
            print("================= uploaded to Supabase ========== $url");
          }
        } else {
          if (kDebugMode) {
            print("Upload failed for image: ${result['error']}");
          }
        }
      }

      return uploadedUrls;
    } catch (e) {
      if (kDebugMode) {
        print("=========Exception while upload $e");
      }

      return [];
    }
  }

  String? calculateSalePresentage(double price, double? oldPrice) {
    if (oldPrice == null || oldPrice <= 0.0 || price <= 0.0) {
      return null;
    }
    double precentage = ((oldPrice - price) / oldPrice) * 100;
    return precentage.toStringAsFixed(0);
  }

  double? getSaleNumber(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0 || originalPrice <= 0.0) {
      return 0;
    }
    double precentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return precentage;
  }

  List<String> getAllProductImage(ProductModel product) {
    Set<String> images = {};
    if (product.thumbnail != '') images.add(product.thumbnail!);
    // selectedProductImage.value = product.thumbnail;
    images.addAll(product.images);
    return images.toList();
  }

  Future<void> finalDeleteProduct(
    ProductModel product,
    String vendorId,
    bool withBackAction,
  ) async {
    TLoader.progressSnackBar(
      title: 'common.delete'.tr,
      message: 'product.deleting'.tr,
    );
    await productRepository.deleteProduct(product.id);

    // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allItems.remove(product);
      var type = product.productType!;
      if (type == 'offers') offerDynamic.remove(product);
      if (type == 'all') allDynamic.remove(product);
      if (type == 'all1') allLine1Dynamic.remove(product);
      if (type == 'all2') allLine2Dynamic.remove(product);
      if (type == 'all3') allLine3Dynamic.remove(product);
      if (type == 'sales') salesDynamic.remove(product);
      if (type == 'foryou') foryouDynamic.remove(product);
      if (type == 'mixone') mixoneDynamic.remove(product);
      if (type == 'mixlin1') mixline1Dynamic.remove(product);
      if (type == 'mixlin2') mixline2Dynamic.remove(product);
      if (type == 'mostdeamand') mostdeamandDynamic.remove(product);
      if (type == 'newArrival') newArrivalDynamic.remove(product);
    });

    TLoader.stopProgress();
    if (withBackAction) {
      Navigator.pop(Get.context!);
    }

    TLoader.successSnackBar(
      title: 'common.success'.tr,
      message: 'product.data_deleted_successfully'.tr,
    );
  }

  /// Mark product as deleted (soft delete) for specific vendor
  Future<void> markProductAsDeleted(
    ProductModel product,
    String vendorId,
    bool withBackAction,
  ) async {
    try {
      TLoader.progressSnackBar(
        title: 'common.delete'.tr,
        message: 'product.deleting_product'.tr,
      );

      // Create updated product with isDeleted = true using copyWith
      final updatedProduct = product.copyWith(isDeleted: true);

      // Update product in Firestore
      await productRepository.updateProduct(updatedProduct);

      // Remove from local lists
      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allItems.remove(product);
        var type = product.productType!;
        if (type == 'offers') offerDynamic.remove(product);
        if (type == 'all') allDynamic.remove(product);
        if (type == 'all1') allLine1Dynamic.remove(product);
        if (type == 'all2') allLine2Dynamic.remove(product);
        if (type == 'all3') allLine3Dynamic.remove(product);
        if (type == 'sales') salesDynamic.remove(product);
        if (type == 'foryou') foryouDynamic.remove(product);
        if (type == 'mixone') mixoneDynamic.remove(product);
        if (type == 'mixlin1') mixline1Dynamic.remove(product);
        if (type == 'mixlin2') mixline2Dynamic.remove(product);
        if (type == 'mostdeamand') mostdeamandDynamic.remove(product);
        if (type == 'newArrival') newArrivalDynamic.remove(product);
      });

      TLoader.stopProgress();

      if (withBackAction) {
        Navigator.pop(Get.context!);
      }

      TLoader.successSnackBar(
        title: 'common.success'.tr,
        message: 'product.product_deleted_successfully'.tr,
      );
    } catch (e) {
      TLoader.stopProgress();
      TLoader.warningSnackBar(
        title: 'common.error'.tr,
        message: 'product.error_deleting_product'.tr.replaceAll(
          '{error}',
          e.toString(),
        ),
      );
    }
  }

  /// Restore deleted product (soft restore) for specific vendor
  Future<void> restoreDeletedProduct(
    ProductModel product,
    String vendorId,
    bool withBackAction,
  ) async {
    try {
      TLoader.progressSnackBar(
        title: "استرجاع",
        message: "جاري استرجاع المنتج",
      );

      // Create updated product with isDeleted = false using copyWith
      final updatedProduct = product.copyWith(isDeleted: false);

      // Update product in Firestore
      await productRepository.updateProduct(updatedProduct);

      // Add back to local lists
      // تأجيل تحديث القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allItems.add(updatedProduct);
        var type = product.productType!;
        if (type == 'offers') offerDynamic.add(updatedProduct);
        if (type == 'all') allDynamic.add(updatedProduct);
        if (type == 'all1') allLine1Dynamic.add(updatedProduct);
        if (type == 'all2') allLine2Dynamic.add(updatedProduct);
        if (type == 'all3') allLine3Dynamic.add(updatedProduct);
        if (type == 'sales') salesDynamic.add(updatedProduct);
        if (type == 'foryou') foryouDynamic.add(updatedProduct);
        if (type == 'mixone') mixoneDynamic.add(updatedProduct);
        if (type == 'mixlin1') mixline1Dynamic.add(updatedProduct);
        if (type == 'mixlin2') mixline2Dynamic.add(updatedProduct);
        if (type == 'mostdeamand') mostdeamandDynamic.add(updatedProduct);
        if (type == 'newArrival') newArrivalDynamic.add(updatedProduct);
      });

      TLoader.stopProgress();

      if (withBackAction) {
        Navigator.pop(Get.context!);
      }

      TLoader.successSnackBar(title: 'نجح', message: "تم استرجاع المنتج بنجاح");
    } catch (e) {
      TLoader.stopProgress();
      TLoader.warningSnackBar(
        title: 'خطأ',
        message: "حدث خطأ أثناء استرجاع المنتج: $e",
      );
    }
  }

  void updateList(ProductModel item) {
    var type = item.productType;

    if (type == 'offers') {
      final index = offerDynamic.indexWhere((i) => i == item);
      if (index != -1) offerDynamic[index] = item;
      offerDynamic.refresh();
    }
    if (type == 'all') {
      final index = allDynamic.indexWhere((i) => i == item);
      if (index != -1) allDynamic[index] = item;
      allDynamic.refresh();
    }
    if (type == 'all1') {
      final index = allLine1Dynamic.indexWhere((i) => i == item);
      if (index != -1) allLine1Dynamic[index] = item;
      allLine1Dynamic.refresh();
    }

    if (type == 'all2') {
      final index = allLine2Dynamic.indexWhere((i) => i == item);
      if (index != -1) allLine2Dynamic[index] = item;
      allLine2Dynamic.refresh();
    }

    if (type == 'all3') {
      final index = allLine3Dynamic.indexWhere((i) => i == item);
      if (index != -1) allLine3Dynamic[index] = item;
      allLine3Dynamic.refresh();
    }
    if (type == 'sales') {
      final index = salesDynamic.indexWhere((i) => i == item);
      if (index != -1) salesDynamic[index] = item;
      salesDynamic.refresh();
    }
    if (type == 'foryou') {
      final index = foryouDynamic.indexWhere((i) => i == item);
      if (index != -1) foryouDynamic[index] = item;
      foryouDynamic.refresh();
    }
    if (type == 'mixone') {
      final index = mixoneDynamic.indexWhere((i) => i == item);
      if (index != -1) mixoneDynamic[index] = item;
      mixoneDynamic.refresh();
    }
    if (type == 'mixline1') {
      final index = mixline1Dynamic.indexWhere((i) => i == item);
      if (index != -1) mixline1Dynamic[index] = item;
      mixline1Dynamic.refresh();
    }
    if (type == 'mixline2') {
      final index = mixline2Dynamic.indexWhere((i) => i == item);
      if (index != -1) mixline2Dynamic[index] = item;
      mixline2Dynamic.refresh();
    }
    if (type == 'mostdeamand') {
      final index = mostdeamandDynamic.indexWhere((i) => i == item);
      if (index != -1) mostdeamandDynamic[index] = item;
      mostdeamandDynamic.refresh();
    }
    if (type == 'newArrival') {
      final index = newArrivalDynamic.indexWhere((i) => i == item);
      if (index != -1) newArrivalDynamic[index] = item;
      newArrivalDynamic.refresh();
    }

    final index = allItems.indexWhere((i) => i == item);
    if (index != -1) allItems[index] = item;

    allItems.refresh();
  }
  //////////////////////

  var selectedCategory = Rx<CategoryModel?>(null);
  var isExpanded = false.obs;

  void selectCategory(CategoryModel category, String vendorId) async {
    if (selectedCategory.value == category && isExpanded.value) {
      isExpanded.value = false;
    } else {
      selectedCategory.value = category;
      await fetchProducts(category, vendorId);
      isExpanded.value = true;
    }
  }

  void closeList() {
    isExpanded.value = false;
  }

  final RxList<ProductModel> products = <ProductModel>[].obs;
  RxBool loadProduct = false.obs;
  Future<void> fetchProducts(CategoryModel category, String vendorId) async {
    loadProduct.value = true;

    try {
      var list = await //productRepository.getAllProducts(vendorId);
      CategoryController.instance.getCategoryProduct(
        categoryId: category.id!,
        userId: vendorId,
      );

      // Filter out deleted products
      var filteredList = list.where((product) => !(product.isDeleted)).toList();

      products.assignAll(filteredList);
    } catch (e) {
      print('Error fetching products: $e');
    }
    loadProduct.value = false;
  }

  void showProgressBar(String text) {
    Get.snackbar(
      text, // ,
      "",
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      backgroundColor: TColors.white,
      colorText: Colors.black,
      duration: Duration(days: 1),
      isDismissible: false,
      showProgressIndicator: true,
      padding: EdgeInsets.symmetric(horizontal: 50),
      progressIndicatorBackgroundColor: Colors.white,
    );
  }

  /// الحصول على منتج من خلال معرفه
  Future<ProductModel?> getProductById(String id) async {
    try {
      // البحث في القائمة المحلية أولاً
      final localProduct = allItems.firstWhereOrNull((p) => p.id == id);
      if (localProduct != null) {
        return localProduct;
      }

      // إذا لم يوجد محلياً، جلبه من قاعدة البيانات
      final product = await productRepository.getProductById(id);
      return product;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting product by ID: $e');
      }
      return null;
    }
  }

  var regularPrice = 0.0.obs;
  var discountPrice = Rxn<double>(); // يسمح بأن يكون فارغًا

  double? priceNumber;

  void validateDiscountPrice(String oldPrice) {
    double? enteredPrice = double.tryParse(oldPrice);
    if (enteredPrice != null) {
      if (enteredPrice <= regularPrice.value) {
        TLoader.warningSnackBar(
          title: '',
          message: "يجب أن يكون سعر البيع أقل  من السعر القديم",
        );
      } else {
        discountPrice.value = enteredPrice;
      }
    } else {
      Get.snackbar(
        "تنبيه",
        "الرجاء إدخال رقم صالح",
        snackPosition: SnackPosition.TOP,
        backgroundColor: TColors.white,
        colorText: Colors.black,
      );
    }
  }

  void changePrice(String value) {
    if (value.isEmpty) return;

    double? discountPercent = double.tryParse(value);
    if (discountPercent == null) return;

    if (discountPercent > 100) {
      TLoader.warningSnackBar(
        title: '',
        message: "sale_precentage_should_be_less_than_100".tr,
      );
      return;
    }
    if (oldPrice.text.isNotEmpty) {
      var originalPrice =
          double.tryParse(oldPrice.text.toString().replaceAll(",", '')) ?? 0.00;
      var salePrice =
          (originalPrice - (originalPrice * (discountPercent / 100)));
      price.text = salePrice.toString();
    }
  }

  void changeSalePresentage(String value) {
    if (kDebugMode) {
      print("===========value is ====$value");
    }

    // حساب سعر البيع عند تغيير السعر الأصلي
    if (saleprecentage.text.isNotEmpty && value.isNotEmpty) {
      double? originalPrice = double.tryParse(value);
      double? discountPercent = double.tryParse(saleprecentage.text);

      if (originalPrice != null && discountPercent != null) {
        var salePrice =
            originalPrice - (originalPrice * (discountPercent / 100));
        // إزالة الفواصل العشرية غير الضرورية
        if (salePrice == salePrice.toInt()) {
          price.text = salePrice.toInt().toString();
        } else {
          price.text = salePrice.toStringAsFixed(2);
        }
      }
    }
  }

  String lastVendor = "";
  void resetDynamicLists(String vendorId) {
    if (vendorId != lastVendor) {
      print(
        "🔄 Vendor changed from $lastVendor to $vendorId, clearing product data...",
      );

      // تأجيل تنظيف القوائم إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // تنظيف جميع القوائم الديناميكية
        offerDynamic.clear();
        allDynamic.clear();
        allLine1Dynamic.clear();
        allLine2Dynamic.clear();
        allLine3Dynamic.clear();
        salesDynamic.clear();
        mixoneDynamic.clear();
        foryouDynamic.clear();
        mixline1Dynamic.clear();
        mixline2Dynamic.clear();
        mostdeamandDynamic.clear();
        newArrivalDynamic.clear();

        // تنظيف البيانات المرتبطة بالتاجر
        allItems.clear();
        products.clear();
        selectedCategory.value = null;
        isExpanded.value = false;
        loadProduct.value = false;

        print("✅ Product data cleared for new vendor: $vendorId");
      });

      lastVendor = vendorId;
    }
  }
}
