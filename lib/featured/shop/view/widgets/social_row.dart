import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SocialMediaController extends GetxController {
  var startIndex = 0.obs;
  final List<IconData> icons = [
    FontAwesomeIcons.locationDot,
    FontAwesomeIcons.google,
    FontAwesomeIcons.phone,
    FontAwesomeIcons.linkedin,
    FontAwesomeIcons.youtube,
    FontAwesomeIcons.facebook,
    FontAwesomeIcons.instagram,
  ]; // استبدل بمسارات الأيقونات الخاصة بك

  void next() {
    if (startIndex.value + 6 < icons.length) {
      startIndex.value += 6;
    }
  }

  void previous() {
    if (startIndex.value > 0) {
      startIndex.value -= 6;
    }
  }
}

class SocialMediaIcons extends StatelessWidget {
  final SocialMediaController controller = Get.put(SocialMediaController());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          return Visibility(
            visible: controller.startIndex.value > 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: controller.previous,
            ),
          );
        }),
        Obx(() {
          return SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  controller.startIndex.value + 6 > controller.icons.length
                      ? controller.icons.length - controller.startIndex.value
                      : 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    controller.icons[controller.startIndex.value + index],
                    size: 25,
                  ),
                );
              },
            ),
          );
        }),
        Obx(() {
          return Visibility(
            visible: controller.startIndex.value + 6 < controller.icons.length,
            child: IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: controller.next,
            ),
          );
        }),
      ],
    );
  }
}
