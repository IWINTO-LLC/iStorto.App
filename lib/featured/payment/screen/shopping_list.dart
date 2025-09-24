import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/screen/widgets/order_details.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/texts/copy_able.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class ShoppingList extends StatelessWidget {
  const ShoppingList({super.key});

  @override
  Widget build(BuildContext context) {
    final authController =
        Get.find(); // or provide your own way to get authController
    return Scaffold(
      appBar: CustomAppBar(title: 'order.myOrders'.tr),
      body: SafeArea(
        child: FutureBuilder<List<OrderModel>>(
          future: OrderController.instance.fetchUserOrders(
            authController.user.id,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: TLoaderWidget());
            final orders = snapshot.data!;
            if (orders.isEmpty) return Center(child: Text('order.noItem'.tr));

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CopyableText(
                              text: order.id ?? '',
                              child: Text(
                                "${'order.id'.tr} : ${order.id ?? ''}",
                                style: titilliumBold.copyWith(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TCustomWidgets.formattedPrice(
                              order.totalPrice,
                              16,
                              TColors.primary,
                            ),
                          ],
                        ),
                        trailing: Text(
                          OrderController.instance.getOrderState(order),
                          style: titilliumRegular.copyWith(
                            color: OrderController.instance.getColorByState(
                              order.state,
                            ),
                            fontSize: 16,
                          ),
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        OrderDetailsScreen(order: order),
                              ),
                            ),
                      ),
                      TCustomWidgets.buildDivider(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
