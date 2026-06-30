# Cara Install Aplikasi Lawatan Tapak

## 1. Windows

Guna Microsoft Edge atau Google Chrome.

1. Hidupkan server:

   ```powershell
   cd "C:\Users\WORK\OneDrive\Documents\Lawatan Tapak\lawatan_tapak_pwa"
   .\start-server.ps1
   ```

2. Buka link aplikasi, contoh `http://localhost:8787`.
3. Tekan ikon install pada address bar.
4. Jika ikon tidak muncul, buka menu browser.
5. Pilih `Apps` > `Install this site as an app`.
6. Aplikasi akan muncul dalam Start Menu Windows.

## 2. Android

Guna Google Chrome atau Microsoft Edge.

1. Buka link aplikasi.
2. Tekan menu tiga titik.
3. Pilih `Install app` atau `Add to Home screen`.
4. Tekan `Install`.
5. Aplikasi akan muncul pada Home Screen.

Nota: Untuk app yang independent dan GPS penuh, gunakan link HTTPS selepas publish. Rujuk `DEPLOY_HTTPS.md`.

## 3. iPhone

Guna Safari.

1. Buka link aplikasi dalam Safari.
2. Tekan ikon `Share`.
3. Pilih `Add to Home Screen`.
4. Tekan `Add`.
5. Aplikasi akan muncul pada Home Screen.

Nota: iPhone biasanya memerlukan HTTPS untuk geolocation. Untuk penggunaan independent, publish aplikasi ini ke HTTPS.

## 4. Publish Supaya Ada Link Tetap

Rujuk [DEPLOY_HTTPS.md](DEPLOY_HTTPS.md). Selepas publish, gunakan link HTTPS yang diberi oleh platform tersebut. Link ini boleh digunakan tanpa WiFi yang sama.

## 5. Cara Guna Selepas Install

1. Buka aplikasi.
2. Isi maklumat projek.
3. Tekan `Ambil gambar` atau `Import gambar`.
4. Benarkan akses lokasi jika diminta.
5. Semak koordinat, altitude dan adjusted level.
6. Tambah ayat pemerhatian atau cadangan.
7. Lukis anak panah lurus atau bulatan pada gambar jika perlu.
8. Buka tab `Peta` untuk semak marker.
9. Buka tab `Laporan`.
10. Tekan `Print / Save PDF`.
