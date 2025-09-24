import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:latlong2/latlong.dart';

import 'package:istoreto/featured/cart/controller/map_controller.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

class OrderMapPreviewScreen extends StatelessWidget {
  final LatLng location;
  final String orderId;

  const OrderMapPreviewScreen({
    super.key,
    required this.location,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TMapController());
    controller.selectedLocation.value = location;

    return Scaffold(
      appBar: CustomAppBar(
        title:
            TranslationController.instance.isRTL
                ? 'موقع الطلب رقم $orderId'
                : "Order #$orderId Location",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
              () => FlutterMap(
                options: MapOptions(
                  initialCenter: controller.selectedLocation.value,
                  maxZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: controller.selectedLocation.value,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 50,
              right: 50,
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // لا حاجة لتحديد موقع جديد – فقط العودة
                    Navigator.pop(context);
                  },
                  child: Text("backToOrder".tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
