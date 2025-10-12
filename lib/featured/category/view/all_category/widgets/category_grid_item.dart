import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

class TCategoryGridItem extends StatelessWidget {
  const TCategoryGridItem({
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
    return Column(
      mainAxisSize: MainAxisSize.min, // تقليل المساحة المطلوبة
      children: [
        Container(
          width: 60, // تقليل الحجم لتفادي overflow
          height: 60,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: TColors.grey,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3),
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
                  (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      image: DecorationImage(image: imageProvider),
                    ),
                  ),
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => ClipRRect(
                    child: TShimmerEffect(
                      raduis: BorderRadius.circular(100),
                      width: 50,
                      height: 50,
                    ),
                  ),
              errorWidget:
                  (context, url, error) =>
                      const Icon(Icons.error, size: 40), // تقليل الحجم
            ),
          ),
        ),
        const SizedBox(height: 4), // تقليل المسافة
        SizedBox(
          // استخدام SizedBox لتجنب أخطاء ParentDataWidget داخل القوائم
          width: 85,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              decoration:
                  selected
                      ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 2),
                        ),
                      )
                      : null,
              child: Obx(
                () =>
                    TranslateController
                            .instance
                            .enableTranslateProductDetails
                            .value
                        ? FutureBuilder<String>(
                          future: TranslateController.instance
                              .getTranslatedText(
                                text: category.title,
                                targetLangCode:
                                    Localizations.localeOf(
                                      context,
                                    ).languageCode,
                              ),
                          builder: (context, snapshot) {
                            final displayText =
                                snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData
                                    ? snapshot.data!
                                    : category.title;
                            return Text(
                              displayText,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: titilliumRegular.copyWith(
                                fontSize: selected ? 14 : 12, // تقليل حجم الخط
                                fontWeight:
                                    selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            );
                          },
                        )
                        : Text(
                          category.title,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: titilliumRegular.copyWith(
                            fontSize: selected ? 13 : 11, // تقليل حجم الخط
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
