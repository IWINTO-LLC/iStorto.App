import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class SavedButton extends StatelessWidget {
  final Color backgroundColor;
  final ProductModel product;
  final double size;

  const SavedButton({
    super.key,
    this.size = 18,
    this.backgroundColor = Colors.black,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SavedController>(
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            if (controller.isSaved(product.id)) {
              controller.removeProduct(product);
            } else {
              controller.saveProduct(product);
            }
          },
          child: Center(
            child: TRoundedContainer(
              width: size + 7,
              height: size + 7,
              radius: BorderRadius.circular(300),
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Obx(() {
                  final isSaved = controller.isSaved(product.id);
                  return Icon(
                    isSaved ? Icons.bookmark_outlined : Icons.bookmark_border,
                    size: size,
                    color: Colors.black,
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
