import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/view/view_category.dart';
import 'package:istoreto/featured/shop/view/widgets/grid_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/grid_builder_custom_card.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_builder_just_img.dart';
import 'package:istoreto/utils/constants/enums.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key, required this.editMode, required this.vendorId});
  final bool editMode;
  final String vendorId;

  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  @override
  void initState() {
    super.initState();
    // تحميل الفئات عند بدء الصفحة
  
  }

  @override
  Widget build(BuildContext context) {
    ProductController.instance.closeList;
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // const SizedBox(
            //   height: 4,
            // ),
           
            // const SizedBox(
            //   height: 16,
            // ),
            GridBuilderCustomCard(
                vendorId: widget.vendorId, editMode: widget.editMode),
            Container(
              color: Colors.transparent,
              height: 10,
            ),
            SectorBuilderJustImg(
              cardWidth: 70.w,
              cardHeight: 70.w * 4 / 3,
              sectorName: 'mixone',
              sctionTitle: 'all',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
            
              withPadding: false,
            ),
            // const SizedBox(
            //   height: 16,
            // ),
            SectorBuilderJustImg(
              cardWidth: 26.w,
              cardHeight: 26.w * (4 / 3),
              sectorName: "offers",
              sctionTitle: 'all',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
              withPadding: false,
            
            ),
            // const SizedBox(
            //   height: 8,
            // ),
            SectorBuilder(
              cardWidth: 33.333.w,
              cardHeight: 33.333.w * (4 / 3),
              sectorName: 'all',
              sctionTitle: 'all',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
              withPadding: false,
              cardType: CardType.smallCard,
            ),

            SectorBuilder(
              cardWidth: 33.333.w,
              cardHeight: 33.333.w * (4 / 3),
              sectorName: 'all1',
              sctionTitle: 'all',
              vendorId: widget.vendorId,

              withPadding: false,
              editMode: widget.editMode,
              // withTitle: false,
              cardType: CardType.smallCard,
            ),

            SectorBuilder(
              cardWidth: 33.333.w,
              cardHeight: 33.333.w * (4 / 3),
              sectorName: 'all2',
              vendorId: widget.vendorId,
              sctionTitle: 'all',
              editMode: widget.editMode,
              withPadding: false,
              cardType: CardType.smallCard,
            ),
            SectorBuilder(
              cardWidth: 33.333.w,
              cardHeight: 33.333.w * (4 / 3),
              sectorName: 'all3',
              sctionTitle: 'all',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
              withPadding: false,
              cardType: CardType.smallCard,
            ),
            //   SectorBuilder(
            //   cardWidth: 127,
            //   cardHeight: 170,
            //   sectorTitle: SectorModel(
            //          name: 'all4', englishName: 'Product List4', arabicName: 'قائمة المنتجات 4'),
            //   sctionTitle: 'all',
            //   vendorId: vendorId,
            //   editMode: editMode,

            //   cardType: CardType.smallCard,
            // ),
            SectorBuilderJustImg(
              cardWidth: 94.w,
              cardHeight: 94.w * (8 / 6),
              sectorName: 'sales',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
             
              withPadding: false,
              sctionTitle: '',
            ),

            SectorBuilderJustImg(
              cardWidth: 25.w,
              cardHeight: 25.w * (4 / 3),
              sectorName: 'foryou',
              sctionTitle: 'all',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
             
              withPadding: false,
            ),
            // const SizedBox(
            //   height: 30,
            // ),
            GridBuilder(vendorId: widget.vendorId, editMode: widget.editMode),

            /////////////////////////////

            // SectorBuilder(
            //   cardWidth: 70.w,
            //   cardHeight: 70.w * 4 / 3,
            //   sectorName: 'mixone',
            //   sctionTitle: 'all',
            //   vendorId: widget.vendorId,
            //   editMode: widget.editMode,
            //   withPadding: false,
            //   cardType: CardType.justImage,
            // ),
            SectorBuilder(
              cardWidth: 40.w,
              cardHeight: 40.w * (4 / 3),
              sectorName: 'mixlin2',
              sctionTitle: 'all',
              vendorId: widget.vendorId,
              editMode: widget.editMode,
              cardType: CardType.mediumCard,
              withTitle: true,
              withPadding: false,
            ),

            /////////////////////mix ones
            Visibility(
              visible: CategoryController.instance.productCount > 40,
              child: Container(
                color: Colors.transparent,
                height: 20,
              ),
            ),

            Visibility(
                visible: CategoryController.instance.productCount > 40,
                child: viewCategories(vendorId: widget.vendorId,editMode: widget.editMode,context: context  )),

            Container(
              color: Colors.transparent,
              height: 60,
            ),
          ]),
    );
  }
  }
