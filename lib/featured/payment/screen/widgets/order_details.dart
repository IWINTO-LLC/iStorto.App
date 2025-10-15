import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/screen/widgets/share_order.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/navigation_menu.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/texts/copy_able.dart';
import 'package:istoreto/utils/constants/color.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order.details'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              CopyableText(
                text: order.id!,
                child: Text(
                  "${'order.id'.tr}: ${order.id}",
                  style: titilliumBold.copyWith(fontSize: 17),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TRoundedContainer(
                    // enableShadow: true,
                    radius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        OrderController.instance.getOrderState(order),
                        style: titilliumBold.copyWith(
                          color: OrderController.instance.getColorByState(
                            order.state,
                          ),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  ShareOrderWidget(order: order),
                  SizedBox(width: 16),
                ],
              ),

              // بيانات الزبون
              ListTile(
                leading: TRoundedContainer(
                  radius: BorderRadius.circular(300),
                  showBorder: true,
                  width: 40,
                  height: 40,
                  child: CustomCaChedNetworkImage(
                    width: 40,
                    height: 40,
                    url: order.buyerDetails.profileImage,
                    raduis: BorderRadius.circular(300),
                  ),
                ),
                title: Text(order.buyerDetails.name),
                subtitle: Text(order.phoneNumber!),
                onTap: () {},
              ),

              // عنوان وموقع
              ListTile(
                leading: TRoundedContainer(
                  radius: BorderRadius.circular(100),
                  enableShadow: true,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.location_on, color: Colors.black),
                  ),
                ),
                title: Text(order.fullAddress!),
                subtitle: Text(order.buildingNumber!),
                trailing:
                    order.locationLat != null
                        ? TRoundedContainer(
                          radius: BorderRadius.circular(100),
                          enableShadow: true,
                          child: IconButton(
                            icon: const Icon(Icons.map, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          //  OrderMapPreviewScreen(
                                          // location: LatLng(
                                          //   double.parse(order.locationLat!),
                                          //   double.parse(order.locationLng!),
                                          NavigationMenu(),
                                ),
                              );
                            },
                          ),
                        )
                        : null,
              ),

              const Divider(),

              // // أزرار التعديل للمستخدم
              // if (isUserOrder) ...[
              //   _buildEditSection(context),
              //   const Divider(),
              // ],

              // المنتجات
              Text("${'order.products'.tr} :", style: titilliumBold),
              // ...order.productList.map(
              //   (item) => CartStaticMenuItem(item: item),
              // ),
              ListTile(
                leading: const Icon(Icons.date_range, color: Colors.black),
                title: Text(
                  "${'order.date'.tr}: ${order.orderDate.toLocal()}",
                  style: titilliumBold.copyWith(fontSize: 17),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.money, color: Colors.black),
                title: Row(
                  children: [
                    TCustomWidgets.formattedPrice(
                      order.totalPrice,
                      20,
                      TColors.primary,
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
