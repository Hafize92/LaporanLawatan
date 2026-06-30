# Platform Setup

Fail ini digunakan selepas folder `android/`, `ios/`, dan `windows/` dijana dengan `flutter create`.

## Android

Edit `android/app/src/main/AndroidManifest.xml`.

Tambah permission sebelum tag `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

Tambah Google Maps API key dalam tag `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="MASUKKAN_GOOGLE_MAPS_API_KEY" />
```

## iOS

Edit `ios/Runner/Info.plist`.

Tambah usage description:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan kamera untuk mengambil gambar lawatan tapak.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk memilih gambar lawatan tapak.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan lokasi untuk merekod koordinat dan level gambar.</string>
```

Edit `ios/Runner/AppDelegate.swift` dan sediakan Google Maps API key.

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("MASUKKAN_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Windows

Windows MVP memaparkan senarai koordinat dan URL Google Maps. Untuk peta interaktif penuh, bina modul WebView2 yang memuatkan Google Maps JavaScript API dan membaca senarai koordinat daripada state aplikasi.

Untuk lokasi, pastikan Windows Location Services dihidupkan:

`Settings > Privacy & security > Location`
