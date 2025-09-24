import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/featured/shop/follow/screens/widgets/user_card.dart';
import 'package:istoreto/models/user_model.dart';
import 'package:istoreto/utils/common/widgets/anime_empty_logo.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key, required this.vendorId});
  final String vendorId;
  @override
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(FollowController());
    return Scaffold(
      appBar: CustomAppBar(title: "Followers".tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 16,
            left: 10,
            right: 10,
          ),
          child: FutureBuilder<List<UserModel>>(
            future: controller.getFollowers(vendorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: TLoaderWidget());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const AnimeEmptyLogo();
              } else {
                var data = snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return usercard(data[index] as VendorModel, context);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
