import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/cart/view/add_to_cart_wid_small.dart';
import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_stuff.dart';

import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

class DynamicProductGridWidget extends StatelessWidget {
  const DynamicProductGridWidget({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.products,
    this.withTitle = true,
    this.withPadding = true,
    this.sectionTitle = '',
    this.sectorName = '',
    this.onProductTap,
    this.showDotsIndicator = true,
    this.enableTranslation = true,
  });

  final double cardWidth;
  final double cardHeight;
  final List<ProductModel> products;
  final bool withTitle;
  final bool withPadding;
  final String sectionTitle;
  final String sectorName;
  final Function(ProductModel product, int index)? onProductTap;
  final bool showDotsIndicator;
  final bool enableTranslation;

  @override
  Widget build(BuildContext context) {
    const double padding = 10;

    // إذا لم توجد منتجات، اعرض حالة فارغة
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildProductsGrid(padding);
  }

  /// بناء شبكة المنتجات
  Widget _buildProductsGrid(double padding) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding:
            withPadding
                ? const EdgeInsets.only(top: 20)
                : const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (sectionTitle.isNotEmpty && withTitle) _buildSectionTitle(),
            const SizedBox(height: 8),
            _buildProductsList(padding),
          ],
        ),
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionTitle() {
    return Builder(
      builder:
          (context) => titleWithEdit(
            context,
            sectorName,
            withTitle,
            '', // vendorId غير مطلوب
            false, // editMode دائماً false
          ),
    );
  }

  /// بناء قائمة المنتجات
  Widget _buildProductsList(double padding) {
    // إنشاء RxInt لمؤشر النقاط
    final String tag = 'currentIndex_${products.hashCode}';
    if (!Get.isRegistered<RxInt>(tag: tag)) {
      Get.put(RxInt(0), tag: tag);
    }
    final RxInt currentIndex = Get.find<RxInt>(tag: tag);

    // إنشاء ScrollController محلي
    final ScrollController scrollController = ScrollController();

    // إضافة listener للـ ScrollController لتحديث مؤشر النقاط
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        double offset = scrollController.offset;
        int newIndex = (offset / (cardWidth + padding)).round();
        newIndex = newIndex.clamp(0, products.length - 1);
        currentIndex.value = newIndex;
      }
    });

    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          height: cardWidth > 50.w ? cardHeight + 138 : cardHeight + 90,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductItem(context, index, padding);
            },
          ),
        ),

        // مؤشر النقاط أسفل القائمة
        if (showDotsIndicator && products.length > 1 && cardWidth == 94.w)
          _buildDotsIndicator(currentIndex),
      ],
    );
  }

  /// بناء عنصر المنتج
  Widget _buildProductItem(BuildContext context, int index, double padding) {
    final product = products[index];

    return Padding(
      padding:
          !TranslationController.instance.isRTL
              ? EdgeInsets.only(
                left: padding,
                bottom: 10,
                right: index == products.length - 1 ? padding : 0,
              )
              : EdgeInsets.only(
                right: padding,
                bottom: 10,
                left: index == products.length - 1 ? padding : 0,
              ),
      child: TRoundedContainer(
        radius: BorderRadius.circular(15),
        width: cardWidth,
        child: ActionsMethods.customLongMethode(
          product,
          context,
          VendorController.instance.isVendor.value,
          _buildProductContent(product, index),
          () => _handleProductTap(context, product, index),
        ),
      ),
    );
  }

  /// بناء محتوى المنتج
  Widget _buildProductContent(ProductModel product, int index) {
    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            mainAxisAlignment:
                cardWidth == 25.w
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
            crossAxisAlignment:
                cardWidth == 25.w
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              TProductImageSliderMini(
                editMode: false,
                withActions: false,
                enableShadow: true,
                product: product,
                prefferHeight: cardWidth * (4 / 3) + 12,
                prefferWidth: cardWidth,
              ),
              Container(color: Colors.transparent, height: 6),

              // عنوان المنتج
              _buildProductTitle(product),
              const SizedBox(height: 2),

              // وصف المنتج
              _buildProductDescription(product),
              const SizedBox(height: 5),

              // سعر المنتج
              _buildProductPrice(product),
            ],
          ),
        ),

        // قائمة الإجراءات للمنتج
        if (cardWidth > 50.w) _buildProductActionsMenu(product, index),

        // زر إضافة للسلة
        _buildAddToCartButton(product, index),
      ],
    );
  }

  /// بناء عنوان المنتج
  Widget _buildProductTitle(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: cardHeight > 50.w ? cardWidth - 55 : cardWidth,
        child:
            enableTranslation
                ? _buildTranslatedText(
                  text: product.title ?? "",
                  fontSize: cardWidth > 50.w ? 15 : 12,
                  maxLines: cardWidth > 50.w ? 2 : 1,
                  textAlign:
                      cardWidth == 25.w ? TextAlign.center : TextAlign.justify,
                  fontWeight: FontWeight.bold,
                )
                : Text(
                  product.title ?? "",
                  style: titilliumSemiBold.copyWith(
                    fontSize: cardWidth > 50.w ? 15 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: cardWidth > 50.w ? 2 : 1,
                  textAlign:
                      cardWidth == 25.w ? TextAlign.center : TextAlign.start,
                ),
      ),
    );
  }

  /// بناء وصف المنتج
  Widget _buildProductDescription(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: cardHeight > 50.w ? cardWidth - 55 : cardWidth,
        child:
            enableTranslation
                ? _buildTranslatedText(
                  text: product.description ?? "",
                  fontSize: cardWidth > 50.w ? 15 : 12,
                  maxLines: cardWidth > 50.w ? 2 : 1,
                  textAlign:
                      cardWidth == 25.w ? TextAlign.center : TextAlign.justify,
                  fontWeight: FontWeight.normal,
                )
                : Text(
                  product.description ?? "",
                  style: titilliumSemiBold.copyWith(
                    fontSize: cardWidth > 50.w ? 15 : 12,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: cardWidth > 50.w ? 2 : 1,
                  textAlign:
                      cardWidth == 25.w ? TextAlign.center : TextAlign.justify,
                ),
      ),
    );
  }

  /// بناء سعر المنتج
  Widget _buildProductPrice(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TCustomWidgets.formattedPrice(
        product.price,
        cardWidth > 50.w ? 17 : 14,
        TColors.primary,
      ),
    );
  }

  /// بناء النص المترجم
  Widget _buildTranslatedText({
    required String text,
    required double fontSize,
    required int maxLines,
    required TextAlign textAlign,
    required FontWeight fontWeight,
  }) {
    return Builder(
      builder:
          (context) => FutureBuilder<String>(
            future: TranslateController.instance.translateText(
              text: text,
              targetLangCode: Localizations.localeOf(context).languageCode,
            ),
            builder: (context, snapshot) {
              final displayText =
                  snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData
                      ? snapshot.data!
                      : text;
              return Text(
                displayText,
                style: titilliumSemiBold.copyWith(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
                maxLines: maxLines,
                textAlign: textAlign,
              );
            },
          ),
    );
  }

  /// بناء قائمة إجراءات المنتج
  Widget _buildProductActionsMenu(ProductModel product, int index) {
    return Positioned(
      top: cardHeight + 18,
      right: 8,
      child: ProductActionsMenu.buildProductActionsMenu(product),
    );
  }

  /// بناء زر إضافة للسلة
  Widget _buildAddToCartButton(ProductModel product, int index) {
    return Positioned(
      top: cardWidth > 50.w ? cardHeight - 30 : cardHeight - 58,
      right: 6,
      child:
          cardWidth > 50.w
              ? DynamicCartAction(product: product)
              : GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(top: 28.0, bottom: 28),
                  child: AddToCartWidgetSmall(product: product),
                ),
              ),
    );
  }

  /// بناء مؤشر النقاط
  Widget _buildDotsIndicator(RxInt currentIndex) {
    return Positioned(
      bottom: 5,
      left: 0,
      right: 0,
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(products.length, (index) {
            bool isActive = index == currentIndex.value;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 15 : 5,
              height: 5,
              decoration: BoxDecoration(
                color:
                    isActive
                        ? TColors.primary
                        : Colors.grey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      }),
    );
  }

  /// التعامل مع النقر على المنتج
  void _handleProductTap(
    BuildContext context,
    ProductModel product,
    int index,
  ) {
    if (onProductTap != null) {
      onProductTap!(product, index);
    } else {
      // السلوك الافتراضي - فتح صفحة تفاصيل المنتج
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProductDetails(
                key: UniqueKey(),
                selected: index,
                spotList: products.obs,
                product: product,
                vendorId: '', // vendorId غير مطلوب
              ),
        ),
      );
    }
  }
}
