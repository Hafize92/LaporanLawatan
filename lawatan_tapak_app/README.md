# Lawatan Tapak App

Aplikasi Flutter untuk menyediakan laporan lawatan tapak bagi iOS, Android, dan Windows.

## Status

Ini ialah MVP source tree. Environment semasa tidak mempunyai Flutter/Dart, jadi platform folder belum dijana dan analisis belum boleh dijalankan di sini.

## Fungsi MVP

- Rekod maklumat projek dan lawatan.
- Ambil gambar melalui kamera atau import galeri.
- Simpan koordinat, altitude, accuracy, masa, dan catatan gambar.
- Baca koordinat daripada lokasi semasa, dengan fallback EXIF jika metadata gambar tersedia.
- Kira adjusted level berdasarkan offset projek.
- Papar gambar sebagai marker Google Maps untuk iOS/Android.
- Papar fallback koordinat dan Google Maps URL untuk Windows.
- Jana preview/export laporan PDF.

## Setup

1. Pasang Flutter SDK.
2. Masuk ke folder projek:

   ```powershell
   cd "C:\Users\WORK\OneDrive\Documents\Lawatan Tapak\lawatan_tapak_app"
   ```

3. Jana folder platform:

   ```powershell
   flutter create . --platforms=android,ios,windows --project-name lawatan_tapak_app
   ```

4. Dapatkan dependency:

   ```powershell
   flutter pub get
   ```

5. Jalankan aplikasi:

   ```powershell
   flutter run -d windows
   ```

## Google Maps API Key

Untuk Android dan iOS, masukkan Google Maps API key mengikut dokumentasi `google_maps_flutter`.

Windows menggunakan fallback MVP berupa senarai koordinat dan Google Maps route/search URL. Integrasi penuh Windows boleh dibuat pada fasa seterusnya dengan WebView2 dan Google Maps JavaScript API.

Lihat [docs/PLATFORM_SETUP.md](docs/PLATFORM_SETUP.md) untuk permission kamera, galeri, lokasi, dan Google Maps API key.

## Nota Ketepatan Level

Altitude daripada telefon sesuai untuk rujukan lawatan tapak, tetapi bukan gantian ukur rasmi. Untuk kerja ukur berketepatan tinggi, gunakan GNSS/RTK atau benchmark level yang disahkan.
