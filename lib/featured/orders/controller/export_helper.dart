import 'dart:io';

//import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  static Future<void> exportOrderDetailsAsPDF(
    OrderModel order,
    BuildContext context,
  ) async {
    loadingMethod(context);
    final pdf = pw.Document();

    // تحميل الخط العربي
    final fontData = await rootBundle.load("assets/fonts/naskh.ttf");
    final ttfFont = pw.Font.ttf(fontData);

    // صورةالعميل
    final response = await http.get(Uri.parse(order.buyerId));
    final buyerImage = pw.MemoryImage(response.bodyBytes);

    final titleStyle = pw.TextStyle(font: ttfFont, fontSize: 14);
    final boldStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );
    final appLogoBytes = await rootBundle.load("assets/images/wintoword.png");

    final appLogo = pw.MemoryImage(appLogoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        build:
            (context) => [
              pw.Align(
                alignment: pw.Alignment.topLeft,
                child: pw.Image(appLogo, width: 65, height: 40),
                //  pw.Text('Powered by iwinto')
              ),
              pw.SizedBox(height: 12),

              // 🏷️ عنوان الصفحة
              pw.Center(
                child: pw.Text(
                  "odred_details".tr,
                  style: pw.TextStyle(
                    font: ttfFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // رقم الطلب + الحالة
              pw.Text("${'order_number'.tr}: ${order.id}", style: boldStyle),
              pw.Text(
                "${'status'.tr}: ${OrderController.instance.getOrderState(order)}",
                style: boldStyle.copyWith(color: PdfColors.deepPurple),
              ),
              pw.Divider(),

              // 📷 بيانات الزبون
              pw.Row(
                children: [
                  pw.ClipOval(
                    child: pw.Image(buyerImage, width: 40, height: 40),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(order.buyerDetails.name, style: titleStyle),
                      pw.Text(order.phoneNumber!, style: titleStyle),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // 🏠 العنوان والموقع
              pw.Text(
                "${'Address'.tr}: ${order.fullAddress}",
                style: titleStyle,
              ),
              pw.Text(
                "${'Building'.tr}: ${order.buildingNumber}",
                style: titleStyle,
              ),
              pw.SizedBox(height: 8),
              if (order.locationLat != null)
                pw.Text('Location map included'.tr, style: titleStyle),

              pw.Divider(),

              // 📦 المنتجات
              pw.Text("Products:".tr, style: boldStyle),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // اسم المنتج
                  1: const pw.FlexColumnWidth(1.2), // العدد
                  2: const pw.FlexColumnWidth(1.5), // سعر الوحدة
                  3: const pw.FlexColumnWidth(1.7), // الإجمالي
                },
                children: [
                  // عنوان الصف
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Product".tr,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Qty".tr,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Unit Price".tr,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Total".tr,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  // صفوف البيانات
                  ...order.productList.map((item) {
                    final title = ProductController.getTitleString(
                      item.product,
                    );
                    final qty = item.quantity;
                    final price = item.product.price;
                    final unit = TCustomWidgets.getPrice(price);
                    final total = TCustomWidgets.getPrice(qty * price);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            title,
                            style: titleStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            qty.toString(),
                            style: titleStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            unit,
                            style: titleStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            total,
                            style: titleStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 8),
              //pw.Divider(),

              // ⏱️ التاريخ والسعر
              pw.Text(
                "${'OrderDate'.tr}: ${order.orderDate.toLocal()}",
                style: titleStyle,
              ),
              pw.Text(
                "${'TotalPrice'.tr}: ${TCustomWidgets.getPrice(order.totalPrice)}",
                style: boldStyle.copyWith(color: PdfColors.green800),
              ),
            ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/order_${order.id}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "تفاصيل الطلب رقم ${order.id}");
    Navigator.pop(context);
  }

  static Future<void> exportAsPDF(
    List<OrderModel> orders,
    VendorModel vendor,
    BuildContext context,
  ) async {
    loadingMethod(context);
    var image = vendor.organizationLogo;
    var name = vendor.organizationName;
    final pdf = pw.Document();

    // 🧵 تحميل الخط العربي
    final fontData = await rootBundle.load("assets/fonts/naskh.ttf");
    final ttfFont = pw.Font.ttf(fontData);

    // تحميل صورة اللوغو من الأصول (PNG أو JPG)
    final appLogoBytes = await rootBundle.load("assets/images/wintoword.png");

    final appLogo = pw.MemoryImage(appLogoBytes.buffer.asUint8List());

    // 🌐 تحميل شعار التاجر من URL
    final vendorResponse = await http.get(Uri.parse(image));
    final vendorLogo = pw.MemoryImage(vendorResponse.bodyBytes);

    // 📝 بناء صفحة التقرير
    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        build:
            (context) => [
              // 🎯 الشعارات
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.ClipOval(
                        child: pw.Image(vendorLogo, width: 60, height: 60),
                      ),
                      pw.Text(name),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Image(appLogo, width: 65, height: 40),
                      //  pw.Text('Powered by iwinto')
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // 🏷️ عنوان التقرير
              pw.Center(
                child: pw.Text(
                  'order.report'.tr,
                  style: pw.TextStyle(
                    font: ttfFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // 📋 جدول الطلبات
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1), // رقم الطلب
                  1: const pw.FlexColumnWidth(2), // اسم الزبون ← توسيعه
                  2: const pw.FlexColumnWidth(1.5), // السعر ← توسيعه قليلًا
                  3: const pw.FlexColumnWidth(1), // الحالة
                  4: const pw.FlexColumnWidth(1.5), // التاريخ
                },
                children: [
                  // 🔘 رأس الجدول (كما في المثال السابق)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'order.num'.tr,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'order.clientName'.tr,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'order.amount'.tr,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'order.state'.tr,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'order.date'.tr,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  // 📝 صفوف البيانات
                  ...orders.map((order) {
                    final state = OrderController.instance.getOrderState(order);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            order.id ?? '',
                            style: pw.TextStyle(font: ttfFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            order.buyerDetails.name,
                            style: pw.TextStyle(font: ttfFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            TCustomWidgets.getPrice(order.totalPrice),
                            style: pw.TextStyle(font: ttfFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            state,
                            style: pw.TextStyle(font: ttfFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            order.orderDate.toLocal().toString().split('.')[0],
                            style: pw.TextStyle(font: ttfFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
      ),
    );

    // 💾 حفظ الملف
    final fileBytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/orders_report.pdf');
    await file.writeAsBytes(fileBytes);

    // 🔗 مشاركة الملف
    await Share.shareXFiles([XFile(file.path)], text: 'order.pdfHint'.tr);
    Navigator.pop(context);
  }

  static void loadingMethod(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static Future<void> exportAsExcel(
    BuildContext context,
    List<OrderModel> orders,
  ) async {
    // final excel = Excel.createExcel();
    // final Sheet sheet = excel['Sheet1'];

    // sheet.appendRow([
    //   'order.num'.tr,
    //   'order.clientName'.tr,

    //   'order.amount'.tr,
    //   // ✅ تأكد أيضًا أن المفتاح مكتوب صحيحًا (وليس mount)
    //   'order.state'.tr,
    //   'order.date'.tr,
    // ]);

    // for (var order in orders) {
    //   final state = OrderController.instance.getOrderState(order);
    //   sheet.appendRow([
    //     order.id,
    //     order.buyerDetails.name,
    //     TCustomWidgets.getPrice(order.totalPrice),
    //     state,
    //     order.orderDate.toLocal().toString().split('.')[0],
    //   ]);
    // }

    // final fileBytes = excel.encode();
    // final dir = await getTemporaryDirectory();
    // final file = File('${dir.path}/orders_report.xlsx');
    // await file.writeAsBytes(fileBytes!);

    // await Share.shareXFiles([
    //   XFile(file.path),
    // ], text: local.translate('order.pdfHint'));
  }
}
