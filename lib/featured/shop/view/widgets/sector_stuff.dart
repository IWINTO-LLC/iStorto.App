import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/sector/view/build_sector_title.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';

RxList<ProductModel> getSpotList(String sector) {
  switch (sector) {
    case 'offers':
      return ProductController.instance.offerDynamic;
    case 'all':
      return ProductController.instance.allDynamic;
    case 'all1':
      return ProductController.instance.allLine1Dynamic;
    case 'all2':
      return ProductController.instance.allLine2Dynamic;
    case 'all3':
      return ProductController.instance.allLine3Dynamic;
    case 'sales':
      return ProductController.instance.salesDynamic;
    case 'foryou':
      return ProductController.instance.foryouDynamic;
    case 'mixone':
      return ProductController.instance.mixoneDynamic;
    case 'mostdeamand':
      return ProductController.instance.mostdeamandDynamic;
    case 'mixlin1':
      return ProductController.instance.mixline1Dynamic;
    case 'mixlin2':
      return ProductController.instance.mixline2Dynamic;

    default:
      return <ProductModel>[].obs; // القيمة الافتراضية إذا لم يكن المدخل صحيحاً
  }
}

Container getEmptyEdit(
  BuildContext context,
  double padding,
  RxList<ProductModel> spotList,
  CardType cardType,
  double cardHeight,
  double cardWidth,
  String sectorName,
  String vendorId,
  bool withTitle,
  bool editMode,
  bool withPadding,
) {
  return Container(
    color: Colors.transparent,
    child: Padding(
      padding:
          withPadding
              ? const EdgeInsets.only(top: 20)
              : const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (withTitle)
                Flexible(
                  child: BuildSectorTitle(name: sectorName, vendorId: vendorId),
                ),
              if (editMode)
                GestureDetector(
                  onTap:
                      () => showEditDialog(
                        context,
                        SectorController.instance.sectors
                            .where((s) => s.name == sectorName)
                            .first,
                      ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                ),
            ],
          ),
          // Visibility(
          //     visible: withTitle, child: TCustomWidgets.buildDivider()),
          Visibility(
            visible: cardType == CardType.mediumCard,
            child: Container(
              color: Colors.transparent,
              height: cardHeight + 110,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: ListView.builder(
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder:
                      (context, index) => Padding(
                        padding:
                            !TranslationController.instance.isRTL
                                ? EdgeInsets.only(
                                  left: padding,
                                  bottom: 20,
                                  right: index == 5 - 1 ? padding : 0,
                                )
                                : EdgeInsets.only(
                                  right: padding,
                                  bottom: 20,
                                  left: index == 5 - 1 ? padding : 0,
                                ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            TRoundedContainer(
                              borderColor: TColors.grey,
                              showBorder: true,
                              enableShadow: true,
                              height: cardHeight + 100,
                              width: cardWidth,
                              radius: BorderRadius.circular(15),
                            ),
                            InkWell(
                              onTap: () {
                                var controller = Get.put(ProductController());
                                controller.deleteTempItems();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CreateProduct(
                                          vendorId: vendorId,
                                          type: sectorName,
                                          initialList: spotList,
                                          sectorTitle:
                                              SectorController.instance.sectors
                                                  .where(
                                                    (s) => s.name == sectorName,
                                                  )
                                                  .first,
                                          sectionId: sectorName,
                                        ),
                                  ),
                                );
                              },
                              child: Stack(
                                //   alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                    ),
                                    child: TRoundedContainer(
                                      showBorder: true,
                                      // enableShadow: true,

                                      // backgroundColor: TColors.grey,
                                      width: cardWidth,
                                      borderColor: TColors.grey.withValues(
                                        alpha: .5,
                                      ),
                                      radius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      height: cardHeight,
                                      child: Visibility(
                                        visible: index == 0,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0,
                                            ),
                                            child: TRoundedContainer(
                                              enableShadow: true,
                                              width: 50,
                                              height: 50,
                                              radius: BorderRadius.circular(
                                                300,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.add,
                                                color: TColors.primary,
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
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: cardType != CardType.mediumCard,
            child: Container(
              color: Colors.transparent,
              height: cardHeight + 10,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder:
                    (context, index) => Padding(
                      padding:
                          !TranslationController.instance.isRTL
                              ? EdgeInsets.only(
                                left: padding,
                                right: index == 5 - 1 ? padding : 0,
                              )
                              : EdgeInsets.only(
                                right: padding,
                                left: index == 5 - 1 ? padding : 0,
                              ),
                      child: InkWell(
                        onTap: () {
                          var controller = Get.put(ProductController());
                          controller.deleteTempItems();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CreateProduct(
                                    vendorId: vendorId,
                                    initialList: spotList,
                                    type: sectorName,
                                    sectorTitle:
                                        SectorController.instance.sectors
                                            .where((s) => s.name == sectorName)
                                            .first,
                                    sectionId: sectorName,
                                  ),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TRoundedContainer(
                              radius: BorderRadius.circular(15),
                              showBorder: true,
                              enableShadow: true,
                              //showBorder: true,
                              height: cardHeight,
                              width: cardWidth,
                              //enableShadow: true,
                              //radius: BorderRadius.circular(15),
                            ),
                            Visibility(
                              visible: index == 0,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: TRoundedContainer(
                                    enableShadow: true,
                                    width: 50,
                                    height: 50,
                                    radius: BorderRadius.circular(300),
                                    child: const Icon(
                                      CupertinoIcons.add,
                                      color: TColors.primary,
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
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    ),
  );
}

Row titleWithEdit(
  BuildContext context,
  String sectorName,
  bool withTitle,
  String vendorId,
  bool editMode,
) {
  return Row(
    children: [
      Flexible(
        child: Visibility(
          visible: withTitle,
          child: BuildSectorTitle(name: sectorName, vendorId: vendorId),
        ),
      ),
      GestureDetector(
        onTap:
            () => showEditDialog(
              context,
              SectorController.instance.sectors
                  .where((s) => s.name == sectorName)
                  .first,
            ),
        child: Visibility(
          visible: editMode,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
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
        ),
      ),
    ],
  );
}
