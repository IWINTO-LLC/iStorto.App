import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/all_select_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';

class ListSelected extends StatelessWidget {
  const ListSelected({super.key, required this.products});
  final List<ProductModel> products;
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductSelectedController());
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Obx(
          () => Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              leading: Image.network(
                product.images.first,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(product.title),
              subtitle: Text(
                product.category == null ? "بدون فئة" : product.category!.title,
              ),
              trailing:
                  controller.isSelecting.value
                      ? Checkbox(
                        value: controller.selectedProducts.contains(product.id),
                        onChanged: (value) {
                          controller.toggleSelection(product.id);
                        },
                      )
                      : null, // لا تظهر الـ Checkbox إذا كان وضع التحديد غير مفعل
              onLongPress: () {
                controller.startSelectionMode(product.id);
              },
            ),
          ),
        );
      },
    );
  }
}
