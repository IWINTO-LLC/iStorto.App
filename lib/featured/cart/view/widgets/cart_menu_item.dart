import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/product/views/widgets/bottom_add_tocart.dart';
import 'package:istoreto/featured/product/views/widgets/one_product_details.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

class CartMenuItem extends StatelessWidget {
  const CartMenuItem({super.key, required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    return Slidable(
      key: ValueKey(item.product.id),

      // مؤشر السحب من اليسار (أخضر للحفظ)
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            SavedController.instance.saveProduct(item.product);
            cartController.removeFromCart(item.product);
          },
        ),
        children: [
          SlidableAction(
            onPressed: null,
            foregroundColor: Colors.green,

            icon: Icons.save,
            // label: 'Save For later',
          ),
        ],
      ),

      // مؤشر السحب من اليمين (أحمر للحذف)
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            cartController.removeFromCart(item.product);
          },
        ),
        children: [
          SlidableAction(
            onPressed: null,
            foregroundColor: Colors.red,

            icon: Icons.delete,

            // label: 'حذف',
          ),
        ],
      ),

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Obx(() {
                final isSelected =
                    cartController.selectedItems[item.product.id] ?? false;
                final quantity =
                    cartController.productQuantities[item.product.id]?.value ??
                    0;
                final totalPrice = quantity * (item.product.price);

                return Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              isSelected ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Checkbox(
                        activeColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        value: isSelected,
                        onChanged: (value) {
                          cartController.selectedItems[item.product.id] =
                              value ?? false;
                          cartController.updateSelectedTotalPrice();
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // صورة المنتج بالأبعاد الأصلية
                    GestureDetector(
                      onTap: () {
                        if (item.product.vendorId == null) {
                          Get.snackbar(
                            'error'.tr,
                            'vendor_not_found'.tr,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Scaffold(
                                  bottomSheet: BottomAddToCart(
                                    product: item.product,
                                  ),
                                  body: SafeArea(
                                    child: ProductDetailsPage(
                                      product: item.product,
                                      edit: false,
                                      vendorId: item.product.vendorId!,
                                    ),
                                  ),
                                ),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50 * (4 / 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              (item.product.images.isNotEmpty)
                                  ? CustomCaChedNetworkImage(
                                    width: 40,
                                    height: 40 * (4 / 3),
                                    fit: BoxFit.cover,
                                    url: item.product.images.first,
                                    raduis: BorderRadius.circular(8),
                                  )
                                  : Container(
                                    width: 40,
                                    height: 40 * (4 / 3),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // تفاصيل المنتج
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (item.product.vendorId == null) {
                            Get.snackbar(
                              'error'.tr,
                              'vendor_not_found'.tr,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Scaffold(
                                    body: SafeArea(
                                      child: ProductDetailsPage(
                                        product: item.product,
                                        edit: false,
                                        vendorId: item.product.vendorId!,
                                      ),
                                    ),
                                  ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // عنوان المنتج
                            Wrap(
                              children: [
                                Text(
                                  item.product.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // السعر والكمية
                            Row(
                              children: [
                                // السعر الإجمالي
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: TCustomWidgets.formattedCartPrice(
                                    totalPrice,
                                    16,
                                    Colors.black87,
                                  ),
                                ),

                                //  const SizedBox(width: 2),

                                // الكمية
                                //     Container(
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 8, vertical: 4),
                                //       decoration: BoxDecoration(
                                //         color: Colors.grey.shade50,
                                //         borderRadius: BorderRadius.circular(6),
                                //         border: Border.all(color: Colors.grey.shade200),
                                //       ),
                                //       child: Row(
                                //         mainAxisSize: MainAxisSize.min,
                                //         children: [
                                //           Icon(
                                //             Icons.shopping_bag_outlined,
                                //             size: 14,
                                //             color: Colors.grey.shade600,
                                //           ),
                                //           const SizedBox(width: 4),
                                //           Text(
                                //             "$quantity",
                                //             style: TextStyle(
                                //               fontSize: 12,
                                //               fontWeight: FontWeight.w600,
                                //               color: Colors.grey.shade700,
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    //const SizedBox(width: 12),
                    DynamicCartAction(
                      product: item.product,
                      // withShadows: false,
                    ),
                  ],
                );
              }),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 0, // ارتفاع صفر في الحالة العادية
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.red],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            //TCustomWidgets.buildDivider()
          ],
        ),
      ),
    );
  }
}
