# دليل دمج Google Maps في التطبيق
## Google Maps Integration Guide

---

## ✅ ملخص الإصلاحات المكتملة
### Completed Fixes Summary

### 1. نظام العناوين (Address System)
✅ **AddressModel** متطابق تماماً مع جدول قاعدة البيانات:
- جميع الأعمدة موجودة: `id`, `user_id`, `title`, `full_address`, `city`, `street`, `building_number`, `phone_number`, `latitude`, `longitude`, `is_default`, `created_at`, `updated_at`
- دوال التحويل من/إلى Map تعمل بشكل صحيح
- يدعم snake_case و camelCase

✅ **AddressService** يحتوي على جميع الدوال المطلوبة:
- `getUserAddresses()` - جلب جميع العناوين
- `saveAddress()` - حفظ عنوان جديد
- `updateAddress()` - تحديث عنوان
- `deleteAddress()` - حذف عنوان
- `setDefaultAddress()` - تعيين عنوان افتراضي
- `selectAddress()` - اختيار عنوان للطلب

✅ **checkout_stepper_screen.dart** تم إصلاحه:
- إضافة `_loadUserAddresses()` لتحميل العناوين تلقائياً
- اختيار العنوان الافتراضي تلقائياً عند التحميل
- التحقق من العنوان المحدد قبل الانتقال للخطوة التالية
- استبدال جميع النصوص الثابتة بمفاتيح الترجمة

✅ **الترجمات (Translations)**:
- إضافة جميع المفاتيح المفقودة للإنجليزية والعربية
- دعم متعدد اللغات لجميع الرسائل

---

## 🗺️ دمج Google Maps
### Integrating Google Maps

### الخطوة 1: الحصول على Google Maps API Key

#### أ) إنشاء مشروع في Google Cloud Console
1. اذهب إلى: https://console.cloud.google.com/
2. انقر على "Select a project" في الأعلى
3. اختر "NEW PROJECT"
4. أدخل اسم المشروع: `istoreto-app`
5. انقر "CREATE"

#### ب) تفعيل Google Maps APIs
1. من القائمة الجانبية، اذهب إلى **APIs & Services > Library**
2. ابحث عن وفعّل هذه الـ APIs:
   - ✅ **Maps SDK for Android**
   - ✅ **Maps SDK for iOS**
   - ✅ **Geocoding API** (لتحويل العناوين إلى إحداثيات)
   - ✅ **Places API** (للبحث عن الأماكن)
   - ✅ **Directions API** (للمسارات - اختياري)

#### ج) إنشاء API Keys
1. اذهب إلى **APIs & Services > Credentials**
2. انقر "CREATE CREDENTIALS" > "API key"
3. ستحصل على مفتاح API
4. **مهم جداً**: انقر على "RESTRICT KEY" وقم بما يلي:

##### لـ Android:
- اختر "Android apps"
- انقر "Add an item"
- أدخل:
  - **Package name**: `com.yourcompany.istoreto` (تجده في `android/app/build.gradle`)
  - **SHA-1**: احصل عليه بتشغيل:
    ```bash
    cd android
    ./gradlew signingReport
    ```
- انسخ SHA-1 certificate fingerprint من النتائج

##### لـ iOS:
- أنشئ API key منفصل
- اختر "iOS apps"
- أدخل Bundle Identifier (تجده في `ios/Runner.xcodeproj`)

---

### الخطوة 2: تثبيت الحزمة

أضف هذه الحزم في `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # خرائط Google
  google_maps_flutter: ^2.5.3
  
  # للموقع الجغرافي
  geolocator: ^11.0.0
  geocoding: ^2.1.1
  
  # للطلبات HTTP (إذا لم تكن موجودة)
  http: ^1.1.0
  
  # للأذونات
  permission_handler: ^11.0.1
```

ثم نفذ:
```bash
flutter pub get
```

---

### الخطوة 3: إعدادات Android

#### أ) تحديث `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- إضافة الأذونات -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    
    <application
        android:label="istoreto"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- إضافة Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_API_KEY_HERE"/>
        
        <activity
            android:name=".MainActivity"
            ...
        </activity>
    </application>
</manifest>
```

#### ب) تحديث `android/app/build.gradle`

تأكد من أن `minSdkVersion` هو 21 على الأقل:

```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.istoreto"
        minSdkVersion 21  // <-- تأكد من هذا
        targetSdkVersion flutter.targetSdkVersion
        ...
    }
}
```

---

### الخطوة 4: إعدادات iOS

#### أ) تحديث `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import GoogleMaps  // أضف هذا

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // أضف Google Maps API Key
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### ب) تحديث `ios/Runner/Info.plist`

```xml
<dict>
    ...
    
    <!-- إضافة أوصاف الأذونات -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>نحتاج للوصول إلى موقعك لإظهار عنوانك على الخريطة</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>نحتاج للوصول إلى موقعك لتحديد عنوان التوصيل</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>نحتاج للوصول إلى موقعك في الخلفية</string>
    
    <key>io.flutter.embedded_views_preview</key>
    <true/>
    
    ...
</dict>
```

#### ج) تحديث `ios/Podfile`

تأكد من أن platform هو iOS 14 على الأقل:

```ruby
platform :ios, '14.0'
```

ثم نفذ:
```bash
cd ios
pod install
cd ..
```

---

### الخطوة 5: إنشاء Google Map Widget

أنشئ ملف: `lib/featured/payment/widgets/google_map_picker.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/styles/styles.dart';

class GoogleMapPicker extends StatefulWidget {
  final Function(LatLng position, String address) onLocationSelected;
  final LatLng? initialPosition;

  const GoogleMapPicker({
    Key? key,
    required this.onLocationSelected,
    this.initialPosition,
  }) : super(key: key);

  @override
  State<GoogleMapPicker> createState() => _GoogleMapPickerState();
}

class _GoogleMapPickerState extends State<GoogleMapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _isLoading = false;
  Set<Marker> _markers = {};

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

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('خطأ', 'تم رفض إذن الموقع');
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('خطأ', 'أذونات الموقع معطلة بشكل دائم');
        setState(() => _isLoading = false);
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = latLng;
        _addMarker(latLng);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );

      await _getAddressFromLatLng(latLng);
    } catch (e) {
      print('Error getting location: $e');
      Get.snackbar('خطأ', 'فشل الحصول على الموقع: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
        ),
      );
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = 'عنوان غير محدد';
      });
    }
  }

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
      appBar: AppBar(
        title: Text(
          'اختر الموقع على الخريطة',
          style: titilliumBold.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // الخريطة
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition ??
                  const LatLng(24.7136, 46.6753), // الرياض
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),

          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // معلومات العنوان
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
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
                  // العنوان
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress.isNotEmpty
                              ? _selectedAddress
                              : 'اختر موقعاً على الخريطة',
                          style: titilliumRegular.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // زر التأكيد
                  ElevatedButton(
                    onPressed: _selectedPosition != null
                        ? () {
                            widget.onLocationSelected(
                              _selectedPosition!,
                              _selectedAddress,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تأكيد الموقع',
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
```

---

### الخطوة 6: دمج الخريطة في صفحة إضافة العنوان

ابحث عن صفحة إضافة/تعديل العنوان في مشروعك (عادة في `lib/featured/payment/views/` أو `lib/views/address/`)

مثال على كيفية إضافة زر لفتح الخريطة:

```dart
import 'package:istoreto/featured/payment/widgets/google_map_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// في داخل الـ Widget:
double? selectedLatitude;
double? selectedLongitude;
String? selectedAddressFromMap;

// زر لفتح الخريطة:
OutlinedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapPicker(
          onLocationSelected: (position, address) {
            setState(() {
              selectedLatitude = position.latitude;
              selectedLongitude = position.longitude;
              selectedAddressFromMap = address;
              
              // يمكنك ملء حقل العنوان تلقائياً
              fullAddressController.text = address;
            });
          },
          initialPosition: selectedLatitude != null && selectedLongitude != null
              ? LatLng(selectedLatitude!, selectedLongitude!)
              : null,
        ),
      ),
    );
  },
  icon: const Icon(Icons.map),
  label: const Text('اختر من الخريطة'),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
),
```

---

### الخطوة 7: حفظ الإحداثيات في قاعدة البيانات

عند حفظ العنوان، تأكد من تمرير الإحداثيات:

```dart
final address = AddressModel(
  userId: userId,
  title: titleController.text,
  fullAddress: fullAddressController.text,
  city: cityController.text,
  street: streetController.text,
  buildingNumber: buildingNumberController.text,
  phoneNumber: phoneNumberController.text,
  latitude: selectedLatitude,  // من الخريطة
  longitude: selectedLongitude, // من الخريطة
  isDefault: isDefaultAddress,
);

await addressService.saveAddress(address, userId);
```

---

### الخطوة 8: عرض الموقع على الخريطة (في صفحة الطلب)

يمكنك إضافة خريطة صغيرة لعرض موقع التوصيل:

```dart
// في صفحة تفاصيل الطلب أو الـ checkout:
if (selectedAddress.latitude != null && selectedAddress.longitude != null)
  Container(
    height: 200,
    margin: const EdgeInsets.symmetric(vertical: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            selectedAddress.latitude!,
            selectedAddress.longitude!,
          ),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('delivery_location'),
            position: LatLng(
              selectedAddress.latitude!,
              selectedAddress.longitude!,
            ),
          ),
        },
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
      ),
    ),
  ),
```

---

## 📝 ملاحظات مهمة

### 1. الأمان (Security)
- **لا تضع API Keys في الكود مباشرة للإنتاج**
- استخدم environment variables أو Firebase Remote Config
- قيّد API Keys بناءً على التطبيق (Package name/Bundle ID)
- قيّد الـ APIs المسموح بها فقط

### 2. التكاليف (Costs)
- Google Maps لديه حصة مجانية شهرية ($200 credit)
- راقب استخدامك في Google Cloud Console
- بعد الحصة المجانية، سيتم الشحن

### 3. الاختبار (Testing)
```bash
# اختبار على Android
flutter run -d android

# اختبار على iOS
flutter run -d ios

# التأكد من الأذونات
# اضغط على زر "موقعي" في الخريطة وتأكد من طلب الإذن
```

### 4. استكشاف الأخطاء (Troubleshooting)

#### المشكلة: الخريطة لا تظهر (شاشة رمادية)
الحل:
- تحقق من صحة API Key
- تأكد من تفعيل Maps SDK for Android/iOS
- تحقق من قيود API Key
- راجع Logs:
  ```bash
  flutter run -v
  ```

#### المشكلة: "Map failed to load" على Android
الحل:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### المشكلة: الموقع الحالي لا يعمل
الحل:
- تحقق من الأذونات في AndroidManifest.xml / Info.plist
- تأكد من تفعيل GPS على الجهاز
- على iOS Simulator، استخدم: Features > Location > Custom Location

---

## 🎯 الخطوات التالية

### ✅ تم الإنجاز:
- [x] نظام العناوين متطابق مع قاعدة البيانات
- [x] تحميل واختيار العناوين تلقائياً
- [x] الترجمات المتعددة للغات
- [x] إصلاح checkout screen

### 📋 المطلوب منك:
1. احصل على Google Maps API Keys (Android + iOS)
2. أضف API Keys في الملفات المحددة أعلاه
3. نفذ الأوامر:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   flutter clean
   ```
4. اختبر التطبيق على جهاز حقيقي (ليس simulator)
5. افتح صفحة إضافة العنوان وأضف زر "اختر من الخريطة"

---

## 📞 دعم إضافي

إذا واجهت أي مشاكل:
1. تحقق من Logs: `flutter run -v`
2. راجع [Google Maps Flutter Documentation](https://pub.dev/packages/google_maps_flutter)
3. تحقق من Google Cloud Console > APIs & Services > Dashboard

---

**ملاحظة**: جميع ملفات AddressModel و AddressService و AddressRepository موجودة بالفعل وتعمل بشكل صحيح مع جدول قاعدة البيانات. فقط تحتاج لإضافة Google Maps UI.

**تاريخ التحديث**: 2025

