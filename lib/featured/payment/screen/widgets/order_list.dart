import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/screen/widgets/order_details.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

class OrderListView extends StatelessWidget {
  final List<OrderModel> orders;

  const OrderListView({required this.orders, super.key});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'order.noItem'.tr, //noItem
            style: titilliumRegular.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // يسمح للـ ListView بالاحتواء ضمن العمود
      physics: const NeverScrollableScrollPhysics(), // يمنع التمرير المزدوج
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 32.w,
                  child: Wrap(
                    children: [
                      Text(
                        "${'order.id'.tr} :${order.id}",
                        style: titilliumRegular.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      OrderController.instance.getOrderState(order),
                      style: titilliumRegular.copyWith(
                        color: OrderController.instance.getColorByState(
                          order.state,
                        ),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap:
                          () => showManageOrderBottomSheet(
                            context,
                            order.vendorId,
                            order,
                          ),
                      child: TRoundedContainer(
                        width: 30,
                        backgroundColor: Colors.black,
                        height: 30,
                        radius: BorderRadius.circular(100),
                        showBorder: true,
                        enableShadow: true,
                        child: const Icon(
                          Icons.edit,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      order.buyerDetails.profileImage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.buyerDetails.name,
                      style: titilliumRegular,
                    ),
                  ),
                  TCustomWidgets.formattedPrice(
                    order.totalPrice,
                    14,
                    TColors.primary,
                  ),
                ],
              ),
            ),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                ),
          ),
        );
      },
    );
  }
}
