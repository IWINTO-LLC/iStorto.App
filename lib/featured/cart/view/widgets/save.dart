import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/save_for_later.dart';
import 'package:istoreto/utils/common/widgets/anime_empty_logo.dart';

class SaveForLaterScreen extends StatelessWidget {
  final controller = SaveForLaterController.instance;

  SaveForLaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // عنوان الصفحة
              // const Text(
              //   "العناصر المحفوظة لاحقًا",
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              const SizedBox(height: 12),

              // زر إضافة الكل
              Obx(
                () => Visibility(
                  visible: controller.savedItems.isNotEmpty,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: controller.addAllToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("إضافة الكل إلى السلة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // القائمة
              Expanded(
                child: Obx(() {
                  if (controller.savedItems.isEmpty) {
                    return const Center(child: AnimeEmptyLogo());
                  }

                  return ListView.builder(
                    itemCount: controller.savedItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.savedItems[index];
                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => controller.addToCart(item),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Image.network(
                              item.product.images.first,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(item.product.title),
                            subtitle: Text("الكمية: ${item.quantity}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed:
                                  () => controller.removeItem(item.product.id),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
