import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';

import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';

import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:istoreto/utils/constants/color.dart';

// Helper function to check if current locale is Arabic
bool isArabicLocale(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ar';
}

// Widget للقلوب المتطايرة
class FloatingHearts extends StatefulWidget {
  final VoidCallback? onComplete;
  final Offset? tapPosition; // إضافة موقع الضغط

  const FloatingHearts({super.key, this.onComplete, this.tapPosition});

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // مدة الأنيميشن
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -2.0), // حركة لأعلى فقط
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0, // يصغر من 1.0 إلى 0.0
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // بدء الأنيميشن
    _controller.forward();

    // إيقاف الأنيميشن بعد انتهائه
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد موقع البداية (مكان الضغط أو وسط الشاشة)
    final startX =
        widget.tapPosition?.dx ?? MediaQuery.of(context).size.width / 2;
    final startY =
        widget.tapPosition?.dy ?? MediaQuery.of(context).size.height / 2;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: startX - 15, // قلب واحد في وسط نقطة الضغط
              top: startY - 70,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Opacity(
                    opacity: _animation.value,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 40, // حجم ثابت للقلب
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProductActionsMenu {
  // وظيفة لعرض أنيميشن القلوب المتطايرة
  static void showFloatingHearts(BuildContext context, {Offset? tapPosition}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (context) => FloatingHearts(
            tapPosition: tapPosition,
            onComplete: () {
              // إغلاق الـ dialog تلقائياً بعد انتهاء الأنيميشن
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
    );
  }

  // وظيفة تنفيذ العمليات
  static Future<void> performAction(
    String action,
    ProductModel product,
    BuildContext context,
  ) async {
    // التأكد من وجود SavedController
    if (!Get.isRegistered<SavedController>()) {
      Get.put(SavedController());
    }

    // التأكد من وجود FavoriteProductsController
    if (!Get.isRegistered<FavoriteProductsController>()) {
      Get.put(FavoriteProductsController());
    }

    switch (action) {
      case 'like':
        var isLiked = FavoriteProductsController.instance.isSaved(product.id);
        if (isLiked) {
          await FavoriteProductsController.instance.removeProduct(product);
          FavoriteProductsController.instance.update();
        } else {
          // عرض أنيميشن القلوب المتطايرة عند الإعجاب
          showFloatingHearts(context);
          await FavoriteProductsController.instance.saveProduct(product);
          FavoriteProductsController.instance.update();
        }
        break;

      case 'save':
        var isSaved = SavedController.instance.isSaved(product.id);
        if (isSaved) {
          await SavedController.instance.removeProduct(product);
          SavedController.instance.update();
        } else {
          await SavedController.instance.saveProduct(product);
          SavedController.instance.update();
        }
        break;

      case 'share':
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ShareServices.shareProduct(product);

        Navigator.pop(context);
        break;
    }
  }

  // Widget جديد باستخدام PopupMenuButton
  static Widget buildProductActionsMenu(ProductModel product) {
    // التأكد من وجود SavedController
    if (!Get.isRegistered<SavedController>()) {
      Get.put(SavedController());
    }

    // التأكد من وجود FavoriteProductsController
    if (!Get.isRegistered<FavoriteProductsController>()) {
      Get.put(FavoriteProductsController());
    }

    return Theme(
      data: Get.context!.theme.copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            // شكل الحواف الدائرية
          ),
        ),
      ),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          //  color: Colors.white,
          shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 4,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.black),
          iconSize: 25,
          borderRadius: BorderRadius.circular(15),
          padding: const EdgeInsetsDirectional.all(2),
          itemBuilder:
              (context) => [
                // زر الإعجاب
                PopupMenuItem<String>(
                  value: 'like',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              FavoriteProductsController.instance.isSaved(
                                    product.id,
                                  )
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FavoriteProductsController.instance.isSaved(
                                product.id,
                              )
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              FavoriteProductsController.instance.isSaved(
                                    product.id,
                                  )
                                  ? Colors.red
                                  : Colors.grey[600],
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'like'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              FavoriteProductsController.instance.isSaved(
                                    product.id,
                                  )
                                  ? Colors.red
                                  : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // زر الحفظ
                PopupMenuItem<String>(
                  value: 'save',
                  child: Row(
                    children: [
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                SavedController.instance.isSaved(product.id)
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            SavedController.instance.isSaved(product.id)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color:
                                SavedController.instance.isSaved(product.id)
                                    ? Colors.green
                                    : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => Text(
                            isArabicLocale(context) ? 'حفظ' : 'Save',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  SavedController.instance.isSaved(product.id)
                                      ? Colors.green
                                      : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // زر المشاركة
                PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isArabicLocale(context) ? 'مشاركة' : 'Share',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            HapticFeedback.lightImpact();
            performAction(value, product, Get.context!);
          },
        ),
      ),
    );
  }

  // وظيفة لعرض قائمة العمليات المنسدلة (للتوافق مع الكود القديم)
  static void showProductActionsMenu(
    BuildContext context,
    ProductModel product,
  ) {
    // التأكد من وجود SavedController
    if (!Get.isRegistered<SavedController>()) {
      Get.put(SavedController());
    }

    // التأكد من وجود FavoriteProductsController
    if (!Get.isRegistered<FavoriteProductsController>()) {
      Get.put(FavoriteProductsController());
    }

    // الحصول على موقع الضغط بدقة
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) {
      return; // لا تظهر أي شيء إذا فشل الحصول على موقع الويدجت
    }

    final RenderBox? overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (overlay == null) {
      return; // لا تظهر أي شيء إذا فشل الحصول على الـ overlay
    }

    // حساب موقع القائمة بدقة - تظهر في مكان الضغط
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final Size buttonSize = button.size;

    // حساب موقع القائمة مع الأولوية للأسفل
    const double menuWidth = 200; // عرض تقريبي للقائمة
    const double menuHeight = 150; // ارتفاع تقريبي للقائمة

    // تحديد موقع القائمة (يسار الويدجت)
    double left = buttonPosition.dx;

    // الأولوية للأسفل - حساب الموقع أسفل الويدجت
    double top = buttonPosition.dy + buttonSize.height + 5;

    // إذا كانت القائمة ستتجاوز يمين الشاشة، انقلها لليسار
    if (left + menuWidth > overlay.size.width) {
      left = overlay.size.width - menuWidth - 10;
    }

    // إذا كانت القائمة ستتجاوز أسفل الشاشة، اعرضها فوق الويدجت
    if (top + menuHeight > overlay.size.height) {
      top = buttonPosition.dy - menuHeight - 5;
    }

    // التأكد من أن القائمة لا تخرج من حدود الشاشة
    left = left.clamp(10.0, overlay.size.width - menuWidth - 10);
    top = top.clamp(10.0, overlay.size.height - menuHeight - 10);

    // إضافة تعليق توضيحي
    // القائمة تظهر في مكان الضغط مع الأولوية للأسفل

    final RelativeRect position = RelativeRect.fromLTRB(
      left,
      top,
      overlay.size.width - (left + menuWidth),
      overlay.size.height - (top + menuHeight),
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      items: [
        // زر الإعجاب
        PopupMenuItem<String>(
          value: 'like',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        FavoriteProductsController.instance.isSaved(product.id)
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FavoriteProductsController.instance.isSaved(product.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        FavoriteProductsController.instance.isSaved(product.id)
                            ? Colors.red
                            : Colors.grey[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabicLocale(context) ? 'إعجاب' : 'Like',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          FavoriteProductsController.instance.isSaved(
                                product.id,
                              )
                              ? Colors.red
                              : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // زر الحفظ
        PopupMenuItem<String>(
          value: 'save',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          SavedController.instance.isSaved(product.id)
                              ? TColors.primary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      SavedController.instance.isSaved(product.id)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color:
                          SavedController.instance.isSaved(product.id)
                              ? TColors.primary
                              : Colors.grey[600],
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      isArabicLocale(context) ? 'حفظ' : 'Save',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            SavedController.instance.isSaved(product.id)
                                ? TColors.primary
                                : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // زر المشاركة
        PopupMenuItem<String>(
          value: 'share',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabicLocale(context) ? 'مشاركة' : 'Share',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        performAction(value, product, context);
      }
    });
  }
}
