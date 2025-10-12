import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';

/// أداة اختيار الموقع من خرائط جوجل
class GoogleMapPicker extends StatefulWidget {
  final Function(LatLng position, String address, Placemark? placemark)
  onLocationSelected;
  final LatLng? initialPosition;

  const GoogleMapPicker({
    super.key,
    required this.onLocationSelected,
    this.initialPosition,
  });

  @override
  State<GoogleMapPicker> createState() => _GoogleMapPickerState();
}

class _GoogleMapPickerState extends State<GoogleMapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String _selectedAddress = '';
  Placemark? _selectedPlacemark;
  bool _isLoading = false;
  bool _isFetchingAddress = false;
  final Set<Marker> _markers = {};

  // موقع افتراضي (الرياض)
  static const LatLng _defaultLocation = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    if (_selectedPosition != null) {
      _addMarker(_selectedPosition!);
      _getAddressFromLatLng(_selectedPosition!);
    } else {
      _getCurrentLocation();
    }
  }

  /// الحصول على الموقع الحالي
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDialog();
          _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        _useDefaultLocation();
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = latLng;
        _addMarker(latLng);
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

      await _getAddressFromLatLng(latLng);
    } catch (e) {
      print('Error getting location: $e');
      _useDefaultLocation();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// استخدام الموقع الافتراضي
  void _useDefaultLocation() {
    setState(() {
      _selectedPosition = _defaultLocation;
      _addMarker(_defaultLocation);
      _isLoading = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_defaultLocation, 12),
    );

    _getAddressFromLatLng(_defaultLocation);
  }

  /// عرض رسالة الأذونات
  void _showPermissionDialog() {
    Get.snackbar(
      'تنبيه',
      'للحصول على موقعك الحالي، نحتاج إلى إذن الموقع. سيتم استخدام موقع افتراضي.',
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      duration: const Duration(seconds: 4),
    );
  }

  /// إضافة علامة على الخريطة
  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _onMapTap(newPosition);
          },
          infoWindow: InfoWindow(
            title: 'موقعك',
            snippet: _selectedAddress.isNotEmpty ? _selectedAddress : null,
          ),
        ),
      );
    });
  }

  /// الحصول على العنوان من الإحداثيات
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isFetchingAddress = true);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _selectedPlacemark = place;

        // تجميع العنوان
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        setState(() {
          _selectedAddress =
              addressParts.isNotEmpty
                  ? addressParts.join(', ')
                  : 'عنوان غير محدد';
        });

        // تحديث معلومات العلامة
        _addMarker(position);
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = 'تعذر الحصول على العنوان';
      });
    } finally {
      setState(() => _isFetchingAddress = false);
    }
  }

  /// عند الضغط على الخريطة
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _addMarker(position);
    });
    _getAddressFromLatLng(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'pick_from_map'.tr,
          style: titilliumBold.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // زر الموقع الحالي
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'map_picker_current_location'.tr,
          ),
        ],
      ),
      body: Stack(
        children: [
          // الخريطة
          _selectedPosition != null
              ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedPosition!,
                  zoom: 15,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // نستخدم زر خاص
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                tiltGesturesEnabled: true,
              )
              : const Center(child: CircularProgressIndicator()),

          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // شريط معلومات العنوان في الأسفل
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // مؤشر السحب
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // العنوان
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: TColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isFetchingAddress
                                  ? 'map_picker_fetching_address'.tr
                                  : (_selectedAddress.isNotEmpty
                                      ? _selectedAddress
                                      : 'اضغط على الخريطة لاختيار موقع'),
                              style: titilliumRegular.copyWith(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_selectedPosition != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                                style: titilliumRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // زر التأكيد
                  ElevatedButton(
                    onPressed:
                        _selectedPosition != null && !_isFetchingAddress
                            ? () {
                              widget.onLocationSelected(
                                _selectedPosition!,
                                _selectedAddress,
                                _selectedPlacemark,
                              );
                              Navigator.pop(context);
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'map_picker_confirm_location'.tr,
                          style: titilliumBold.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
