import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  const MapLocationPicker({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late LatLng _pickedLocation;
  String? _address;
  bool _loadingAddress = false;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation ?? const LatLng(24.7136, 46.6753);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAddressFromLatLng(_pickedLocation);
    });
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    setState(() {
      _loadingAddress = true;
      _address = null;
    });
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&accept-language=ar';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterMapLocationPicker/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _address = data['display_name'] ?? 'عنوان غير متوفر';
          _loadingAddress = false;
        });
      } else {
        setState(() {
          _address = 'map_picker_address_fetch_error'.tr;
          _loadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'map_picker_address_fetch_error'.tr;
        _loadingAddress = false;
      });
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _pickedLocation = point;
      _address = null;
    });
    _getAddressFromLatLng(point);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _gettingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('map_picker_location_fetch_error'.tr)),
        );
        setState(() {
          _gettingLocation = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('map_picker_location_fetch_error'.tr)),
          );
          setState(() {
            _gettingLocation = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('map_picker_location_fetch_error'.tr)),
        );
        setState(() {
          _gettingLocation = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng current = LatLng(position.latitude, position.longitude);
      setState(() {
        _pickedLocation = current;
        _address = null;
        _gettingLocation = false;
      });
      _getAddressFromLatLng(current);
    } catch (e) {
      setState(() {
        _gettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('map_picker_location_fetch_error'.tr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'map_picker_title'.tr),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _pickedLocation,
                maxZoom: 17,
                onTap: (tapPosition, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                // TileLayer(
                //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                //   userAgentPackageName: 'com.example.app',
                // ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        size: 44,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        _loadingAddress
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('map_picker_fetching_address'.tr),
                              ],
                            )
                            : _address != null
                            ? Text(
                              _address!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            )
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon:
                              _gettingLocation
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                  ),
                          label: Text('map_picker_current_location'.tr),

                          onPressed:
                              _gettingLocation ? null : _getCurrentLocation,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: Text('map_picker_confirm_location'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed:
                              _address != null && !_loadingAddress
                                  ? () {
                                    Navigator.pop(context, {
                                      'latlng': _pickedLocation,
                                      'address': _address,
                                    });
                                  }
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
