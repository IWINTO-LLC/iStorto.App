import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/dialog/confirmation_dialog.dart';

import '../../../../../utils/constants/image_strings.dart';

class TBannerItem extends StatelessWidget {
  TBannerItem({super.key, required this.banner, required this.vendorId});
  final BannerModel banner;
  final String vendorId;
  final controller = BannerController.instance;
  final renderOverlay = true;
  final visible = true;
  final switchLabelPosition = false;
  final extend = false.obs;
  final mini = false;
  final customDialRoot = false;
  final closeManually = false;
  final useRAnimation = true;
  final isDialOpen = ValueNotifier<bool>(false);
  final speedDialDirection =
      TranslationController.instance.isRTL
          ? SpeedDialDirection.right
          : SpeedDialDirection.left;
  final buttonSize = const Size(35.0, 35.0);
  final childrenButtonSize = const Size(45.0, 45.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 364,
        height: 214,
        child: Slidable(
          key: const ValueKey(0),
          endActionPane: ActionPane(
            extentRatio: .6,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                onPressed: (context) {
                  banner.active = !banner.active;
                  controller.updateStatus(banner, vendorId);
                },
                flex: 2,
                borderRadius: BorderRadius.circular(10),
                autoClose: true,
                // backgroundColor: TColors.primary.withOpacity(.2),
                foregroundColor:
                    banner.active == true ? Colors.red : Colors.green,
                padding: const EdgeInsets.all(10),
                spacing: 2,
                icon: CupertinoIcons.power,

                label:
                    banner.active == true
                        ? "banner.deactivate".tr
                        : "banner.activate".tr,
              ),
              SlidableAction(
                onPressed:
                    (context) => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                          icon: TImages.deleteProduct,
                          refund: false,
                          description: "banner.delete_confirmation".tr,
                          onYesPressed:
                              () => controller.deleteBanner(banner, vendorId),
                        );
                      },
                    ),
                //backgroundColor: TColors.red.withOpacity(.3),
                foregroundColor: Colors.red,
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.all(3),
                autoClose: true,
                icon: Icons.delete,
                label: "banner.delete".tr,
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8,
                  ),
                  child: Stack(
                    children: [
                      CustomCaChedNetworkImage(
                        url: banner.image,
                        width: 364,
                        height: 214,
                        raduis: BorderRadius.circular(15),
                        // height: 180,
                        //  height: 180,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Align(
                  alignment:
                      Get.locale?.languageCode == 'ar'
                          ? Alignment.topLeft
                          : Alignment.topRight,
                  child: SpeedDial(
                    overlayOpacity: 0,
                    icon: Icons.more_vert,
                    iconTheme: const IconThemeData(size: 30),
                    activeIcon: Icons.close,
                    spacing: 0,
                    mini: mini,
                    openCloseDial: isDialOpen,
                    childPadding: const EdgeInsets.all(3),
                    spaceBetweenChildren: 4,
                    buttonSize: buttonSize,
                    childrenButtonSize: childrenButtonSize,
                    visible: visible,
                    direction: speedDialDirection,
                    switchLabelPosition: switchLabelPosition,
                    closeManually: false,
                    renderOverlay: renderOverlay,
                    useRotationAnimation: useRAnimation,
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: TColors.black,
                    elevation: 0,
                    animationCurve: Curves.elasticInOut,
                    isOpenOnStart: false,
                    shape:
                        customDialRoot
                            ? const RoundedRectangleBorder()
                            : const StadiumBorder(),
                    onOpen: () {
                      extend.value = true;
                    },
                    onClose: () {
                      extend.value = false;
                    },
                    children: [
                      SpeedDialChild(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              banner.active == true
                                  ? Icon(
                                    CupertinoIcons.power,
                                    color: Colors.red,
                                  )
                                  : Icon(
                                    CupertinoIcons.power,
                                    color: Colors.green,
                                  ),
                        ),
                        onTap: () {
                          banner.active = !banner.active;
                          controller.updateStatus(banner, vendorId);
                        },
                      ),
                      SpeedDialChild(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            TImages.delete,
                            color: TColors.black,
                          ),
                        ),
                        onTap:
                            () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmationDialog(
                                  icon: TImages.deleteProduct,
                                  refund: false,
                                  description: "banner.delete_confirmation".tr,
                                  onYesPressed:
                                      () => controller.deleteBanner(
                                        banner,
                                        vendorId,
                                      ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
