import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/admin/banners/controllers/helper_functions.dart';
import 'package:istoreto/views/admin/banners/widgets/banner_contents.dart';
import 'package:sizer/sizer.dart';

class AdminBannersPage extends StatelessWidget {
  const AdminBannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController bannerController = Get.put(BannerController());

    // تحميل البيانات عند بناء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bannerController.fetchAllBanners();
    });

    return Scaffold(
      appBar: CustomAppBar(title: 'banner_management'.tr, centerTitle: true),
      body: BannersContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddBannerDialog(context),
        backgroundColor: TColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'add_banner'.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
