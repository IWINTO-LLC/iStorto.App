import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:istoreto/featured/custom_Excel_menu/controller/bulk_excel_product_control.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/edit/edit_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/logging/logger.dart';
import 'package:sizer/sizer.dart';

class BulkEXcelMenuItem extends StatefulWidget {
  const BulkEXcelMenuItem({super.key, required this.product});

  final ProductModel product;

  @override
  State<BulkEXcelMenuItem> createState() => _BulkEXcelMenuItemState();
}

class _BulkEXcelMenuItemState extends State<BulkEXcelMenuItem> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(UniqueKey), // المفتاح الفريد للعنصر
      startActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              try {
                // HapticFeedback.lightImpact;
                EditProductController.instance.initTemp(widget.product);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProduct(
                          product: widget.product,
                          vendorId: widget.product.vendorId!,
                          isTemp: true,
                        ),
                  ),
                );
              } catch (e) {
                TLoggerHelper.error(e.toString());
              }
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
            onPressed: (context) async {
              ProductControllerExcel().deleteOneProduct(
                widget.product,
                widget.product.vendorId!,
              );
            },
            foregroundColor: Colors.red,
            icon: Icons.delete,
            label: 'حذف',
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
        child: TRoundedContainer(
          //  showBorder: true,
          // radius: BorderRadius.circular(15),
          //  backgroundColor: TColors.lightContainer,
          child: GestureDetector(
            onTap: () {
              EditProductController.instance.init(widget.product);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditProduct(
                        product: widget.product,
                        vendorId: widget.product.vendorId!,
                        isTemp: true,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Row(
                children: [
                  TProductImageSliderMini(
                    editMode: true,
                    product: widget.product,
                    prefferWidth: 15.w,
                    enableShadow: true,
                    prefferHeight: 15.w * (4 / 3),
                    withActions: false,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 60.w,
                          child: ProductController.getTitle(
                            widget.product,
                            14,
                            2,
                            false,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 60.w,
                          child: Text(
                            widget.product.description ?? '',
                            style: robotoRegular.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: TColors.darkerGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TCustomWidgets.formattedPrice(
                              widget.product.price,
                              14,
                              TColors.primary,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: Text(widget.product.category!.title),
                              // FutureBuilder<String>(
                              //   future: _getCategoryTitle(
                              //     widget.product.category?.id,
                              //   ),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState ==
                              //         ConnectionState.waiting) {
                              //       return SizedBox(
                              //         width: 60,
                              //         height: 16,
                              //         child: CircularProgressIndicator(
                              //           strokeWidth: 2,
                              //           valueColor:
                              //               AlwaysStoppedAnimation<Color>(
                              //                 TColors.primary,
                              //               ),
                              //         ),
                              //       );
                              //     }

                              //     return Text(
                              //       snapshot.data ??
                              //           widget.product.categoryId ??
                              //           'Unknown',
                              //       style: titilliumBold,
                              //       maxLines: 1,
                              //       overflow: TextOverflow.ellipsis,
                              //     );
                              //   },
                              // ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
