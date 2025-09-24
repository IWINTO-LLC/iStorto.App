import 'package:flutter/material.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/featured/shop/follow/screens/followers_details.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

class FollowNumber extends StatelessWidget {
  const FollowNumber({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    var controller = FollowController.instance;
    return FutureBuilder<int>(
      future: controller.getFollowersCount(vendorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: TShimmerEffect(
              width: 20,
              height: 20,
              raduis: BorderRadius.circular(10),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(" "),
            ),
          );
        }
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersScreen(vendorId: vendorId),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(snapshot.data.toString()),
          ),
        );
      },
    );
  }
}
