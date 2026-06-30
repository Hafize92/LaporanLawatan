# Publish Sebagai Link Independent

Untuk aplikasi ini tidak bergantung kepada WiFi yang sama, folder `lawatan_tapak_pwa` perlu dipublish ke hosting HTTPS. Selepas itu, link HTTPS boleh dibuka dan dipasang pada iPhone, Android dan Windows dari mana-mana rangkaian.

Untuk GitHub, push folder `lawatan_tapak_pwa` dan aktifkan GitHub Pages. Untuk upload manual ke Netlify Drop, upload folder `lawatan_tapak_pwa` atau ZIP yang dijana daripada folder tersebut.

## Pilihan Paling Mudah: Netlify Drop

1. Buka https://app.netlify.com/drop
2. Drag folder `lawatan_tapak_pwa` ke halaman tersebut.
3. Netlify akan beri link HTTPS seperti:

   ```text
   https://nama-site.netlify.app
   ```

4. Buka link itu di iPhone/Android/Windows.
5. Install app melalui browser.

## Cloudflare Pages

1. Buka Cloudflare Pages.
2. Create project.
3. Upload folder `lawatan_tapak_pwa` atau sambung kepada Git repository.
4. Build command: kosongkan.
5. Output directory: `/` atau root folder.
6. Deploy.

## GitHub Pages

1. Buat repository baru.
2. Upload semua fail dalam `lawatan_tapak_pwa`.
3. Pergi ke `Settings` > `Pages`.
4. Pilih branch `main` dan folder root.
5. Simpan.
6. GitHub akan beri link HTTPS.

## Vercel

1. Buat project baru.
2. Import repository atau upload folder.
3. Framework preset: `Other`.
4. Build command: kosongkan.
5. Output directory: kosongkan atau root.
6. Deploy.

## Nota GPS

GPS ketepatan tinggi pada iPhone dan Android biasanya memerlukan HTTPS. Selepas app dipublish ke HTTPS:

- GPS lawatan boleh digunakan.
- GPS gambar boleh digunakan.
- App boleh dipasang sebagai PWA.
- Selepas dipasang, app boleh dibuka semula walaupun offline kerana service worker menyimpan fail asas.

Data projek dan gambar disimpan dalam peranti pengguna menggunakan IndexedDB. Gunakan `Export JSON` untuk backup atau pindah data.
