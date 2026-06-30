# Spesifikasi Awal Aplikasi Lawatan Tapak

## Matlamat

Aplikasi ini bertujuan membantu pengguna menyediakan laporan lawatan tapak dengan gambar, koordinat lokasi, ketinggian/level, peta, dan nota pemerhatian.

Implementasi MVP Flutter telah dimulakan dalam folder `lawatan_tapak_app`.
Versi PWA installable yang boleh dibuka melalui link telah disediakan dalam folder `lawatan_tapak_pwa`.

Platform sasaran:

- iOS
- Android
- Windows

## Cadangan Teknologi

Cadangan utama ialah Flutter kerana ia menyokong pembangunan satu codebase untuk iOS, Android, dan Windows. Ini mengurangkan kos pembangunan berbanding membina tiga aplikasi native berasingan.

Cadangan stack:

- Frontend/app: Flutter + Dart
- Local database: SQLite
- Penyimpanan fail: local app storage
- Peta:
  - iOS/Android: Google Maps SDK melalui Flutter plugin
  - Windows: WebView2 dengan Google Maps JavaScript API, atau fallback peta statik dalam laporan
- Laporan: jana PDF atau Word-like report daripada template
- Sync/cloud optional: Firebase, Supabase, atau server sendiri

## Fungsi Utama

### 1. Ambil gambar lawatan tapak

Pengguna boleh mengambil gambar terus dalam aplikasi atau import daripada galeri.

Data yang perlu disimpan untuk setiap gambar:

- Gambar asal
- Tarikh dan masa
- Latitude
- Longitude
- Altitude/ketinggian jika tersedia
- Accuracy GPS
- Nama lokasi atau chainage optional
- Nota gambar
- Kategori gambar, contoh: struktur, longkang, jalan, cerun, utiliti

### 2. Koordinat gambar dimasukkan ke dalam template laporan

Setiap gambar akan dipaparkan dalam template laporan bersama maklumat:

- No. gambar
- Thumbnail/gambar penuh
- Latitude dan longitude
- Altitude/level
- Tarikh dan masa
- Catatan pengguna
- Marker lokasi pada peta

Template laporan boleh mempunyai format seperti:

- Muka depan projek
- Ringkasan lawatan
- Jadual gambar
- Peta lokasi
- Pemerhatian dan cadangan
- Lampiran gambar

### 3. Ketinggian gambar dan level

Aplikasi boleh membaca atau mendapatkan altitude daripada:

- Metadata gambar jika gambar mempunyai GPS altitude
- Sensor lokasi telefon semasa gambar diambil
- Tetapan manual seperti benchmark level atau offset projek

Kaedah level:

- `Recorded altitude`: altitude yang direkod oleh peranti
- `Adjusted level`: altitude + offset projek
- `MSL estimate`: anggaran berdasarkan sumber peranti atau servis geoid jika diperlukan

Nota penting: Altitude daripada telefon tidak sentiasa tepat untuk kerja ukur rasmi. Untuk laporan lawatan tapak, ia sesuai sebagai rujukan. Untuk kerja ukur berketepatan tinggi, perlu integrasi GNSS/RTK atau data benchmark sah.

### 4. Integrasi Google Map

Fungsi peta:

- Papar semua gambar sebagai marker
- Tap marker untuk lihat gambar dan nota
- Papar laluan lawatan berdasarkan urutan gambar
- Pilih satu atau beberapa gambar untuk dimasukkan ke peta laporan
- Export peta sebagai imej untuk dimasukkan ke dalam PDF

Cadangan implementasi:

- iOS dan Android: Google Maps native plugin
- Windows: Google Maps JavaScript API dalam WebView2, kerana plugin Flutter Google Maps rasmi tidak menyediakan Windows native

### 5. Tambah ayat/catatan

Pengguna boleh tambah ayat pada beberapa peringkat:

- Catatan untuk setiap gambar
- Catatan umum lawatan tapak
- Pemerhatian
- Cadangan tindakan
- Kesimpulan laporan

Untuk memudahkan pengguna, aplikasi boleh sediakan ayat template seperti:

- "Pemerhatian di lokasi ini menunjukkan..."
- "Kerja pembaikan dicadangkan di kawasan..."
- "Keadaan semasa tapak adalah..."
- "Tindakan lanjut diperlukan bagi..."

## Aliran Kerja Aplikasi

1. Buat projek lawatan tapak baru.
2. Isi maklumat projek, tarikh, pegawai, kontraktor, dan lokasi.
3. Ambil gambar di tapak.
4. Aplikasi simpan gambar bersama koordinat, altitude, masa, dan nota.
5. Gambar dipaparkan atas peta sebagai marker.
6. Pengguna tambah ayat pemerhatian dan cadangan.
7. Pilih template laporan.
8. Aplikasi jana laporan PDF.
9. Pengguna boleh semak, edit, export, atau share laporan.

## Struktur Skrin

- Dashboard projek
- Senarai lawatan
- Borang maklumat lawatan
- Kamera
- Galeri gambar lawatan
- Peta gambar
- Editor catatan
- Preview laporan
- Tetapan template dan level offset

## Data Model Awal

### Project

- id
- projectName
- clientName
- locationName
- createdAt
- levelOffset
- reportTemplateId

### SiteVisit

- id
- projectId
- visitDate
- officerName
- weather
- generalNotes
- conclusion

### SitePhoto

- id
- visitId
- filePath
- latitude
- longitude
- altitude
- adjustedLevel
- horizontalAccuracy
- verticalAccuracy
- capturedAt
- category
- caption
- observation
- recommendation

### ReportTemplate

- id
- name
- layoutType
- includeMap
- includePhotoTable
- includeSummary

## MVP Fasa 1

Fasa pertama yang sesuai dibangunkan:

- Buat projek dan lawatan
- Ambil/import gambar
- Simpan koordinat, altitude, masa, dan nota
- Papar marker gambar atas peta untuk iOS/Android
- Senarai gambar dengan catatan
- Jana laporan PDF asas
- Export/share PDF

## Fasa 2

- Sokongan Windows penuh dengan WebView2 map
- Template laporan boleh disunting
- Auto-generate ayat berdasarkan kategori dan nota
- Sync cloud
- Login pengguna
- Export Word/docx
- Integrasi GNSS/RTK jika perlu ketepatan ukur

## Risiko Teknikal

- Altitude telefon boleh berubah-ubah dan kurang tepat.
- Gambar import daripada galeri mungkin tiada metadata GPS.
- Google Maps pada Windows memerlukan pendekatan WebView atau web map, bukan native Flutter plugin rasmi.
- App Store dan Play Store memerlukan permission text yang jelas untuk kamera, lokasi, dan galeri.

## Rujukan Awal

- Flutter supported deployment platforms: https://docs.flutter.dev/reference/supported-platforms
- Google Maps Flutter package: https://pub.dev/packages/google_maps_flutter
- Flutter camera package: https://pub.dev/packages/camera
