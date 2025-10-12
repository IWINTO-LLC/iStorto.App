# 🚀 إعداد سريع لـ Google Maps

## 1. احصل على API Keys ⚠️ مهم جداً

```
🔗 https://console.cloud.google.com/
```

1. أنشئ مشروع
2. فعّل: Maps SDK for Android + iOS + Geocoding API
3. أنشئ API Keys (واحد للأندرويد + واحد لـ iOS)
4. قيّدهما بناءً على التطبيق

---

## 2. أضف الحزم

```bash
flutter pub add google_maps_flutter geolocator geocoding permission_handler
```

---

## 3. Android Setup

### `android/app/src/main/AndroidManifest.xml`
```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_KEY"/>
    </application>
</manifest>
```

### `android/app/build.gradle`
```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

---

## 4. iOS Setup

### `ios/Runner/AppDelegate.swift`
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_IOS_KEY")  // في أول السطر في didFinishLaunchingWithOptions
```

### `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج لموقعك لتحديد عنوان التوصيل</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### `ios/Podfile`
```ruby
platform :ios, '14.0'
```

---

## 5. نفذ الأوامر

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

---

## 6. انسخ GoogleMapPicker Widget

من ملف `GOOGLE_MAPS_INTEGRATION_GUIDE.md` (الخطوة 5)
ضعه في: `lib/featured/payment/widgets/google_map_picker.dart`

---

## 7. استخدمه

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapPicker(
          onLocationSelected: (position, address) {
            setState(() {
              latitude = position.latitude;
              longitude = position.longitude;
              addressController.text = address;
            });
          },
        ),
      ),
    );
  },
  icon: Icon(Icons.map),
  label: Text('اختر من الخريطة'),
)
```

---

## ✅ جاهز!

**راجع الملف الكامل للتفاصيل:** `GOOGLE_MAPS_INTEGRATION_GUIDE.md`

