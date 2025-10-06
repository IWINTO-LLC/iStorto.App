import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/featured/banner/view/front/promo_slider.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/shop/view/widgets/grid_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/grid_builder_custom_card.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_builder_just_img.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_categories_widget.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:sizer/sizer.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key, required this.editMode, required this.vendorId});
  final bool editMode;
  final String vendorId;

  @override
  Widget build(BuildContext context) {
    Get.put(SectorController(vendorId));
    ProductController.instance.closeList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TPromoSlider(editMode: editMode, vendorId: vendorId),
        Container(color: Colors.transparent, height: 16),

        VendorCategoriesWidget(editMode: editMode, vendorId: vendorId),

        GridBuilderCustomCard(vendorId: vendorId, editMode: editMode),
        Container(color: Colors.transparent, height: 10),
        SectorBuilder(
          cardWidth: 70.w,
          cardHeight: 70.w * 4 / 3,
          sectorName: 'mixone',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          cardType: CardType.justImage,
          withPadding: false,
        ),

        SectorBuilderJustImg(
          cardWidth: 25.w,
          cardHeight: 25.w * (4 / 3),
          sectorName: "offers",
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
        ),

        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
          cardType: CardType.smallCard,
        ),

        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all1',
          sctionTitle: 'all',
          vendorId: vendorId,
          withPadding: false,
          editMode: editMode,
          cardType: CardType.smallCard,
        ),

        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all2',
          vendorId: vendorId,
          sctionTitle: 'all',
          editMode: editMode,
          withPadding: false,
          cardType: CardType.smallCard,
        ),

        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all3',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
          cardType: CardType.smallCard,
        ),

        SectorBuilderJustImg(
          cardWidth: 94.w,
          cardHeight: 94.w * (8 / 6),
          sectorName: 'sales',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
          sctionTitle: '',
        ),

        SectorBuilderJustImg(
          cardWidth: 25.w,
          cardHeight: 25.w * (4 / 3),
          sectorName: 'foryou',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
        ),

        GridBuilder(vendorId: vendorId, editMode: editMode),

        SectorBuilder(
          cardWidth: 40.w,
          cardHeight: 40.w * (4 / 3),
          sectorName: 'mixlin2',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          cardType: CardType.mediumCard,
          withTitle: true,
          withPadding: false,
        ),

        // عرض الفئات مرة أخرى إذا كان هناك أكثر من 40 منتج
        Visibility(
          visible: CategoryController.instance.productCount > 40,
          child: Container(color: Colors.transparent, height: 20),
        ),

        Visibility(
          visible: CategoryController.instance.productCount > 40,
          child: VendorCategoriesWidget(editMode: editMode, vendorId: vendorId),
        ),

        Container(color: Colors.transparent, height: 60),
      ],
    );
  }
}
