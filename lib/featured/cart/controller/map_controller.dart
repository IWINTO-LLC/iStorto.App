import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class TMapController extends GetxController {
  Rx<LatLng> selectedLocation = Rx<LatLng>(LatLng(25.2048, 55.2708)); // دبي

  Future<void> setCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    selectedLocation.value = LatLng(position.latitude, position.longitude);
  }
}
