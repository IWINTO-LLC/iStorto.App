import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/controllers/translate_controller.dart';

class BuildSectorTitle extends StatelessWidget {
  const BuildSectorTitle({
    super.key,
    required this.vendorId,
    required this.name,
  });
  final String vendorId;
  final String name;
  @override
  Widget build(BuildContext context) {
    final initial = initialSector.where((e) => e.name == name).first;
    final controller = SectorController.instance;

    return FutureBuilder(
      future: controller.fetchSectors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TShimmerEffect(
              width: 100,
              height: 20,
              raduis: BorderRadius.circular(10),
            ),
          );
        } else {
          // استخدام Obx لمراقبة التغييرات في sectors
          return Obx(() {
            // الحصول على القسم المحدث داخل Obx
            final sector = controller.sectors.firstWhere(
              (e) => e.name == name,
              orElse: () => initial,
            );

            return TranslateController
                    .instance
                    .enableTranslateProductDetails
                    .value
                ? FutureBuilder<String>(
                  future: TranslateController.instance.getTranslatedText(
                    text: sector.englishName,
                    targetLangCode:
                        Localizations.localeOf(context).languageCode,
                  ),
                  builder: (context, snapshot) {
                    final displayText =
                        snapshot.connectionState == ConnectionState.done &&
                                snapshot.hasData
                            ? snapshot.data!
                            : sector.englishName;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TCustomWidgets.buildTitle(displayText),
                    );
                  },
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TCustomWidgets.buildTitle(sector.englishName),
                );
          });
        }
        //  else {
        //   return TCustomWidgets.buildTitle(
        //       isArabicLocale() ? initial.arabicName : initial.englishName);
        // }
      },
    );
  }
}
