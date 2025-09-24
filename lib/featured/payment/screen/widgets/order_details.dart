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
                        "${OrderController.instance.getOrderState(order)}",
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
                    order.locationLat != null && order.locationLat != ""
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

  Widget _buildEditSection(BuildContext context) {
    // التحقق من إمكانية التعديل بناءً على حالة الطلب
    bool canEditAddress =
        order.state == '0' || order.state == '1'; // غير معروف أو تم الدفع
    bool canEditPhone = true; // يمكن تعديل رقم الهاتف دائماً
    bool canEditPayment =
        order.state == '0'; // يمكن تعديل أسلوب الدفع فقط في حالة غير معروف

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order.edit_order'.tr,
          style: titilliumBold.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),

        // تعديل العنوان
        _buildEditButton(
          context: context,
          icon: Icons.location_on,
          title: 'order.edit_address'.tr,
          subtitle: order.fullAddress!,
          enabled: canEditAddress,
          onTap: canEditAddress ? () => _editAddress(context) : null,
          disabledMessage: 'لا يمكن تعديل العنوان بعد بدء التحضير',
        ),

        const SizedBox(height: 12),

        // تعديل رقم الهاتف
        _buildEditButton(
          context: context,
          icon: Icons.phone,
          title: 'order.edit_phone'.tr,
          subtitle: order.phoneNumber!,
          enabled: canEditPhone,
          onTap: canEditPhone ? () => _editPhone(context) : null,
        ),

        const SizedBox(height: 12),

        // تعديل أسلوب الدفع
        _buildEditButton(
          context: context,
          icon: Icons.payment,
          title: 'order.edit_payment'.tr,
          subtitle: order.paymentMethod,
          enabled: canEditPayment,
          onTap: canEditPayment ? () => _editPaymentMethod(context) : null,
          disabledMessage: 'لا يمكن تعديل أسلوب الدفع بعد الدفع',
        ),
      ],
    );
  }

  Widget _buildEditButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    VoidCallback? onTap,
    String? disabledMessage,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? Colors.white : Colors.grey.shade50,
      ),
      child: InkWell(
        onTap:
            enabled
                ? onTap
                : () => _showDisabledMessage(context, disabledMessage),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled ? TColors.primary : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: enabled ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color:
                            enabled
                                ? Colors.grey.shade700
                                : Colors.grey.shade500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.edit : Icons.lock,
                color: enabled ? TColors.primary : Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editAddress(BuildContext context) {
    // TODO: تنفيذ تعديل العنوان
    Get.snackbar(
      'تعديل العنوان',
      'سيتم إضافة هذه الميزة قريباً',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editPhone(BuildContext context) {
    // TODO: تنفيذ تعديل رقم الهاتف
    Get.snackbar(
      'تعديل رقم الهاتف',
      'سيتم إضافة هذه الميزة قريباً',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editPaymentMethod(BuildContext context) {
    // TODO: تنفيذ تعديل أسلوب الدفع
    Get.snackbar(
      'تعديل أسلوب الدفع',
      'سيتم إضافة هذه الميزة قريباً',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showDisabledMessage(BuildContext context, String? message) {
    if (message != null) {
      Get.snackbar(
        'تنبيه',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
      );
    }
  }
}
