import 'package:flutter/material.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';

import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class ShareVendorButton extends StatelessWidget {
  final Color backgroundColor;
  final String? vendorId; // إضافة vendorId كمعامل اختياري

  //final ProductModel product;
  final double size;
  const ShareVendorButton({
    super.key,
    this.size = 23,
    this.backgroundColor = Colors.black,
    this.vendorId, // إضافة vendorId
    // required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // حفظ context للاستخدام الآمن
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          // الحصول على بيانات المتجر
          VendorModel vendorData;

          if (vendorId != null) {
            // إذا تم تمرير vendorId، احصل على البيانات مباشرة
            vendorData = await VendorController.instance
                .fetchVendorreturnedData(vendorId!);
          } else {
            // استخدم البيانات المخزنة في الكنترولر
            vendorData = VendorController.instance.vendorData.value;
          }

          // فحص إذا كانت البيانات صحيحة
          if (vendorData.userId == null || vendorData.userId!.isEmpty) {
            if (context.mounted) {
              Navigator.pop(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    '❌ لا يمكن مشاركة هذا المتجر - بيانات غير متوفرة',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          await ShareServices.shareVendor(vendorData);
          if (context.mounted) {
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('❌ خطأ في المشاركة: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Center(
        child:
        // Transform.rotate(angle: 45,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TRoundedContainer(
            width: size + 5,
            height: size + 5,
            backgroundColor: Colors.black.withValues(alpha: .5),
            radius: BorderRadius.circular(100),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0, right: 5),
                child: Icon(
                  Icons.share_outlined,
                  size: size - 5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
