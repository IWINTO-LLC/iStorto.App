import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/data/models/upload_result.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/custom_Excel_menu/controller/bulk_excel_product_control.dart';

import 'package:istoreto/utils/loader/loaders.dart';
import 'package:istoreto/utils/upload.dart';

class EditProductController extends GetxController {
  static EditProductController get instance => Get.find();

  // Media path for uploads
  final String mediaPath = 'https://iwinto.cloud/uploads/';

  @override
  void onInit() {
    super.onInit();
    ever(selectedImage, (_) => update()); // تحديث عند تغيير الصور
    ever(initialImage, (_) => update()); // تحديث عند تغيير الصور
  }

  // Upload media to server
  Future<UploadResult> uploadMediaToServer(File file) async {
    return await UploadService.instance.uploadMediaToServer(file);
  }

  void removeInitialImage(int index) {
    initialImage.removeAt(index);
    update();
  }

  void removeSelectedImage(int index) {
    selectedImage.removeAt(index);
    update();
  }

  //Variables
  final isLoading = false.obs;
  final productRepository = Get.put(ProductRepository());
  // final skuCode = TextEditingController();
  final title = TextEditingController();
  final arabicTitle = TextEditingController();
  String t = "";
  String a = "";
  final description = TextEditingController();
  final arabicDescription = TextEditingController();
  final minQuantityController = TextEditingController(text: '1');
  final price = TextEditingController();
  final oldPrice = TextEditingController();
  var salePrice = 00.0.obs;
  final saleprecentage = TextEditingController();
  final categoryTextField = TextEditingController();
  final formKey = GlobalKey<FormState>();
  CategoryModel category = CategoryModel.empty();
  RxList<String> images = <String>[].obs;
  RxList<String> initialImage = <String>[].obs;
  RxString message = ''.obs;
  Rx<CategoryModel> selectedCategory = CategoryModel.empty().obs;
  String oldthumb = '';
  String type = '';
  List<String> oldExtraImages = [];
  RxList<XFile> selectedImage = <XFile>[].obs;
  RxString localThumbnail = ''.obs;

  RxString thumbnailUrl = ''.obs;
  void takeCameraImages() async {
    var tackenImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (tackenImage != null) {
      selectedImage.add(tackenImage);
      update(['images']);
    }
  }

  Future<void> cropImage(String imagePath) async {
    //  int index = selectedImage.indexWhere((image) => image.path == imagePath);
    // if (index != -1) {
    //   selectedImage[index] =
    //       cropactionImage(imagePath) as XFile; // استبدال الصورة بعد القص

    // }
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 600, ratioY: 800),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'product_image'.tr,
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
      update(['images']);
    }
  }

  void initTemp(ProductModel product) {
    resetFields();
    if (kDebugMode) {
      print('=========id========== [38;5;2m${product.id} [0m');
    }
    localThumbnail.value = "";
    title.text = product.title;
    description.text = product.description ?? '';
    images.value = product.images;

    // تنسيق السعر القديم
    if (product.oldPrice != null) {
      oldPrice.text = product.oldPrice!.toStringAsFixed(2);
    } else {
      oldPrice.text = "";
    }

    // تنسيق السعر الحالي
    price.text = product.price.toStringAsFixed(2);

    if (product.category != null && product.category != CategoryModel.empty()) {
      selectedCategory.value =
          CategoryController.instance.allItems
              .where((c) => c.id == product.category?.id!)
              .single;
      categoryTextField.text = selectedCategory.value.title;
    }
  }

  void init(ProductModel product) {
    resetFields();
    if (kDebugMode) {
      print('=========id========== [38;5;2m${product.id} [0m');
    }
    localThumbnail.value = "";
    title.text = product.title;
    description.text = product.description ?? '';
    initialImage.value = product.images;

    // تنسيق السعر بشكل صحيح مع تقليل الكسور العشرية
    double convertedPrice = CurrencyController.instance
        .convertToDefaultCurrency(product.price);
    price.text = convertedPrice.toStringAsFixed(2);

    // تنسيق السعر القديم
    if (product.oldPrice != null) {
      double convertedOldPrice = CurrencyController.instance
          .convertToDefaultCurrency(product.oldPrice!);
      oldPrice.text = convertedOldPrice.toStringAsFixed(2);
    } else {
      oldPrice.text = convertedPrice.toStringAsFixed(2);
    }

    images.value = product.images;
    minQuantityController.text = product.minQuantity.toString();

    // البحث عن الفئة باستخدام categoryId
    if (product.category != null && product.category != CategoryModel.empty()) {
      selectedCategory.value = CategoryController.instance.allItems.firstWhere(
        (c) => c.id == product.category?.id,
        orElse: () => CategoryModel.empty(),
      );
      categoryTextField.text = selectedCategory.value.title;
    }

    oldExtraImages.assignAll(product.images);
  }

  void resetFields() {
    isLoading(false);
    selectedImage.clear(); // إزالة جميع العناصر من القائمة
    initialImage.clear();

    title.clear();
    arabicTitle.clear();
    description.clear();
    arabicDescription.clear();
    price.text = '0';
    oldPrice.text = '';
    selectedImage.clear();
    selectedImage.value = [];
    initialImage.value = [];
    thumbnailUrl.value = "";
    localThumbnail.value = "";
    minQuantityController.text = '1';
    update();
  }

  Future<void> updateProduct(
    ProductModel product,
    String vendorId,
    bool isTemp, {
    int minQuantity = 1,
  }) async {
    var index = -1;
    if (isTemp) {
      index = ProductControllerExcel().products.indexOf(product);
    }
    product.images = initialImage;
    var oldimages = initialImage.length;
    var salePriceNumber = double.parse(
      price.text.replaceAll(RegExp(r'[,.]'), ''),
    );
    print("===========salePriceNumber is ====$salePriceNumber");
    var oldPriceNumber =
        double.tryParse(oldPrice.text.replaceAll(RegExp(r'[,.]'), '')) ?? 0.00;
    print("===========oldPriceNumber is ====$oldPriceNumber");

    if (title.text.isEmpty) {
      TLoader.warningSnackBar(
        title: '',
        message:
            Get.locale?.languageCode == 'ar'
                ? "الرجاء إدخال اسم العنصر "
                : "Please add a title",
      );
      return;
    } else if (!formKey.currentState!.validate()) {
      isLoading.value = false;
      return;
    } else if (selectedImage.isEmpty && oldimages < 1) {
      TLoader.warningSnackBar(
        title: '',
        message:
            Get.locale?.languageCode == 'ar'
                ? "يرجى ادخال صورة على الأقل"
                : "Please add at least one photo",
      );
      return;
    } else if (selectedCategory.value == CategoryModel.empty()) {
      isLoading.value = false;
      TLoader.warningSnackBar(
        title: '',
        message:
            Get.locale?.languageCode == 'ar'
                ? "يرجى اختيار تصنيف "
                : "Please select a category",
      );
      return;
    } else if (oldPriceNumber < salePriceNumber && oldPriceNumber > 0.00) {
      TLoader.warningSnackBar(
        title: '',
        message:
            Get.locale?.languageCode == 'ar'
                ? "سعر البيع يجب ان يكون أقل من السعر"
                : "Sale price should be less than Price",
      );
      return;
    } else {
      showProgressBar(
        Get.locale?.languageCode == 'ar' ? "جاري الحفظ..." : "Saving Now ..",
      );
      List<String> s3 = await uploadImages(selectedImage);
      final allImages = [...initialImage, ...s3];
      product.images = allImages;
      product.title = title.text.trim();
      product.productType = type;
      product.price = salePriceNumber;
      product.oldPrice = oldPriceNumber;
      product.description = description.text.trim();
      product.isFeature = true;
      product.category = selectedCategory.value;
      product.minQuantity = int.tryParse(minQuantityController.text) ?? 1;
      try {
        isTemp
            ? await productRepository.updateProduct(product)
            : await productRepository.updateProduct(product);
        TLoader.stopProgress();
        resetFields();
        update();
        Navigator.pop(Get.context!);
      } catch (e) {
        TLoader.stopProgress();
        throw 'some thing go wrong while update product';
      }
      TLoader.successSnackBar(
        title: 'Successfull',
        message: "data updated successfully",
      );
      Navigator.of(Get.context!).pop();
    }
    if (isTemp) {
      ProductControllerExcel().products[index] = product;
    } else {}
  }

  void showProgressBar(String text) {
    Get.snackbar(
      "", // عنوان فارغ
      text, // النص في المحتوى
      snackPosition: SnackPosition.BOTTOM,

      margin: EdgeInsets.only(bottom: 20, left: 40, right: 40),
      backgroundColor: Colors.black.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 90),
      isDismissible: false,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white.withOpacity(0.3),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      // padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      borderRadius: 25,
      barBlur: 10,
      overlayBlur: 0.5,
    );
  }

  Future<void> pickImage() async {
    var pickedFile = (await ImagePicker().pickImage(
      source: ImageSource.gallery,
    ));

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Product Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Edit Product Image',
            // Locks aspect ratio
          ),
        ],
      );
      File img = File(croppedFile!.path);

      localThumbnail.value = img.path;
    }
  }

  Future<List<XFile>> selectImages() async {
    List<XFile> list = [];

    list = await ImagePicker().pickMultiImage();

    if (list.isNotEmpty) {
      selectedImage.addAll(list);
      update(['images']);
      return list;
    }
    return [];
  }

  var regularPrice = 0.0.obs;
  var discountPrice = Rxn<double>(); // يسمح بأن يكون فارغًا

  Future<void> uploadThumbnail() async {
    message.value = "uploading thumbnail";
    if (localThumbnail.value == "") return;
    File img = File(localThumbnail.value);
    if (kDebugMode) {
      print("================= befor ==upload category=======");
      print(img.path);
    }
    UploadResult s1 = await UploadService.instance.uploadMediaToServer(img);
    var s = s1.fileUrl;
    thumbnailUrl.value = "$mediaPath$s";
    if (kDebugMode) {
      print("uploading url===${thumbnailUrl.value}");
      message.value = "uploading thumb done";
    }
    return;
  }

  Future<List<String>> uploadImages(List<XFile> localImages) async {
    try {
      List<String> s3 = [];
      if (localImages == []) return s3;
      for (var image in localImages) {
        File img = File(image.path);

        UploadResult s = await uploadMediaToServer(img);

        s3.add("$mediaPath${s.fileUrl}");
        print("uploaded images: $mediaPath${s.fileUrl}");

        if (kDebugMode) {
          print(
            "================= uploaded= compressed ========== $mediaPath${s.fileUrl}",
          );
        }
      }

      return s3;
    } catch (e) {
      if (kDebugMode) {
        print("=========Exception while upload $e");
      }

      return [];
    }
  }

  // final NumberFormat formatter = NumberFormat("#,##0", "en_US");
  double? priceNumber;

  void changePrice(String value) {
    if (value.isEmpty) return;

    double? discountPercent = double.tryParse(value);
    if (discountPercent == null) return;

    if (discountPercent > 100) {
      TLoader.warningSnackBar(
        title: '',
        message:
            Get.locale?.languageCode == 'ar'
                ? "نسبة الادخال الصحيحة اقل من 100"
                : "Sale precentage should be less than 100",
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
}
