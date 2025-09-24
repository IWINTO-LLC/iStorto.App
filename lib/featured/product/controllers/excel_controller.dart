// import 'dart:io';

//
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart';
//
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:istoreto/data/models/category_model.dart';
// import 'package:istoreto/featured/product/data/product_model.dart';
// import 'package:istoreto/featured/product/data/product_repository.dart';

// class ExcelController extends GetxController {
//   var filePath = ''.obs;
//   var excelData = <List<dynamic>>[].obs;

//   String vendorId = FirebaseAuth.instance.currentUser!.uid;
//   void onInit() {
//     fetchtempProduct();
//     super.onInit();
//   }

//   // Fetch saved products list from Firebase
//   void fetchtempProduct() async {
//     var snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(vendorId)
//         .collection('temp_products_$vendorId')
//         .get();
//     products.value =
//         snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
//   }

//   Future<void> downloadExcelFile() async {
//     var excel = Excel.createExcel();
//     var sheet = excel['Sheet1'];

//     // إضافة رأس الجدول
//     // sheet.appendRow([
//     //   'الاسم العربي',
//     //   'الوصف العربي',
//     //   'English Name',
//     //   'English Description',
//     //   'السعر',
//     //   'سعر التخفيض',
//     //   'الفئة',
//     //   'الصور'
//     // ]);

//     // إعداد قائمة الفئات المتاحة
//     var categories = ['إلكترونيات', 'ملابس', 'أثاث', 'أغذية'];

//     // تحديد نطاق البيانات المستخدمة في القائمة المنسدلة
//     // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value = 'اختر فئة';
//     // sheet.dataValidation(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1),
//     //     DataValidation(
//     //       allowList: categories,
//     //       showDropDown: true,
//     //       inputMessage: 'اختر الفئة المناسبة للمنتج',
//     //       errorMessage: 'القيمة غير صحيحة، الرجاء اختيار فئة من القائمة',
//     //     ));

//     // مثال لإضافة بيانات منتج
//     // sheet.appendRow([
//     //   'هاتف ذكي',
//     //   'هاتف ذكي متطور بكاميرا عالية الدقة',
//     //   'Smartphone',
//     //   'Advanced smartphone with high-resolution camera',
//     //   '1000',
//     //   '900',
//     //   'إلكترونيات',
//     //   'image1.jpg,image2.jpg,image3.jpg'
//     // ]);

//     // حفظ الملف
//     var fileBytes = excel.save();
//     if (fileBytes != null) {
//       File('products.xlsx')
//         ..createSync(recursive: true)
//         ..writeAsBytesSync(fileBytes);
//       print('تم إنشاء ملف Excel بنجاح!');
//     }
// //     try {

// //        var status = await Permission.storage.request();
// //   if (status.isGranted) {
// //     print("تم منح الإذن للوصول إلى الملفات!");
// //   } else {
// //     print("الإذن مرفوض، يرجى تفعيله يدويًا.");
// //   }
// //       // ✅ 1. قراءة ملف Excel من `assets`
// //       ByteData data = await rootBundle.load('assets/template.xlsx');
// //       List<int> bytes = data.buffer.asUint8List();
// // //assets\template.xlsx
// //       // ✅ 2. حفظ الملف محليًا في مجلد المستندات
// //       final directory = await getApplicationDocumentsDirectory();
// //       final file = File('${directory.path}/template.xlsx');
// //       await file.writeAsBytes(bytes);

// //       // ✅ 3. تحديث المسار حتى يمكن عرضه للمستخدم
// //       filePath.value = file.path;

// //       Get.snackbar("نجاح", "تم تحميل نموذج Excel بنجاح!");
// //     } catch (e) {
// //       Get.snackbar("خطأ", "حدث خطأ أثناء تحميل الملف!");
// //     }
//   }

//   final RxList<ProductModel> products = <ProductModel>[].obs;
//   void pickFile(String vendorId) async {
//     if (kDebugMode) {
//       print("===================vendorid$vendorId");
//     }
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx', 'xls'],
//     );

//     if (result != null) {
//       filePath.value = result.files.single.path!;
//       _readExcel(File(filePath.value), vendorId);
//     }
//   }

//   void _readExcel(File file, String vendorId) async {
//     var bytes = file.readAsBytesSync();
//     var excel = Excel.decodeBytes(bytes);
//     var sheet = excel.tables[excel.tables.keys.first];

//     if (sheet != null) {
//       for (var row in sheet.rows) {
//         excelData.add(row.map((cell) => cell?.value ?? "").toList());

//         var title = row[0]?.value.toString();
//         var description = row[1]?.value.toString();
//         var arabicTitle = row[2]?.value.toString();
//         var arabicDescription = row[3]?.value.toString();
//         var price = row[4]?.value.toString();
//         var salePrice = row[5]?.value.toString();
//         var item = ProductModel(
//             id: '',
//             title: title!,
//             arabicTitle: arabicTitle!,
//             price: double.parse(price.toString()),
//             oldPrice: double.parse(salePrice.toString()),
//             isFeature: true,
//             //category: CategoryModel(name: 'Excel', arabicName: 'Excel'),
//             images: [],
//             productType: 'all',
//             thumbnail: '',
//             description: description!,
//             arabicDescription: arabicDescription!,
//             vendorId: vendorId);
//         products.add(item);
//       }
//       storeTemporaryData(products, vendorId);
//       print('temp data 9999999999999 length${products.length}');
//       fetchTemporaryData(vendorId);
//     }
//   }

//   void refreshData(String vendorId) {
//     fetchTemporaryData(vendorId);
//   }

//   Future<void> storeTemporaryData(
//       List<ProductModel> data, String vendorId) async {
//     for (var item in data) {
//       await ProductRepository.instance.addProductToTemps(item, vendorId);
//     }
//   }

//   var sortColumn = ''.obs;
//   var sortAscending = true.obs;

//   void sortData(String column) {
//     //  var items = <ProductModel>[].obs;
//     //  items.value=products;
//     if (sortColumn.value == column) {
//       sortAscending.value = !sortAscending.value; // تبديل الترتيب
//     } else {
//       sortColumn.value = column;
//       sortAscending.value = true; // عند تحديد عمود جديد، يبدأ بتصاعدي
//     }

//     products.sort((a, b) {
//       var aValue = a.toJson()[column];
//       var bValue = b.toJson()[column];
//       return sortAscending.value
//           ? aValue.compareTo(bValue)
//           : bValue.compareTo(aValue);
//     });

//     products.refresh();
//   }

//   void fetchTemporaryData(String vendorId) async {
//     var snapshot =
//         await ProductRepository.instance.getAllTempProducts(vendorId);
//     products.value = snapshot;
//   }

//   void updateItem(int index, String field, String value) {
//     var product = products[index];
//     if (field == "title") product.title = value;
//     if (field == "arabicTitle") product.arabicTitle = value;
//     if (field == "price") product.price = double.parse(value);
//     if (field == "salePrice") product.oldPrice = double.parse(value);
//     if (field == "description") product.description = value;
//     if (field == "arabicDescription") product.arabicDescription = value;
//     products.refresh();
//   }

//   Future<void> saveChanges() async {
//     for (var product in products) {
//       await FirebaseFirestore.instance
//           .collection('excel_temp_data')
//           .doc(product.id)
//           .update(product.toJson());
//     }
//   }
// }
