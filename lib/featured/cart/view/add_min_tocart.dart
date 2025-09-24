import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/constant.dart';

class AddMinusToCartWidget extends StatelessWidget {
  final ProductModel product;
  final bool withShadows;
  final double size;

  const AddMinusToCartWidget({
    super.key,
    required this.product,
    required this.size,
    this.withShadows = true,
  });

  void _showQuantityDialog(
    BuildContext context,
    CartController cartController,
    int currentQuantity,
  ) {
    final TextEditingController quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('cart.set_quantity'.tr, style: titilliumBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: titilliumBold.copyWith(fontSize: 18),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'cart.enter_quantity'.tr,
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'cart.cancel'.tr,
                style: titilliumBold.copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newQuantity = int.tryParse(quantityController.text) ?? 0;
                if (newQuantity >= 0) {
                  if (newQuantity == 0) {
                    cartController.removeFromCart(product);
                  } else {
                    // تحديث الكمية مباشرة
                    final index = cartController.cartItems.indexWhere(
                      (item) => item.product.id == product.id,
                    );
                    if (index != -1) {
                      cartController.cartItems[index].quantity = newQuantity;
                    } else {
                      cartController.cartItems.add(
                        CartItem(product: product, quantity: newQuantity),
                      );
                    }

                    // تحديث البيانات بدون إعادة تحميل الشاشة
                    cartController.cartItems.refresh();
                    cartController.productQuantities[product.id]?.value =
                        newQuantity;
                    cartController.getTotalItems();
                    cartController.updateSelectedTotalPrice();

                    // حفظ البيانات في الخلفية
                    Future.microtask(() {
                      cartController.saveCartToSupabase();
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'cart.confirm'.tr,
                style: titilliumBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    return TapRegion(
      onTapInside: (_) => cartController.setTapInside(product.id, true),
      onTapOutside: (_) => cartController.setTapInside(product.id, false),
      child: TRoundedContainer(
        width: (size - 5) * 4,
        height: size,
        radius: cartRadius,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AbsorbPointer(
                absorbing: false,
                child: InkWell(
                  onTap: () => cartController.addToCart(product),
                  child: TRoundedContainer(
                    width: size,
                    height: size,
                    showBorder: true,
                    radius: BorderRadius.circular(40),
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(
                      CupertinoIcons.add,
                      size: size - 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    final quantity =
                        cartController.productQuantities[product.id]?.value ??
                        0;
                    _showQuantityDialog(context, cartController, quantity);
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Obx(() {
                      final quantity =
                          cartController.productQuantities[product.id]?.value ??
                          0;
                      return Text(
                        '$quantity',
                        style: titilliumBold.copyWith(
                          fontFamily: numberFonts,
                          fontSize: (size - 5) / 2,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              AbsorbPointer(
                absorbing: false,
                child: InkWell(
                  onTap: () {
                    final quantity =
                        cartController.productQuantities[product.id]?.value ??
                        0;
                    if (quantity > 0) {
                      cartController.decreaseQuantity(product);
                    }
                  },
                  child: TRoundedContainer(
                    width: size,
                    height: size,
                    showBorder: true,
                    radius: BorderRadius.circular(40),
                    backgroundColor: Colors.grey.shade100,
                    child: Obx(() {
                      final quantity =
                          cartController.productQuantities[product.id]?.value ??
                          0;
                      final canDecrease = quantity > 0;
                      return Icon(
                        CupertinoIcons.minus,
                        size: size - 15,
                        color: canDecrease ? Colors.black : Colors.grey,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
