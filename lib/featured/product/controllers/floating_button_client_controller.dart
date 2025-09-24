import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class FloatingButtonsClientController extends GetxController {
  ProductModel product = ProductModel.empty();
  var savedController = SavedController.instance;

  OverlayEntry? overlayEntry;
  var isEditabel = false;
  // متغير لمتابعة موقع الإصبع (سيُحدث أثناء السحب)
  Rxn<Offset> currentDragPosition = Rxn<Offset>();

  // عتبة الكشف (بالبكسل) لتحديد مدى قرب الإصبع من مركز أيقونة معينة
  final double iconActivationThreshold = 50.0;
  // قائمة لتخزين مراكز الأيقونات بعد حسابها
  final List<Offset> iconCenters = [];

  // بيانات الأيقونات؛ هنا "حفظ" تُستخدم لأيقونة الإعجاب (like)
  final List<Map<String, dynamic>> iconsData = [
    {"icon": Icons.share_outlined, "label": "share"},
    {"icon": Icons.favorite, "label": "like"},
    {"icon": Icons.bookmark, "label": "save"},
  ];
  bool _actionTriggered = false;
  var isLike = false.obs;
  int _lastHoveredIndex = -1;

  Offset? pressPosition;

  /// [productIsFavorite] هي حالة المنتج (مفضلة أم لا).
  void showFloatingButtons(
    BuildContext context,
    Offset position, {
    bool productIsFavorite = false,
  }) {
    var saved = savedController.isSaved(product.id).obs;

    removeFloatingButtons();
    iconCenters.clear();
    _actionTriggered = false;
    _lastHoveredIndex = -1;
    pressPosition = position;
    currentDragPosition.value = position; // تحديث أولي لموضع الإصبع

    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final centerX = screenSize.width / 2;
    double baseAngle = 0;
    if (pressPosition!.dx < centerX * 0.3) {
      baseAngle =
          100; // القائمة تظهر على يمين الإصبع عندما يكون الضغط في أقصى اليسار
    } else if (pressPosition!.dx > centerX * 0.8) {
      baseAngle =
          pi +
          20; // القائمة تظهر على بسار الإصبع عندما يكون الضغط في أقصى اليمين
    } else {
      baseAngle = -pi / 2;
    }

    final spread = pi / 1.8;
    final startAngle = baseAngle - spread / 2;
    final endAngle = baseAngle + spread / 2;
    double radius = 85.0;

    overlayEntry = OverlayEntry(
      builder: (context) {
        //  var iconsData=isEditabel ? iconsDataVendor:iconsDataClient;
        // نستخدم IgnorePointer لكي لا تُعترض طبقة الـ Overlay أحداث اللمس،
        // وهذا يسمح للـ GestureDetector في شاشة المنتجات التقاطها.
        return IgnorePointer(
          child: Obx(() {
            // اختبار الأيقونة التي يمر فوقها الإصبع لتفعيل رد الفعل اللمسي.
            int currentHovered = _getSelectedIconIndex();
            if (currentHovered != _lastHoveredIndex && currentHovered != -1) {
              HapticFeedback.lightImpact();
              _lastHoveredIndex = currentHovered;
            }
            return Stack(
              children: [
                // طبقة تعتيم تغطي الشاشة.
                Container(color: Colors.black.withValues(alpha: 0.2)),
                // رسم الدائرة الشفافة في موقع الضغط.
                if (pressPosition != null)
                  Positioned(
                    left: pressPosition!.dx,
                    top: pressPosition!.dy,
                    child: TRoundedContainer(
                      width: 50,
                      height: 50,
                      radius: BorderRadius.circular(300),
                      showBorder: true,
                      borderColor: Colors.grey.withValues(alpha: .5),
                      borderWidth: 4,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                // رسم أيقونات القائمة.
                ...List.generate(iconsData.length, (index) {
                  // نحسب زاوية ظهور الأيقونة بناءً على الزاوية الأساسية وانتشارها.
                  double iconAngle =
                      startAngle +
                      index *
                          ((endAngle - startAngle) / (iconsData.length - 1));
                  double dx = radius * cos(iconAngle);
                  double dy = radius * sin(iconAngle);
                  Offset iconCenter = pressPosition! + Offset(dx, dy);
                  if (iconCenters.length < iconsData.length) {
                    iconCenters.add(iconCenter);
                  } else {
                    iconCenters[index] = iconCenter;
                  }
                  // تحديد اللون وحجم الأيقونة بناءً على قرب الإصبع منها.
                  Color defaultColor;
                  Color defaultBgColor = Colors.white;
                  Color hoverColor = Colors.white;
                  Color hoverBgColor = Colors.black;

                  switch (iconsData[index]["label"]) {
                    case "like":
                      defaultColor =
                          FavoriteProductsController.instance.isSaved(
                                product.id,
                              )
                              ? Colors.red
                              : Colors.black;
                      defaultBgColor = Colors.white;
                      hoverColor = Colors.white;
                      hoverBgColor = Colors.black;
                      break;
                    case "save":
                      defaultColor = saved.value ? Colors.blue : Colors.black;
                      defaultBgColor = Colors.white;
                      hoverColor = Colors.white;
                      hoverBgColor = Colors.black;
                      break;
                    default:
                      defaultColor = Colors.black;
                      defaultBgColor = Colors.white;
                      hoverColor = Colors.white;
                      hoverBgColor = Colors.black;
                  }

                  Color iconColor = defaultColor;
                  Color bgColor = defaultBgColor;
                  double scale = 1.0;

                  if (currentDragPosition.value != null) {
                    double distance =
                        (currentDragPosition.value! - iconCenter).distance;
                    if (distance <= iconActivationThreshold) {
                      iconColor = hoverColor;
                      bgColor = hoverBgColor;
                      scale = 1.5;
                    }
                  }
                  // إذا كانت الأيقونة "حفظ" تقوم بتبديل الرمز بحسب حالة المفضلة.
                  IconData iconData =
                      iconsData[index]["label"] == "save"
                          ? (saved.value
                              ? Icons.bookmark
                              : Icons.bookmark_border)
                          : iconsData[index]["label"] == "like"
                          ? (FavoriteProductsController.instance.isSaved(
                                product.id,
                              )
                              ? Icons.favorite
                              : Icons.favorite_border)
                          : iconsData[index]["icon"];

                  return Positioned(
                    left: iconCenter.dx - 15,
                    top: iconCenter.dy - 15,
                    child: AnimatedScale(
                      scale: scale,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () {},
                        backgroundColor: bgColor,
                        child: Icon(iconData, color: iconColor),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        );
      },
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  /// تقوم هذه الدالة بتحديث موقع الإصبع
  void updatePosition(Offset pos) {
    currentDragPosition.value = pos;
  }

  /// تُعيد _getSelectedIconIndex الفهرس الخاص بالأيقونة التي يقع عنها الإصبع ضمن العتبة
  int _getSelectedIconIndex() {
    if (currentDragPosition.value == null) return -1;
    for (int i = 0; i < iconCenters.length; i++) {
      if ((currentDragPosition.value! - iconCenters[i]).distance <=
          iconActivationThreshold) {
        return i;
      }
    }
    return -1;
  }

  /// عند تحرير الإصبع تُعالج عملية الاختيار (إذا وُجدت أيقونة تحت الإصبع)
  void processSelection() {
    // var iconsData=isEditabel ? iconsDataVendor:iconsDataClient;
    if (!_actionTriggered) {
      int selectedIndex = _getSelectedIconIndex();
      if (selectedIndex != -1) {
        _actionTriggered = true;
        if (iconsData[selectedIndex]["label"] == "like") {
          isLike.value = !isLike.value;
        }
        performAction(iconsData[selectedIndex]["label"]);
      }
    }
  }

  Future<void> performAction(String label) async {
    switch (label) {
      case 'like':
        var like = FavoriteProductsController.instance.isSaved(product.id);
        if (like) {
          FavoriteProductsController.instance.removeProduct(product);
        } else {
          // عرض أنيميشن القلوب المتطايرة عند الإعجاب
          if (pressPosition != null) {
            ProductActionsMenu.showFloatingHearts(
              Get.context!,
              tapPosition: pressPosition,
            );
          }
          FavoriteProductsController.instance.saveProduct(product);
        }
        break;

      case 'save':
        var save = SavedController.instance.isSaved(product.id);
        if (save) {
          SavedController.instance.removeProduct(product);
        } else {
          SavedController.instance.saveProduct(product);
        }
        break;

      case 'share':
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ShareServices.shareProduct(product);

        Navigator.pop(Get.context!);
        break;
      default:
        removeFloatingButtons();
        return; // القيمة الافتراضية إذا لم يكن المدخل صحيحاً
    }

    // Get.snackbar("إجراء", "تم تنفيذ: $label", snackPosition: SnackPosition.BOTTOM);
  }

  void removeFloatingButtons() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
