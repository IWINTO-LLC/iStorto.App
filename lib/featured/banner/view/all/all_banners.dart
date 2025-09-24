import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/view/all/widgets/banner_list_item.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/larg_listTileShimmer.dart';
import 'package:sizer/sizer.dart';

class BannersMobileScreen extends StatelessWidget {
  const BannersMobileScreen({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final controller = BannerController.instance;
    controller.fetchBanners(vendorId);

    // final banners = controller.fetchBanners();
    return Directionality(
      textDirection:
          TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        floatingActionButton: CustomFloatActionButton(
          onTap: () => controller.addBanner('gallery', vendorId),
        ),
        appBar: CustomAppBar(title: 'shop.allBanners'),

        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(() {
                  if (controller.loading.value) {
                    return const TLargListTilehummer();
                  } else if (controller.banners.isEmpty) {
                    return Center(
                      child: SizedBox(
                        height: 300,
                        width: 80.w,
                        child: Center(
                          child: Text(
                            "banner.no_banners".tr,
                            style: titilliumBold.copyWith(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Obx(
                      () => ListView.separated(
                        separatorBuilder:
                            (_, __) => TCustomWidgets.buildDivider(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.banners.length,
                        itemBuilder:
                            (_, index) => TBannerItem(
                              banner: controller.banners[index],
                              vendorId: vendorId,
                            ),
                      ),
                    );
                  }
                }),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
