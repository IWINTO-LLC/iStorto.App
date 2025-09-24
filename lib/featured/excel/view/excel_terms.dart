// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';

// import 'package:istoreto/featured/custom_Excel_menu/screen/excel_product_menu.dart';
// import 'package:istoreto/featured/excel/controller/excel_controller.dart';
// import 'package:istoreto/featured/excel/view/widgets/expanded_cell.dart';

// import 'package:istoreto/utils/common/styles/styles.dart';
// import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
// import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
// import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
// import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
// import 'package:istoreto/utils/constants/color.dart';

// class ImportExcelPage extends StatelessWidget {
//   var controller = Get.put(ExcelController());
//   final String vendorId;

//   ImportExcelPage({super.key, required this.vendorId});
//   @override
//   Widget build(BuildContext context) {
//     controller.fetchTemporaryData(vendorId);
//     return Scaffold(
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Obx(
//             () => Visibility(
//               visible: controller.products.isNotEmpty,
//               child: FloatingActionButton(
//                 backgroundColor: Colors.black,
//                 child: const Icon(Icons.settings),
//                 onPressed:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (context) => ProductManageExelTempBulkMenu(
//                               initialList: controller.products,
//                               vendorId: vendorId,
//                             ),
//                       ),
//                     ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           FloatingActionButton(
//             backgroundColor: Colors.black,
//             child: const Icon(Icons.refresh),
//             onPressed: () => controller.refreshData(vendorId),
//           ),
//         ],
//       ),
//       appBar: CustomAppBar(title: 'importDataFromExcel'.tr),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: 80.w,
//                       child: Text(
//                         'excel.term1'.tr,
//                         style: titilliumSemiBold.copyWith(height: 1.5),
//                         maxLines: 3,
//                         textAlign: TextAlign.justify,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     CustomButtonBlack(
//                       width: 200,
//                       onTap: () {
//                         controller.generateExcelTemplate();
//                       },
//                       text: 'تنزيل ملف Excel',
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: 80.w,
//                       child: Text(
//                         'excel.term2'.tr,
//                         style: titilliumSemiBold.copyWith(height: 1.5),
//                         maxLines: 3,
//                         textAlign: TextAlign.justify,
//                       ),
//                     ),

//                     const SizedBox(height: 16),
//                     CustomButtonBlack(
//                       onTap: () {
//                         controller.pickFile(vendorId);
//                       },
//                       text: 'رفع ملف Excel',
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: 80.w,
//                       child: Text(
//                         ' اضغط على زر ادارة القائمة ان اردت التعديل قبل تفعيل المنتجات',
//                         maxLines: 3,
//                         textAlign: TextAlign.justify,
//                         style: titilliumSemiBold.copyWith(height: 1.5),
//                       ),
//                     ),
//                     // Obx(() => controller.filePath.value.isNotEmpty
//                     //     ? Column(
//                     //         children: [
//                     //           Text('Saved To :  '),
//                     //           Text('✅  ${controller.filePath.value}'),
//                     //         ],
//                     //       )
//                     //     : const SizedBox.shrink()),
//                     const SizedBox(height: 20),
//                     //        const SizedBox(
//                     //   height: 30,
//                     // ),
//                   ],
//                 ),
//               ),
//               Obx(
//                 () => Visibility(
//                   visible: true,
//                   child: Padding(
//                     padding: const EdgeInsets.all(14.0),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: DataTable(
//                           border: TableBorder.all(color: Colors.blue, width: 1),
//                           columns: [
//                             DataColumn(
//                               label: Row(children: [buildCell('title'.tr)]),
//                             ),
//                             DataColumn(
//                               label: Row(
//                                 children: [buildCell('description'.tr)],
//                               ),
//                             ),
//                             DataColumn(
//                               label: Row(children: [buildCell("salePrice".tr)]),
//                             ),
//                             DataColumn(
//                               label: Row(children: [buildCell("actegory".tr)]),
//                             ),
//                             DataColumn(
//                               label: Row(children: [buildCell("Images".tr)]),
//                             ),
//                           ],
//                           rows: List.generate(controller.products.length, (
//                             index,
//                           ) {
//                             var product = controller.products[index];
//                             return DataRow(
//                               cells: [
//                                 DataCell(
//                                   TextFormField(
//                                     style: titilliumRegular.copyWith(
//                                       fontSize: 14,
//                                     ),
//                                     initialValue: product.title ?? '',
//                                   ),
//                                 ),
//                                 DataCell(
//                                   AutoResizeTextField(
//                                     initialText: product.description ?? '',
//                                     onChanged: (value) {},
//                                   ),
//                                 ),
//                                 DataCell(
//                                   TCustomWidgets.formattedPrice(
//                                     product.price,
//                                     14,
//                                     TColors.primary,
//                                   ),
//                                 ),
//                                 DataCell(
//                                   TextFormField(
//                                     style: titilliumRegular.copyWith(
//                                       fontSize: 14,
//                                     ),
//                                     initialValue:
//                                         product.category?.title.toString(),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   TextFormField(
//                                     style: titilliumRegular.copyWith(
//                                       fontSize: 14,
//                                     ),
//                                     initialValue: product.images!.join(', '),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Text buildCell(String cell) {
//     return Text(cell, style: titilliumRegular.copyWith(fontSize: 12));
//   }
// }
