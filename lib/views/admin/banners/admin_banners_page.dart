import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/admin/banners/controllers/helper_functions.dart';
import 'package:istoreto/views/admin/banners/widgets/banner_contents.dart';

class AdminBannersPage extends StatefulWidget {
  const AdminBannersPage({super.key});

  @override
  State<AdminBannersPage> createState() => _AdminBannersPageState();
}

class _AdminBannersPageState extends State<AdminBannersPage> {
  late final BannerController _bannerController;

  @override
  void initState() {
    super.initState();
    // تهيئة الـ controller
    _bannerController = Get.put(BannerController());
    // تحميل البيانات
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    await _bannerController.fetchAllBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'banner_management'.tr,
        centerTitle: true,
        actions: [
          // زر إعادة التحميل
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBanners,
            tooltip: 'reload'.tr,
          ),
        ],
      ),
      body: Obx(() {
        // حالة التحميل
        if (_bannerController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'loading',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // عرض المحتوى
        return RefreshIndicator(
          onRefresh: _loadBanners,
          child: const BannersContent(),
        );
      }),
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
