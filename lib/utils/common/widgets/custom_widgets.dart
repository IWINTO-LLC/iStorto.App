// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/custom_Excel_menu/controller/bulk_excel_product_control.dart';
import 'package:istoreto/featured/custom_menu/controller/bulk_product_control.dart';
import 'package:istoreto/featured/custom_menu/screen/product_menu.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/common/widgets/texts/widgets/bottom_menu_item.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/dialog/reusable_dialog.dart';
import 'package:istoreto/utils/formatters/formatter.dart';
import 'package:istoreto/utils/loader/loaders.dart';
import 'package:sizer/sizer.dart';

class TCustomWidgets {
  static Widget buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 3),
      child: const Divider(thickness: .5),
    );
  }

  static Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [const SizedBox(width: 8), Text(text, style: titilliumBold)],
      ),
    );
  }

  // static double getCoinsRatio() {
  //   double s = 0.00;
  //   Consumer(builder: (context, ref, child) {
  //   s = ref.watch(winicoinsUsdRateProvider as ProviderListenable<double>);

  //   });
  //   return s;
  // }

  static String getPrice(double value) {
    var curr =
        AuthController.instance.currentUser.value?.defaultCurrency ?? 'USD';

    double convertedValue;
    try {
      convertedValue = CurrencyController.instance.convertToDefaultCurrency(
        value,
      );
    } catch (e) {
      debugPrint('Error converting currency in getPrice: $e');
      convertedValue = value;
      curr = 'USD';
    }

    return "${TFormatter.formateNumber(convertedValue)} $curr";
  }

  static Widget formattedPrice(double value, double size, Color fontColor) {
    // الحصول على العملة الافتراضية للمستخدم
    var curr =
        AuthController.instance.currentUser.value?.defaultCurrency ?? 'USD';

    // تحويل السعر من الدولار إلى العملة الافتراضية
    double convertedValue;
    try {
      convertedValue = CurrencyController.instance.convertToDefaultCurrency(
        value,
      );
    } catch (e) {
      // في حالة فشل التحويل، استخدم القيمة الأصلية واستخدم USD
      debugPrint('Error converting currency: $e');
      convertedValue = value;
      curr = 'USD';
    }

    return RichText(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: TextStyle(
          fontSize: size - 2,
          color: fontColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ), // حجم الرقم الأساسي
        children: [
          TextSpan(text: TFormatter.formateNumber(convertedValue)),
          TextSpan(
            text: " $curr", // العملة
            style: TextStyle(
              fontSize: size - 6,
              fontWeight: FontWeight.normal,
              color: fontColor,
              fontFamily: 'Poppins',
            ), // حجم أصغر للعملة
          ),
        ],
      ),
    );
  }

  static Widget formattedCrossPrice(
    double value,
    double size,
    Color fontColor,
  ) {
    var curr =
        AuthController.instance.currentUser.value?.defaultCurrency ?? 'USD';

    double convertedValue;
    try {
      convertedValue = CurrencyController.instance.convertToDefaultCurrency(
        value,
      );
    } catch (e) {
      debugPrint('Error converting currency in formattedCrossPrice: $e');
      convertedValue = value;
      curr = 'USD';
    }

    return RichText(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: TextStyle(
          fontSize: size - 2,
          color: fontColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ), // حجم الرقم الأساسي
        children: [
          TextSpan(text: '('),
          TextSpan(text: TFormatter.formateNumber(convertedValue)),
          TextSpan(
            text: " $curr", // العملة
            style: TextStyle(
              fontSize: size - 4,
              fontWeight: FontWeight.normal,
              color: fontColor,
              fontFamily: 'Poppins',
            ), // حجم أصغر للعملة
          ),
          TextSpan(text: ')'),
        ],
      ),
    );
  }

  static Widget formattedCartPrice(double value, double size, Color fontColor) {
    var curr =
        AuthController.instance.currentUser.value?.defaultCurrency ?? 'USD';

    double convertedValue;
    try {
      convertedValue = CurrencyController.instance.convertToDefaultCurrency(
        value,
      );
    } catch (e) {
      debugPrint('Error converting currency in formattedCartPrice: $e');
      convertedValue = value;
      curr = 'USD';
    }

    return RichText(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: TextStyle(
          fontSize: size - 2,
          color: fontColor,
          fontWeight: FontWeight.normal,
          fontFamily: 'Poppins',
        ), // حجم الرقم الأساسي
        children: [
          TextSpan(text: TFormatter.formateNumber(convertedValue)),
          TextSpan(
            text: " $curr", // العملة
            style: TextStyle(
              fontSize: size - 4,
              fontWeight: FontWeight.normal,
              color: fontColor,
              fontFamily: 'Poppins',
            ), // حجم أصغر للعملة
          ),
        ],
      ),
    );
  }

  static Widget viewSalePrice(String text, double size) {
    double convertedValue;
    try {
      convertedValue = CurrencyController.instance.convertToDefaultCurrency(
        double.parse(text),
      );
    } catch (e) {
      debugPrint('Error converting currency in viewSalePrice: $e');
      convertedValue = double.tryParse(text) ?? 0.0;
    }

    return Text(
      TFormatter.formateNumber(convertedValue),
      style: titilliumBold.copyWith(
        color: TColors.darkGrey,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.lineThrough,
        decorationThickness: 1.5,
        fontSize: size,
      ),
    );
  }

  static Widget buildTitle(String text) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(text, style: titilliumBold.copyWith(fontSize: 18, height: .5)),
      ],
    );
  }
}

GestureDetector backAction(String userId, BuildContext context) {
  return GestureDetector(
    onTap: () => onBackFromEdit(userId, context),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        // alignment: Alignment.topCenter,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.1416),
            child: TRoundedContainer(
              width: 35,
              height: 35,
              enableShadow: true,
              backgroundColor: TColors.primary,
              showBorder: true,
              radius: BorderRadius.circular(100),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.reply, size: 26, color: TColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void onBackFromEdit(String userId, BuildContext context) {
  Get.rawSnackbar(
    messageText: Text(
      'order_saveAndExit'.tr,
      textAlign: TextAlign.center,
      style: titilliumBold.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    margin: EdgeInsets.only(
      top: 100.h / 2 - 40, // منتصف الشاشة تقريبًا
      left: 30.w,
      right: 30.w,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: 20,
    duration: const Duration(seconds: 1),
    backgroundColor: TColors.primary,
    snackPosition: SnackPosition.TOP, // ← لا تغيّره، نستخدمه فقط لأنه required
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Get.offAll(() => MarketPlaceView(vendorId: userId, editMode: false));
}

Future<void> returnMethodeFromEdit(String user, BuildContext context) async {
  onBackFromEdit(user, context);
  HapticFeedback.lightImpact;
  Get.to(() => MarketPlaceView(vendorId: user, editMode: false));
  // await CartController.instance.saveCartToFirestore();
}

void openDeleteSelectionDialog(BuildContext context) {
  ReusableAlertDialog.show(
    context: context,
    title: 'product.delete_items'.tr,
    content: 'product.delete_items_confirm'.tr,
    onConfirm: () {
      ProductControllerx().deleteSelectedProducts;
    },
  );
  Get.back();
}

void openCategorySelectionDialog(BuildContext context) {
  var controller = Get.put(ProductControllerx());
  var addCat = CategoryModel(title: 'edit_category.add_category');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("category.choose_new".tr, style: titilliumBold),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    CategoryController.instance.isLoading.value
                        ? const TShimmerEffect(
                          width: double.infinity,
                          height: 55,
                        )
                        : Column(
                          children: [
                            Center(
                              child: SizedBox(
                                height: 80,
                                child: Obx(() {
                                  return DropdownButtonFormField(
                                    borderRadius: BorderRadius.circular(15),
                                    iconSize: 40,

                                    itemHeight: 60, //

                                    items:
                                        CategoryController.instance.allItems.map((
                                            cat,
                                          ) {
                                            return DropdownMenuItem(
                                              value: cat,
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          300,
                                                        ),
                                                    child: SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child: CustomCaChedNetworkImage(
                                                        width: 40,
                                                        height: 40,
                                                        url: cat.icon!,
                                                        raduis:
                                                            BorderRadius.circular(
                                                              300,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    cat.title,
                                                    style: titilliumRegular
                                                        .copyWith(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList()
                                          ..add(
                                            DropdownMenuItem(
                                              value: addCat,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.add,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "addNewCategory".tr,
                                                    style: titilliumRegular
                                                        .copyWith(
                                                          color: Colors.blue,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    onChanged: (newValue) {
                                      if (newValue == addCat) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const CreateCategory(
                                                      vendorId: '',
                                                    ),
                                          ),
                                        );
                                      } else {
                                        controller.category = newValue!;
                                      }
                                    },
                                  );
                                }),
                              ),
                            ),
                            CustomButtonBlack(
                              text: "move",
                              onTap: () {
                                controller.moveSelectedProductsToCategory(
                                  controller.category,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
//openSectorSelectionTempDialog

void openSectorSelectionTempDialog(BuildContext context) {
  var controller = Get.put(ProductControllerExcel());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("chooseNewSector".tr, style: titilliumBold),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    SectorController.instance.isLoading.value
                        ? const TShimmerEffect(
                          width: double.infinity,
                          height: 55,
                        )
                        : Column(
                          children: [
                            Center(
                              child: SizedBox(
                                height: 80,
                                child: Obx(() {
                                  return DropdownButtonFormField(
                                    borderRadius: BorderRadius.circular(15),
                                    iconSize: 40,

                                    itemHeight: 60, //
                                    onChanged: (newValue) {
                                      controller.newSector = newValue!;
                                    },
                                    items:
                                        SectorController.instance.sectors.map((
                                          sector,
                                        ) {
                                          return DropdownMenuItem(
                                            value: sector,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Text(
                                                  sector.englishName,
                                                  style: titilliumRegular
                                                      .copyWith(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }),
                              ),
                            ),
                            CustomButtonBlack(
                              text: "move",
                              onTap: () {
                                controller.moveSelectedProductsToSector(
                                  controller.newSector,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String getOrderState(OrderModel order) {
  switch (order.state) {
    case '0':
      return "orderState.unKnoun"
          .tr; //isArabicLocale() ? "غير معروف" : "Un Known";
    case '1':
      return "orderState.paied".tr;
    case '2':
      return "orderState.delivered".tr;
    case '3':
      return "orderState.packaging".tr;
    case '4':
      return "orderState.runing".tr;
    default:
      return ""; // القيمة الافتراضية إذا لم يكن الم
  }
}

void showManageOrderBottomSheet(
  BuildContext context,
  String vendorId,
  OrderModel order,
) {
  final orderController = OrderController.instance;
  final stateKeys = {'runing': 4, "packaging": 3, 'paied': 1, 'delivered': 2};

  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return TRoundedContainer(
        radius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "updateOrderStatus".tr,
              style: titilliumBold.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 16),

            // عرض الحالات كقائمة
            ...stateKeys.entries.map((entry) {
              final label = entry.key;
              final key = entry.value;
              final translated = "orderState.$label".tr;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BuildBottomMenuItem(
                  icon: const Icon(Icons.update, color: Colors.black),
                  text: translated,
                  onTap: () async {
                    Navigator.of(context).pop();
                    TLoader.progressSnackBar(title: "", message: "updating".tr);

                    await orderController.updateOrderState(
                      order.docId,
                      key.toString(),
                      vendorId,
                    );

                    TLoader.successSnackBar(
                      title: "",
                      message: "${"status_updated_to".tr}: $translated",
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 8),
            Text(
              "choose_appropriate_status".tr,
              style: titilliumBold.copyWith(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    },
  );
}

void showManageOrderBottomSheet2(
  BuildContext context,
  String vendorId,
  OrderModel order,
) {
  var orderController = OrderController();
  showModalBottomSheet(
    backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (BuildContext context) {
      return TRoundedContainer(
        width: 100.w,
        radius: const BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BuildBottomMenuItem(
                icon: const Icon(Icons.delivery_dining, color: Colors.black),
                text: "delivery_order".tr,
                onTap: () async {
                  TLoader.progressSnackBar(title: "on_way_for_delivery".tr);
                  await orderController.updateOrderState(
                    order.vendorId,
                    order.docId,
                    '2',
                  );
                  Get.back();
                  TLoader.successSnackBar(
                    title: "",
                    message: "order_delivered".tr,
                  );
                  //  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

void showExcelBottomSheet(
  BuildContext context,
  List<ProductModel> spotList,
  String vendorId,
) {
  showModalBottomSheet(
    backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (BuildContext context) {
      return TRoundedContainer(
        width: 100.w,
        radius: const BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BuildBottomMenuItem(
                icon: const Icon(Icons.download, color: Colors.black),
                text: "import_new_excel_file".tr,
                onTap: () {
                  HapticFeedback.lightImpact;

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ImportExcelPage(vendorId: vendorId),
                  //   ),
                  // );
                },
              ),
              // const SizedBox(
              //   height: 16,
              // ),
              // BuildBottomMenuItem(
              //     icon: const Icon(Icons.menu, color: Colors.black),
              //     text: 'معالجة ملف سابق',
              //     onTap: () {
              //       HapticFeedback.lightImpact;

              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => ProductManageExelTempBulkMenu(
              //                     initialList: ExcelController().products,
              //                   )));
              //     }),
              const SizedBox(height: 16),
              BuildBottomMenuItem(
                icon: const Icon(Icons.menu_open_rounded, color: Colors.black),
                text: "manage_current_menu".tr,
                onTap: () {
                  HapticFeedback.lightImpact;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductManageBulkMenu(
                            initialList: spotList,
                            vendorId: vendorId,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void openCategorySelectionTempDialog(BuildContext context) {
  var controller = Get.put(ProductControllerExcel());
  var addCat = CategoryModel(title: 'edit_category.add_category'.tr);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("choose_new_destination".tr, style: titilliumBold),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    CategoryController.instance.isLoading.value
                        ? const TShimmerEffect(
                          width: double.infinity,
                          height: 55,
                        )
                        : Column(
                          children: [
                            Center(
                              child: SizedBox(
                                height: 80,
                                child: Obx(() {
                                  return DropdownButtonFormField(
                                    borderRadius: BorderRadius.circular(15),
                                    iconSize: 40,

                                    itemHeight: 60, //

                                    items:
                                        CategoryController.instance.allItems.map((
                                            cat,
                                          ) {
                                            return DropdownMenuItem(
                                              value: cat,
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          300,
                                                        ),
                                                    child: SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child: CustomCaChedNetworkImage(
                                                        width: 40,
                                                        height: 40,
                                                        url: cat.icon!,
                                                        raduis:
                                                            BorderRadius.circular(
                                                              300,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    cat.title,
                                                    style: titilliumRegular
                                                        .copyWith(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList()
                                          ..add(
                                            DropdownMenuItem(
                                              value: addCat,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.add,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "add_new_category".tr,
                                                    style: titilliumRegular
                                                        .copyWith(
                                                          color: Colors.blue,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    onChanged: (newValue) {
                                      if (newValue == addCat) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const CreateCategory(
                                                      vendorId: '',
                                                    ),
                                          ),
                                        );
                                      } else {
                                        controller.category = newValue!;
                                      }
                                    },
                                  );
                                }),
                              ),
                            ),
                            CustomButtonBlack(
                              text: "move",
                              onTap: () {
                                controller.moveSelectedProductsToCategory(
                                  controller.category,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

void showEditDialog(BuildContext context, SectorModel sector) {
  // استخدام GetX بدلاً من context
  var ctr = Get.find<SectorController>();

  TextEditingController englishNameController = TextEditingController(
    text: sector.englishName,
  );

  Get.dialog(
    AlertDialog(
      title: Text("choose_new_name".tr, style: titilliumBold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: englishNameController,
            decoration: InputDecoration(
              hintText: "sector_name".tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButtonBlack(
              width: 20.w,
              onTap: () {
                // استخدام Get.back() بدلاً من Navigator.pop
                Navigator.pop(context);
              },
              text: "cancel".tr,
            ),
            const SizedBox(width: 19),
            CustomButtonBlack(
              width: 20.w,
              onTap: () async {
                try {
                  // Create updated sector using copyWith for immutability
                  final updatedSector = sector.copyWith(
                    englishName: englishNameController.text.trim(),
                  );

                  // استخدام GetX controller لتحديث القطاع
                  await ctr.updateSection(updatedSector);

                  // إغلاق Dialog باستخدام GetX
                  Get.back();

                  // عرض رسالة نجاح واحدة بخلفية خضراء سفلية
                  Get.snackbar(
                    "success".tr,
                    "تم تحديث القسم بنجاح",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade800,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(10),
                    borderRadius: 8,
                  );
                } catch (e) {
                  // إغلاق Dialog في حالة الخطأ
                  Get.back();

                  // عرض رسالة خطأ
                  Get.snackbar(
                    "error".tr,
                    "فشل في تحديث القسم",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade800,
                    duration: const Duration(seconds: 3),
                    margin: const EdgeInsets.all(10),
                    borderRadius: 8,
                  );
                }
              },
              text: "post".tr,
            ),
          ],
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

void showEditDialosg(BuildContext context, SectorModel sector) {
  var ctr = SectorController.instance;

  TextEditingController englishNameController = TextEditingController(
    text: sector.englishName,
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Text("edit_sector".tr, style: titilliumBold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: englishNameController,
              decoration: InputDecoration(labelText: 'ecommerce.title'.tr),
            ),
          ],
        ),
        actions: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButtonBlack(
                  width: 20.w,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  text: "cancel".tr,
                ),
                const SizedBox(width: 19),
                CustomButtonBlack(
                  width: 20.w,
                  onTap: () async {
                    // Create updated sector using copyWith for immutability
                    final updatedSector = sector.copyWith(
                      englishName: englishNameController.text.trim(),
                    );

                    await ctr.updateSection(updatedSector);
                    Navigator.of(context).pop();
                  },
                  text: "post".tr,
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void openSectorSelectionDialog(BuildContext context) {
  var controller = Get.put(ProductControllerx());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("choose_new_sector".tr, style: titilliumBold),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    SectorController.instance.isLoading.value
                        ? const TShimmerEffect(
                          width: double.infinity,
                          height: 55,
                        )
                        : Column(
                          children: [
                            Center(
                              child: SizedBox(
                                height: 80,
                                child: Obx(() {
                                  return DropdownButtonFormField(
                                    borderRadius: BorderRadius.circular(15),
                                    iconSize: 40,

                                    itemHeight: 60, //
                                    onChanged: (newValue) {
                                      controller.newSector = newValue!;
                                    },
                                    items:
                                        SectorController.instance.sectors.map((
                                          sector,
                                        ) {
                                          return DropdownMenuItem(
                                            value: sector,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Text(
                                                  sector.englishName,
                                                  style: titilliumRegular
                                                      .copyWith(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }),
                              ),
                            ),
                            CustomButtonBlack(
                              text: "move",
                              onTap: () {
                                controller.moveSelectedProductsToSector(
                                  controller.newSector,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
