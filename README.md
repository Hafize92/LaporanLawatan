# Lawatan Tapak PWA

Ini ialah aplikasi laporan lawatan tapak versi PWA yang boleh dipasang secara independent pada:

- iPhone melalui Safari Add to Home Screen
- Android melalui Chrome/Edge Install app
- Windows melalui Chrome/Edge Install app

Untuk tidak bergantung kepada WiFi yang sama, publish folder ini ke hosting HTTPS. Lihat [docs/DEPLOY_HTTPS.md](docs/DEPLOY_HTTPS.md).

Jika guna repository GitHub ini, workflow GitHub Pages akan publish aplikasi ke:

```text
https://hafize92.github.io/LaporanLawatan/
```

## Fungsi

- Maklumat projek dan lawatan
- Ambil gambar atau import gambar
- Simpan koordinat, altitude, adjusted level dan accuracy
- Baca GPS daripada EXIF gambar jika tersedia
- Ambil GPS ketepatan tinggi melalui browser jika dibenarkan
- Simpan GPS / lokasi lawatan
- Kategori: Kerja tanah, Jalan, Sistem saliran, Retikulasi air, Pembentungan
- Lukis anak panah lurus pelbagai warna secara manual pada gambar dengan mouse/touch
- Lukis bulatan pelbagai warna dengan diskripsi pada gambar
- Tambah ayat pemerhatian dan cadangan
- Papar marker gambar dalam peta ringkas
- Buka marker dan laluan dalam Google Maps
- Preview laporan
- Print / Save PDF
- Export HTML laporan
- Export/import data JSON
- Simpan data offline menggunakan IndexedDB

## Cara Dapat Link Independent

Untuk Android/iPhone/Windows tanpa perlu WiFi yang sama:

1. Upload folder `lawatan_tapak_pwa` ke hosting HTTPS, atau deploy terus daripada GitHub repository.
2. Guna link HTTPS yang diberi oleh hosting tersebut.
3. Buka link itu pada iPhone, Android atau Windows.
4. Install app melalui browser.
5. App boleh terus digunakan.

Panduan penuh ada di [docs/DEPLOY_HTTPS.md](docs/DEPLOY_HTTPS.md).

## Cara Preview Di Komputer Ini

Masuk ke folder:

```powershell
cd "C:\Users\WORK\OneDrive\Documents\Lawatan Tapak\lawatan_tapak_pwa"
```

Jalankan static server:

```powershell
.\start-server.ps1
```

Buka untuk preview di Windows:

```text
http://localhost:8787
```

Untuk preview telefon sebelum publish, telefon dan komputer perlu berada pada WiFi yang sama, kemudian buka:

```text
http://IP-KOMPUTER:8787
```

Contoh:

```text
http://192.168.1.25:8787
```

## Nota Penting Untuk GPS Dan Link Independent

Browser moden biasanya memerlukan HTTPS untuk geolocation, kecuali `localhost`.

- Windows pada komputer yang sama: `http://localhost:8787` boleh guna GPS jika device menyokong lokasi.
- Link independent untuk iPhone/Android/Windows perlu HTTPS.
- iPhone/Android melalui IP WiFi seperti `http://192.168.x.x:8787` sesuai untuk preview sahaja; GPS mungkin disekat kerana bukan HTTPS.
- Untuk GPS penuh pada iPhone/Android, host folder ini ke HTTPS seperti GitHub Pages, Netlify, Cloudflare Pages, Vercel, atau server sendiri dengan SSL.

## Cara Install

Lihat [docs/INSTALL.md](docs/INSTALL.md).
