import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/edit/edit_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

class BulkMenuItem extends StatelessWidget {
  const BulkMenuItem({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(UniqueKey), // المفتاح الفريد للعنصر
      startActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              HapticFeedback.lightImpact;
              EditProductController.instance.init(product);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditProduct(
                        product: product,
                        vendorId: product.vendorId!,
                      ),
                ),
              );
            },
            foregroundColor: Colors.black,
            icon: Icons.edit,
            label: 'تعديل',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              ProductController.instance.markProductAsDeleted(
                product,
                product.vendorId!,
                false,
              );
            },
            foregroundColor: Colors.red,
            icon: Icons.delete,
            label: 'حذف',
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Row(
            children: [
              TProductImageSliderMini(
                editMode: true,
                product: product,
                enableShadow: true,
                prefferWidth: 15.w,
                prefferHeight: 15.w * (4 / 3),
                withActions: false,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: SizedBox(
                  height: 20.w * (4 / 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 60.w,
                        child: ProductController.getTitle(
                          product,
                          14,
                          2,
                          false,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: TColors.darkerGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TCustomWidgets.formattedPrice(
                            product.price,
                            14,
                            TColors.primary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              product.category?.title ?? '',
                              style: titilliumBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
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
