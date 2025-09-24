import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';

class FavoriteVendors extends StatelessWidget {
  final String userId;
  final FollowController controller = Get.put(FollowController());

  FavoriteVendors({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المتاجر التي تتابعها")),
      body: SafeArea(
        child: FutureBuilder<List<VendorModel>>(
          future: controller.getFollowing(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("لم تقم بمتابعة أي متجر"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(snapshot.data![index].displayName),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
