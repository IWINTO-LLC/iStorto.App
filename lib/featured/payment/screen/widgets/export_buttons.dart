import 'package:flutter/material.dart';
import 'package:istoreto/featured/orders/controller/export_helper.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class ExportButtonsRow extends StatelessWidget {
  final List<OrderModel> orders;

  const ExportButtonsRow({required this.orders, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TRoundedContainer(
          radius: BorderRadius.circular(100),
          enableShadow: true,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                ExportHelper.exportAsPDF(
                  orders,
                  VendorController.instance.profileData.value,
                  context,
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf, size: 18, color: Colors.black),
                  SizedBox(width: 5),
                  Text("PDF", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TRoundedContainer(
          radius: BorderRadius.circular(100),
          enableShadow: true,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () => ExportHelper.exportAsExcel(context, orders),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.table_chart, size: 18, color: Colors.black),
                  SizedBox(width: 5),
                  Text("Excel", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
