import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/view/widgets/control_panel_menu.dart';
import 'package:istoreto/navigation_menu.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/cart/view/cart_screen.dart';
import 'package:istoreto/featured/cart/view/cart_widget.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:istoreto/featured/product/views/all_products_view.dart';

import 'package:istoreto/featured/shop/follow/screens/followers_details.dart';
import 'package:istoreto/featured/shop/follow/screens/widgets/follow_heart.dart';
import 'package:istoreto/featured/shop/follow/screens/widgets/follower_number.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/featured/shop/view/widgets/control_panel_menu_visitor.dart';
import 'package:istoreto/featured/shop/view/widgets/control_panel_popupMenu.dart';
import 'package:istoreto/featured/shop/view/widgets/share_vendor_widget.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_social_bar.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/display_image_full.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';

Widget marketHeaderSection(String userId, bool editMode, bool isVendor) {
  bool fetchingExclusive = false;

  return Obx(() {
    VendorController.instance.fetchVendorData(userId);

    //  print(" nname ${userMap['organizationName']}");
    if (VendorController.instance.isLoading.value) {
      return TLoaderWidget();
    } else if (VendorController.instance.vendorData.value !=
        VendorModel.empty()) {
      // Handle no data state
      return Center(child: Text('user_profile_top_section.user_not_found'.tr));
    } else {
      final userMap = VendorController.instance.profileData.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 33.h + 10,
                color: Colors.transparent,
              ),
              if (userMap.bannerImage != 'loading')
                userMap.bannerImage == ''
                    ? Container(
                      width: 100.w,
                      height: 33.h + 10,
                      color: Colors.grey,
                    )
                    : Stack(
                      children: [
                        Container(
                          color: Colors.transparent,
                          height: 37.5.h,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () async {
                                if (editMode) {
                                  // await uploadorganizationBannerImageAndSaveToFirestore(
                                  //   context,
                                  //   userId,
                                  // );
                                  // uploadOrgnizationBannerImageAndSaveToFirestore(
                                  //     context, ref);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             MarketPlaceManagment(
                                  //                 vendorId: userId,
                                  //                 editMode: true)));
                                } else {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (
                                  //           context,
                                  //         ) => NetworkImageFullScreen(
                                  //           userMap!['organizationCover'] ??
                                  //               userMap['bannerImage'] ??
                                  //               '',
                                  //         ),
                                  //   ),
                                  // );
                                }
                              },
                              child: SizedBox(
                                width: 100.w,
                                height: 33.h,
                                child:
                                    userMap.organizationCover == 'loading'
                                        ? TShimmerEffect(
                                          baseColor: TColors.lightgrey,
                                          width: 100.w,
                                          height: 28.h,
                                        )
                                        : ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: userMap.organizationCover,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                            placeholder:
                                                (context, url) =>
                                                    TShimmerEffect(
                                                      width: 100.w,
                                                      height: 33.h,
                                                      baseColor:
                                                          TColors.lightgrey,
                                                    ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      width: 100.w,
                                                      height: 33.h,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),

                        //
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              right: 4,
                              top: 2,
                              bottom: 10,
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.to(() => CartScreen()),

                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: CartWidget(),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isVendor && !editMode,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: GestureDetector(
                                          onTap:
                                              () => Get.to(
                                                () => MarketPlaceManagment(
                                                  vendorId: userId,
                                                  editMode: true,
                                                ),
                                              ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                            ),
                                            child: TRoundedContainer(
                                              radius: BorderRadius.circular(
                                                100,
                                              ),
                                              width: 35,
                                              height: 35,
                                              backgroundColor: TColors.primary,
                                              child: const Icon(
                                                Icons.settings,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          left: 0,
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: GestureDetector(
                                    onTap:
                                        () =>
                                            editMode
                                                ? Get.to(() => NavigationMenu())
                                                : Get.to(
                                                  () => NavigationMenu(),
                                                ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                      ),
                                      child: TRoundedContainer(
                                        width: 30,
                                        height: 30,
                                        backgroundColor: Colors.black
                                            .withValues(alpha: .5),
                                        //  enableShadow: true,
                                        radius: BorderRadius.circular(100),
                                        child: const Center(
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            textDirection: TextDirection.ltr,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8,
                                ),
                                child: ShareVendorButton(
                                  size: 25,
                                  vendorId: userId, // تمرير vendorId
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 26,
                          right: 70,
                          child: itemCount(userId, Get.context!),
                        ),
                        Positioned(
                          right: 14,
                          bottom: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: //true,
                                    (userMap.isSubscriber) && (userMap.isRoyal),
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: TColors.tboxShadow,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(
                                          255,
                                          208,
                                          183,
                                          132,
                                        ), // Satin Sheen Gold
                                        TColors.gold, // Sunray
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),

                                      child: Icon(FontAwesomeIcons.crown),
                                      // child: SvgPicture.asset(
                                      //   width: 25,
                                      //   height: 25,
                                      //   color: Colors.white,
                                      //   'assets/images/ecommerce/icons/royal.svg',
                                      // ),
                                    ),
                                  ),
                                ),
                              ),

                              // Visibility(
                              //     visible: //true,
                              //         (userMap["isSubscriber"] ??
                              //                 false == true) &&
                              //             (userMap["isRoyal"] ??
                              //                 false == true),
                              //     child: const SizedBox(
                              //       height: 0,
                              //     )),

                              // if (!isVendor &&
                              //     (userMap['inExclusive']) == true)
                              if (!isVendor && userMap.inExclusive)
                                Visibility(
                                  visible: !editMode,
                                  child: const SizedBox(height: 10),
                                ),

                              if (!isVendor && userMap.inExclusive)
                                Visibility(
                                  visible: !editMode,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (fetchingExclusive) return;
                                      fetchingExclusive = true;
                                      try {
                                        HapticFeedback.lightImpact;
                                        // Here we need to go to exclusive
                                        log('Attempting to view offer');
                                      } finally {
                                        fetchingExclusive = false;
                                      }
                                    },
                                    child: TRoundedContainer(
                                      width: 35,
                                      height: 35,
                                      radius: BorderRadius.circular(300),
                                      backgroundColor: TColors.white,
                                      child: const Center(
                                        child: Icon(
                                          CupertinoIcons.star_fill,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              if (!isVendor && userMap.inExclusive)
                                Visibility(
                                  visible: !editMode,
                                  child: const SizedBox(height: 10),
                                ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact;
                                },
                                child: TRoundedContainer(
                                  radius: BorderRadius.circular(50),
                                  width: 37,
                                  height: 37,
                                  showBorder: true,
                                  borderColor: Colors.white,
                                  borderWidth: 2, //profileImage
                                  // backgroundColor: Colors.transparent,
                                  child: FreeCaChedNetworkImage(
                                    url: userMap.organizationLogo,
                                    raduis: BorderRadius.circular(100),
                                  ),
                                  // const Padding(
                                  //   padding: EdgeInsets.all(2.0),
                                  //   child: Image(
                                  //     image: AssetImage(
                                  //         'assets/images/logo.png'),
                                  //     width: 20,
                                  //     height: 20,
                                  //   ),
                                  // )
                                ),
                              ),
                              const SizedBox(height: 10),
                              Visibility(
                                visible: !editMode,
                                child: TRoundedContainer(
                                  width: 35,
                                  radius: BorderRadius.circular(300),
                                  height: 35,
                                  backgroundColor: TColors.white,
                                  showBorder: true,
                                  child: ControlPanelMenuVisitor(
                                    vendorId: userId,
                                    editMode: isVendor,
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: editMode,
                                child: TRoundedContainer(
                                  width: 35,
                                  height: 35,
                                  radius: BorderRadius.circular(300),
                                  backgroundColor: Colors.white,
                                  showBorder: true,
                                  child: Center(
                                    child: ControlPanelMenu(
                                      vendorId: userId,
                                      editMode: editMode,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              isVendor
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => Navigator.push(
                                              Get.context!,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        FollowersScreen(
                                                          vendorId: userId,
                                                        ),
                                              ),
                                            ), //   FollowersScreen(vendorId: userId)),
                                        child: TRoundedContainer(
                                          width: 35,
                                          height: 35,
                                          radius: BorderRadius.circular(300),
                                          showBorder: true,
                                          child: const Center(
                                            child: Icon(
                                              CupertinoIcons.heart,
                                              color: Colors.black,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : FollowHeart(
                                    myId:
                                        AuthController
                                            .instance
                                            .currentUser
                                            .value!
                                            .id,
                                    orgId: userMap.id ?? '',
                                  ),
                              // SizedBox(
                              //   height: 4,
                              // ),
                              Visibility(
                                visible: isVendor,
                                child: FollowNumber(vendorId: userId),
                              ),
                              Visibility(
                                visible: !isVendor,
                                child: const SizedBox(height: 27),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              if (userMap.bannerImage == 'loading')
                TShimmerEffect(
                  width: 100.w,
                  baseColor: TColors.lightgrey,
                  height: 60.h,
                  raduis: BorderRadius.circular(50),
                  color: Colors.grey,
                ),
              Positioned(
                bottom: 12,
                left: 16,
                child: GestureDetector(
                  onTap: () async {
                    if (editMode) {
                      // await uploadorganizationBannerImageAndSaveToFirestore(
                      //   Get.context!,
                      //   userId,
                      // );
                    } else {
                      Get.to(
                        () => NetworkImageFullScreen(
                          userMap.organizationCover ??
                              userMap.bannerImage ??
                              '',
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: 185,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 35, bottom: 5),
                          child: Container(
                            color: Colors.transparent,
                            //height: 200,
                            width: 200,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(300),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,

                                      blurRadius: 6,
                                      offset: Offset(0, 3), // موقع الظل
                                    ),
                                  ],
                                ),
                                child:
                                    userMap.organizationLogo == 'loading'
                                        ? TShimmerEffect(
                                          width: 100,
                                          baseColor: TColors.lightgrey,
                                          height: 100,
                                          raduis: BorderRadius.circular(300),
                                        )
                                        : GestureDetector(
                                          onTap: () async {
                                            if (editMode) {
                                              // await uploadLogoAndSaveToFirestore(
                                              //   Get.context!,
                                              //   userId,
                                              // );
                                              // uploadProfileLogoImageAndSaveToFirestore(
                                              //     context, ref);
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             MarketPlaceManagment(
                                              //                 vendorId: userId,
                                              //                 editMode: true)));
                                            } else {
                                              Get.to(
                                                () => NetworkImageFullScreen(
                                                  userMap.organizationLogo,
                                                ),
                                              );
                                            }
                                          },

                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  userMap.organizationLogo, //
                                              width: 130,
                                              height: 130,
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: (userMap.isVerified ?? false) == true,
                child: Positioned(
                  bottom: -10,
                  left: 60,
                  child: Container(
                    width: 45,
                    height: 45,
                    child: Icon(CupertinoIcons.arrow_counterclockwise),
                  ),
                ),
              ),
            ],
          ),

          // if (!editMode)
          //   Container(
          //     color: Colors.transparent,
          //     height: 10,
          //   ),
          Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: editMode,
                                child: Builder(
                                  builder: (context) {
                                    return editName(context, userMap.toJson());
                                  },
                                ),
                              ),
                              Visibility(
                                visible: editMode,
                                child: const SizedBox(width: 6),
                              ),
                              SizedBox(
                                width: editMode ? 80.w : 95.w,
                                child: Obx(() {
                                  final orgName =
                                      (userMap.organizationName ??
                                          userMap.organizationName);
                                  return TranslateController
                                          .instance
                                          .enableTranslateProductDetails
                                          .value
                                      ? FutureBuilder<String>(
                                        future: TranslateController.instance
                                            .getTranslatedText(
                                              text: orgName,
                                              targetLangCode:
                                                  Localizations.localeOf(
                                                    Get.context!,
                                                  ).languageCode,
                                            ),
                                        builder: (context, snapshot) {
                                          final displayText =
                                              snapshot.connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData
                                                  ? snapshot.data!
                                                  : orgName;
                                          return Text(
                                            displayText,
                                            textAlign: TextAlign.left,
                                            textDirection: TextDirection.ltr,
                                            style: titilliumBold.copyWith(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      )
                                      : Text(
                                        orgName,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: titilliumBold.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                }),
                              ),
                            ],
                          ),
                          if (userMap.slugn != '' && !isVendor)
                            const SizedBox(height: 10),
                          userMap.slugn != ''
                              ? Row(
                                children: [
                                  Visibility(
                                    visible: editMode,
                                    child: Builder(
                                      builder: (context) {
                                        return editSlugnIcon(
                                          context,
                                          userMap.toJson(),
                                        );
                                      },
                                    ),
                                  ),
                                  Visibility(
                                    visible: editMode,
                                    child: const SizedBox(width: 6),
                                  ),
                                  Obx(() {
                                    final brief = userMap.slugn;
                                    return TranslateController
                                            .instance
                                            .enableTranslateProductDetails
                                            .value
                                        ? FutureBuilder<String>(
                                          future: TranslateController.instance
                                              .getTranslatedText(
                                                text: brief,
                                                targetLangCode:
                                                    Localizations.localeOf(
                                                      Get.context!,
                                                    ).languageCode,
                                              ),
                                          builder: (context, snapshot) {
                                            final displayText =
                                                snapshot.connectionState ==
                                                            ConnectionState
                                                                .done &&
                                                        snapshot.hasData
                                                    ? snapshot.data!
                                                    : brief;
                                            return Text(
                                              displayText,
                                              textAlign: TextAlign.left,
                                              textDirection: TextDirection.ltr,
                                              style: titilliumBold.copyWith(
                                                fontSize: 16,
                                                color: TColors.darkerGray,
                                              ),
                                            );
                                          },
                                        )
                                        : Text(
                                          brief,
                                          textAlign: TextAlign.left,
                                          textDirection: TextDirection.ltr,
                                          style: titilliumBold.copyWith(
                                            fontSize: 16,
                                            color: TColors.darkerGray,
                                          ),
                                        );
                                  }),
                                ],
                              )
                              : isVendor
                              ? GestureDetector(
                                onTap:
                                    () => editSlugn(
                                      Get.context!,
                                      userMap.toJson(),
                                    ),
                                child: Text(
                                  "Add brief about your orgnization",
                                  style: titilliumBold.copyWith(
                                    color: TColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //       )
          Column(
            children: [
              // Container(
              //   color: Colors.transparent,
              //   height: 25,
              // ),
              // Visibility(visible: true, child: SocialMediaIcons()),
              VendorSocialLinksBar(vendorId: userId, iconSize: 25),

              if (userMap.organizationBio != '')
                Container(color: Colors.transparent, height: 16),

              if (userMap.organizationBio != '')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    final bio = userMap.organizationBio;
                    return TranslateController
                            .instance
                            .enableTranslateProductDetails
                            .value
                        ? FutureBuilder<String>(
                          future: TranslateController.instance
                              .getTranslatedText(
                                text: bio,
                                targetLangCode:
                                    Localizations.localeOf(
                                      Get.context!,
                                    ).languageCode,
                              ),
                          builder: (context, snapshot) {
                            final displayText =
                                snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData
                                    ? snapshot.data!
                                    : bio;
                            return Text(
                              displayText,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr,
                              style: titilliumRegular.copyWith(fontSize: 16),
                            );
                          },
                        )
                        : Text(
                          bio,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: titilliumRegular.copyWith(fontSize: 16),
                        );
                  }),
                ),
            ],
          ),

          if (editMode)
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8, top: 8),
              child: Divider(thickness: 1.5),
            ),
          Container(color: Colors.transparent, height: 10),
          //        TPromoSlider(
          //     editMode: editMode,
          //     vendorId: userId,
          //   ),
          //   Container(
          //     color: Colors.transparent,
          //     height: 16,
          //   ),

          //  viewCategories(
          //    vendorId: userId,
          //    editMode: editMode,
          //    context: context,
          //  ),
        ],
      );
    }
  });
}

GestureDetector editName(BuildContext context, Map<String, dynamic>? userMap) {
  return GestureDetector(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: TRoundedContainer(
        width: 28,
        height: 28,
        //showBorder: true,
        enableShadow: true,
        radius: BorderRadius.circular(300),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.edit, size: 18),
        ),
      ),
    ),
  );
}

GestureDetector editSlugnIcon(
  BuildContext context,
  Map<String, dynamic>? userMap,
) {
  return GestureDetector(
    onTap: () => editSlugn(context, userMap),
    child: TRoundedContainer(
      width: 28,
      height: 28,
      //showBorder: true,
      enableShadow: true,
      radius: BorderRadius.circular(300),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.edit, size: 18),
      ),
    ),
  );
}

editSlugn(BuildContext context, Map<String, dynamic>? userMap) {}

Widget itemCount(String userId, BuildContext context) {
  // var isVendorAction= CategoryController.instance.productCount.value ==0  &&   !VendorController.instance.isVendor.value
  return GestureDetector(
    onTap: () {
      if (CategoryController.instance.productCount.value > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllProductViewClient(vendorId: userId),
          ),
        );

        // &&   !VendorController.instance.isVendor.value){
      } else if (VendorController.instance.isVendor.value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MarketPlaceManagment(vendorId: userId, editMode: true),
          ),
        );
      } else {}
    },
    child: Obx(
      () =>
          CategoryController.instance.productCount.value == 0 &&
                  !VendorController.instance.isVendor.value
              ? const SizedBox.shrink()
              : TRoundedContainer(
                enableShadow: true,
                showBorder: true,
                borderColor: Colors.white,
                borderWidth: 2.5,
                backgroundColor: TColors.grey,
                radius: BorderRadius.circular(100),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 12,
                      top: 1,
                      bottom: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.bag_fill,
                          color: TColors.titleColor.withValues(alpha: .5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Obx(
                            () => Text(
                              CategoryController.instance.productCount
                                  .toString(),
                              style: titilliumBold.copyWith(
                                fontFamily: numberFonts,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: TColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    ),
  );
}
