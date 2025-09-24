import 'package:flutter/material.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';

Widget usercard(VendorModel user, BuildContext context) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.transparent,
      child: Row(
        children: [
          const SizedBox(width: 10),
          // UserProfileImageWidget(
          //   imgUrl: user.profileImage,
          //   size: 40,
          //   withShadow: false,
          //   allowChange: false,
          // ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(user.displayName)],
          ),
        ],
      ),
    ),
  );
}
