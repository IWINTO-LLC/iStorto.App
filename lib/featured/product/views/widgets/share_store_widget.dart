import 'package:flutter/material.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';

import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class ShareButton extends StatelessWidget {
  final Color backgroundColor;

  final VendorModel vendor;
  final double size;
  const ShareButton({
    super.key,
    this.size = 18,
    this.backgroundColor = Colors.black,
    required this.vendor,
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

        await ShareServices.shareVendor(vendor);

        Navigator.pop(context);
        // var shareLink = storeSharelink + vendor.userId!;
        // final url = Uri.parse(vendor.organizationLogo!);
        // final response = await http.get(url);
        // final contentType = response.headers['content-type'];
        // final image = XFile.fromData(
        //   response.bodyBytes,
        //   mimeType: contentType,
        //   name: '',
        // );
        // await Share.shareXFiles([image],
        //     text:
        //         'Look at This Amazing Store! $shareLink    it is a  ${vendor.organizationName} ');
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
