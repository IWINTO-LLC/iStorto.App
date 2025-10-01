import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class RTLHelper {
  /// إرجاع المسافات المناسبة للعناصر بناءً على اتجاه النص
  ///
  /// [isFirst] - هل هذا العنصر الأول
  /// [isLast] - هل هذا العنصر الأخير
  /// [context] - السياق للحصول على اتجاه النص
  /// [spacing] - المسافة المطلوبة (افتراضي: TSizes.spaceBtWItems)
  static EdgeInsets getItemPadding({
    required bool isFirst,
    required bool isLast,
    required BuildContext context,
    double? spacing,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final space = spacing ?? TSizes.spaceBtWItems;

    return EdgeInsets.only(
      left: isRTL ? (isLast ? space : 0) : (isFirst ? space : 0),
      right: isRTL ? (isFirst ? space : 0) : (isLast ? space : 0),
    );
  }

  /// إرجاع المسافات للقائمة الأفقية بناءً على اتجاه النص
  ///
  /// [index] - فهرس العنصر الحالي
  /// [totalItems] - إجمالي عدد العناصر
  /// [context] - السياق للحصول على اتجاه النص
  /// [spacing] - المسافة المطلوبة (افتراضي: TSizes.spaceBtWItems)
  static EdgeInsets getHorizontalListPadding({
    required int index,
    required int totalItems,
    required BuildContext context,
    double? spacing,
  }) {
    final isFirst = index == 0;
    final isLast = index == totalItems - 1;

    return getItemPadding(
      isFirst: isFirst,
      isLast: isLast,
      context: context,
      spacing: spacing,
    );
  }

  /// إرجاع المسافات للقائمة العمودية بناءً على اتجاه النص
  ///
  /// [index] - فهرس العنصر الحالي
  /// [totalItems] - إجمالي عدد العناصر
  /// [context] - السياق للحصول على اتجاه النص
  /// [spacing] - المسافة المطلوبة (افتراضي: TSizes.spaceBtWItems)
  static EdgeInsets getVerticalListPadding({
    required int index,
    required int totalItems,
    required BuildContext context,
    double? spacing,
  }) {
    final isFirst = index == 0;
    final isLast = index == totalItems - 1;
    final space = spacing ?? TSizes.spaceBtWItems;

    return EdgeInsets.only(
      top: isFirst ? space : 0,
      bottom: isLast ? space : 0,
    );
  }

  /// إرجاع المسافات المخصصة بناءً على اتجاه النص
  ///
  /// [isFirst] - هل هذا العنصر الأول
  /// [isLast] - هل هذا العنصر الأخير
  /// [context] - السياق للحصول على اتجاه النص
  /// [horizontalSpacing] - المسافة الأفقية (افتراضي: TSizes.spaceBtWItems)
  /// [verticalSpacing] - المسافة العمودية (افتراضي: 0)
  static EdgeInsets getCustomPadding({
    required bool isFirst,
    required bool isLast,
    required BuildContext context,
    double? horizontalSpacing,
    double? verticalSpacing,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final hSpace = horizontalSpacing ?? TSizes.spaceBtWItems;
    final vSpace = verticalSpacing ?? 0;

    return EdgeInsets.only(
      left: isRTL ? (isLast ? hSpace : 0) : (isFirst ? hSpace : 0),
      right: isRTL ? (isFirst ? hSpace : 0) : (isLast ? hSpace : 0),
      top: isFirst ? vSpace : 0,
      bottom: isLast ? vSpace : 0,
    );
  }
}
