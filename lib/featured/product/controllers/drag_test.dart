import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // لاستخدام HapticFeedback
import 'package:get/get.dart';
import 'package:istoreto/utils/constants/color.dart';

class FloatingButtonsController extends GetxController {
  OverlayEntry? overlayEntry;
  // متغير لمتابعة موقع الإصبع (سيُحدث أثناء السحب)
  Rxn<Offset> currentDragPosition = Rxn<Offset>();

  // عتبة الكشف (بالبكسل) لتحديد مدى قرب الإصبع من مركز أيقونة معينة
  final double iconActivationThreshold = 50.0;
  // قائمة لتخزين مراكز الأيقونات بعد حسابها
  final List<Offset> iconCenters = [];

  // بيانات الأيقونات؛ هنا "حفظ" تُستخدم لأيقونة الإعجاب (like)
  final List<Map<String, dynamic>> iconsData = [
    {"icon": Icons.favorite, "label": "حفظ"},
    {"icon": Icons.share, "label": "مشاركة"},
    {"icon": Icons.close, "label": "إغلاق"},
    {"icon": Icons.edit, "label": "تعديل"},
    {"icon": Icons.delete, "label": "حذف"},
  ];

  bool _actionTriggered = false;
  bool isFavorite = false;
  int _lastHoveredIndex = -1;

  // نقوم بتخزين موقع الضغط الأولي لاستخدامه في رسم دائرة شفافة
  Offset? pressPosition;

  /// تعرض هذه الدالة القائمة العائمة (Overlay)
  /// مع طبقة تعتيم ودائرة شفافة في موقع الضغط.
  /// يتم حساب زاوية بدء عرض الأيقونات ديناميكيًا بناءً على مكان الإصبع.
  /// [productIsFavorite] هي حالة المنتج (مفضلة أم لا).
  void showFloatingButtons(
    BuildContext context,
    Offset position, {
    bool productIsFavorite = false,
  }) {
    removeFloatingButtons();
    iconCenters.clear();
    _actionTriggered = false;
    isFavorite = productIsFavorite;
    _lastHoveredIndex = -1;
    pressPosition = position;
    currentDragPosition.value = position; // تحديث أولي لموضع الإصبع

    // نحصل على قياسات الشاشة ونحسب مركزها.
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    // نحسب الزاوية الأساسية بين نقطة الضغط ومركز الشاشة.
    double baseAngle = atan2(center.dy - position.dy, center.dx - position.dx);
    if (baseAngle < 0) baseAngle += 2 * pi;
    // نختار انتشاراً (spread) 90 درجة (pi/2 راديان) لتوزيع الأيقونات حول الزاوية الأساسية.
    final spread = pi / 2;
    final double startAngle = baseAngle - spread / 2;
    final double endAngle = baseAngle + spread / 2;

    double radius = 110.0;

    overlayEntry = OverlayEntry(
      builder: (context) {
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
                    left: pressPosition!.dx - 50,
                    top: pressPosition!.dy - 50,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TColors.grey,
                      ),

                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                  Color hoverColor;
                  switch (iconsData[index]["label"]) {
                    case "حفظ":
                      defaultColor = isFavorite ? Colors.red : Colors.black;
                      hoverColor = Colors.redAccent;
                      break;
                    case "مشاركة":
                      defaultColor = Colors.black;
                      hoverColor = Colors.blueAccent;
                      break;
                    case "إغلاق":
                      defaultColor = Colors.black;
                      hoverColor = Colors.grey;
                      break;
                    case "تعديل":
                      defaultColor = Colors.black;
                      hoverColor = Colors.orangeAccent;
                      break;
                    case "حذف":
                      defaultColor = Colors.black;
                      hoverColor = Colors.red;
                      break;
                    default:
                      defaultColor = Colors.black;
                      hoverColor = Colors.black;
                  }
                  Color bgColor = defaultColor;
                  double scale = 1.0;
                  if (currentDragPosition.value != null) {
                    double distance =
                        (currentDragPosition.value! - iconCenter).distance;
                    if (distance <= iconActivationThreshold) {
                      bgColor = hoverColor;
                      scale = 1.3;
                    }
                  }
                  // إذا كانت الأيقونة "حفظ" تقوم بتبديل الرمز بحسب حالة المفضلة.
                  IconData iconData =
                      iconsData[index]["label"] == "حفظ"
                          ? (isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border)
                          : iconsData[index]["icon"];

                  return Positioned(
                    left: iconCenter.dx - 20,
                    top: iconCenter.dy - 20,
                    child: AnimatedScale(
                      scale: scale,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () {},
                        backgroundColor: bgColor,
                        child: Icon(iconData, color: Colors.white),
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
    if (!_actionTriggered) {
      int selectedIndex = _getSelectedIconIndex();
      if (selectedIndex != -1) {
        _actionTriggered = true;
        if (iconsData[selectedIndex]["label"] == "حفظ") {
          isFavorite = !isFavorite;
        }
        performAction(iconsData[selectedIndex]["label"]);
      }
    }
  }

  void performAction(String label) {
    Get.snackbar(
      "إجراء",
      "تم تنفيذ: $label",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeFloatingButtons() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}

class ProductListScreen extends StatelessWidget {
  final FloatingButtonsController controller = Get.put(
    FloatingButtonsController(),
  );

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> products = [
      "منتج 1",
      "منتج 2",
      "منتج 3",
      "منتج 4",
      "منتج 1",
      "منتج 2",
      "منتج 3",
      "منتج 4",
      "منتج 1",
      "منتج 2",
      "منتج 3",
      "منتج 4",
      "منتج 1",
      "منتج 2",
      "منتج 3",
      "منتج 4",
    ];
    return Scaffold(
      appBar: AppBar(title: Text("قائمة المنتجات")),
      body: SafeArea(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            // هنا يتم دمج الضغط المطول والسحب في سلسلة واحدة
            return GestureDetector(
              onLongPressStart: (details) {
                controller.showFloatingButtons(
                  context,
                  details.globalPosition,
                  productIsFavorite: false,
                );
              },
              onLongPressMoveUpdate: (details) {
                controller.updatePosition(details.globalPosition);
              },
              onLongPressEnd: (details) {
                controller.processSelection();
                controller.removeFloatingButtons();
              },
              child: Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ListTile(title: Text(products[index])),
              ),
            );
          },
        ),
      ),
    );
  }
}
