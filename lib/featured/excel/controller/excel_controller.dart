// import 'package:get/get.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:istoreto/controllers/category_controller.dart';
// import 'package:istoreto/data/models/category_model.dart';
// import 'dart:io';
// import 'package:open_file/open_file.dart';

// import 'package:istoreto/featured/product/data/product_model.dart';
// import 'package:istoreto/featured/product/data/product_repository.dart';
// import 'package:istoreto/utils/loader/loaders.dart';

// class ExcelController extends GetxController {
//   var filePath = ''.obs;
//   var excelData = <List<dynamic>>[].obs;
//   final RxList<ProductModel> products = <ProductModel>[].obs;

//   Future<void> generateExcelTemplate() async {
//     final excel = Excel.createExcel(); // إنشاء مصنف جديد
//     final sheet = excel['sheet1']; // اسم الورقة
//     sheet.appendRow(['Title', 'Description', 'price', 'Category', 'Images']);

//     // حفظ الملف
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/iwinto-excel.xlsx';
//     final fileBytes = excel.encode();
//     if (fileBytes != null) {
//       final file =
//           File(filePath)
//             ..createSync(recursive: true)
//             ..writeAsBytesSync(fileBytes);
//       TLoader.successSnackBar(message: 'تم إنشاء الملف: $filePath', title: "");
//       await OpenFile.open(filePath);
//     }
//   }

//   // Fetch saved products list from Firebase

//   void pickFile(String vendorId) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx'],
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
//         var price = row[2]?.value.toString();
//         var categoryName = row[3]?.value.toString().trim();
//         var imagesCell = row[4]?.value.toString().trim() ?? "";
//         var category = CategoryController.instance.allItems.firstWhere(
//           (cat) => cat.name == categoryName,
//           orElse: () => CategoryModel.empty(),
//         );
//         List<String> images =
//             imagesCell.split(',').map((e) => e.trim()).toList();

//         products.add(
//           ProductModel(
//             id: '',
//             title: title ?? '',
//             description: description ?? '',
//             price: double.tryParse(price ?? '0') ?? 0.0,
//             oldPrice: double.tryParse(price ?? '0') ?? 0.0,
//             category: category,
//             images: images,
//             vendorId: vendorId,
//           ),
//         );
//       }
//       storeTempProducts(vendorId);
//     }
//   }

//   void storeTempProducts(String userId) {
//     for (var product in products) {
//       ProductRepository.instance.addProductToTemps(product, userId);
//     }
//   }

//   Future<void> saveChanges() async {
//     for (var product in products) {
//       await FirebaseFirestore.instance
//           .collection('excel_temp_data')
//           .doc(product.id)
//           .update(product.toJson());
//     }
//   }

//   Future<void> fetchTemporaryData(String vendorId) async {
//     var list = await ProductRepository.instance.getAllTempProduct(vendorId);
//     products.value = list;
//   }

//   void refreshData(String vendorId) {
//     fetchTemporaryData(vendorId);
//   }

//   void updateItem(int index, String field, String value) {
//     var product = products[index];
//     if (field == "title") product.title = value;
//     if (field == "price") product.price = double.tryParse(value) ?? 0.0;
//     if (field == "description") product.description = value;
//     products.refresh();
//   }
// }
