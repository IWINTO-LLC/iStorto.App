import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';

class PaymentMethodSelector extends StatelessWidget {
  final VendorModel vendorProfile;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const PaymentMethodSelector({
    super.key,
    required this.vendorProfile,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final availableMethods = <String>[];

    // إضافة وسائل الدفع المتاحة بناءً على إعدادات التاجر
    if (vendorProfile.enableCod == true) {
      availableMethods.add('cod');
    }
    if (vendorProfile.enableIwintoPayment == true) {
      availableMethods.add('iwinto_wallet');
    }

    // إذا لم تكن هناك وسائل دفع متاحة، استخدم الدفع عند الاستلام كافتراضي
    if (availableMethods.isEmpty) {
      availableMethods.add('cod');
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                // Icon(
                //   Icons.payment,
                //   color: TColors.primary,
                //   size: 20,
                // ),
                // const SizedBox(width: 8),
                Text(
                  'payment.method'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // خيارات وسائل الدفع
            ...availableMethods.map(
              (method) => _buildPaymentOption(
                context,
                method,
                selectedPaymentMethod == method,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String method,
    bool isSelected,
  ) {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;

    switch (method) {
      case 'cod':
        title = 'payment.cod'.tr;
        subtitle = 'payment.cod_desc'.tr;
        icon = Icons.money;
        iconColor = Colors.green;
        break;
      case 'iwinto_wallet':
        title = 'payment.iwinto_wallet'.tr;
        subtitle = 'payment.iwinto_wallet_desc'.tr;
        icon = Icons.account_balance_wallet;
        iconColor = TColors.primary;
        break;
      default:
        title = 'Unknown';
        subtitle = '';
        icon = Icons.payment;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isSelected ? TColors.primary.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? TColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onPaymentMethodChanged(method),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // أيقونة وسيلة الدفع
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),

              const SizedBox(width: 12),

              // تفاصيل وسيلة الدفع
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titilliumSemiBold.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: titilliumRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // علامة الاختيار
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? TColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? TColors.primary : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
