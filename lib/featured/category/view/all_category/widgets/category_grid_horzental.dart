import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TCategoryGridHorizental extends StatelessWidget {
  const TCategoryGridHorizental({
    super.key,
    required this.category,
    required this.editMode,
    this.selected = false,
  });
  final CategoryModel category;

  final bool editMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: TColors.grey,
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: TColors.white,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            color: TColors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              imageUrl: category.icon!,
              imageBuilder:
                  (context, imageProvider) =>
                  //  GestureDetector(
                  //       onTap: () => Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => AllProducts(
                  //                     title: Get.locale?.languageCode == 'en'
                  //                         ? category.name
                  //                         : category.arabicName,
                  //                     categoryId: category.id!,
                  //                     editMode: editMode,
                  //                     vendorId: vendorId,
                  //                     futureMethode: CategoryController
                  //                         .instance
                  //                         .getCategoryProduct(
                  //                             categoryId: category.id!,
                  //                             userId: FirebaseAuth
                  //                                 .instance.currentUser!.uid,
                  //                             limit: -1),
                  //                   ))),
                  //       child:
                  Container(
                    // width: 80,
                    // height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(image: imageProvider),
                    ),
                  ),
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => ClipRRect(
                    //  borderRadius: BorderRadius.circular(0),
                    child: TShimmerEffect(
                      raduis: BorderRadius.circular(100),
                      width: 65,
                      height: 65,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => const Icon(Icons.error, size: 50),
            ),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtWItems / 2),

        Wrap(
          children: [
            Container(
              width: 85,

              //   height: 60,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration:
                      selected
                          ? BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black, // لون الحد
                                width: 2, // سمك الحد
                              ),
                            ),
                          )
                          : null,
                  child: Text(
                    category.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: titilliumRegular.copyWith(
                      fontSize: selected ? 15 : 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
