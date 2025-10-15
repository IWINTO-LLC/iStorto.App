import 'package:flutter/material.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class ShareButton extends StatelessWidget {
  final Color backgroundColor;

  final ProductModel product;
  final double size;
  const ShareButton({
    super.key,
    this.size = 18,
    this.backgroundColor = Colors.black,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ShareServices.shareProduct(product);

        Navigator.pop(context); // إغلاق الـ Dialog بعد الانتهاء
      },
      child: Center(
        child:
        // Transform.rotate(angle: 45,
        TRoundedContainer(
          width: size + 7,
          height: size + 7,
          radius: BorderRadius.circular(300),
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Icon(Icons.share_outlined, size: size, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
