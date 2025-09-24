import 'package:flutter/material.dart';
import 'package:istoreto/featured/orders/controller/export_helper.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class ShareOrderWidget extends StatelessWidget {
  const ShareOrderWidget({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ExportHelper.exportOrderDetailsAsPDF(order, context),
      child: TRoundedContainer(
        width: 35,
        height: 35,
        enableShadow: true,
        showBorder: true,
        radius: BorderRadius.circular(300),
        child: const Center(
          child: Icon(Icons.share_outlined, size: 25, color: Colors.black),
        ),
      ),
    );
  }
}
