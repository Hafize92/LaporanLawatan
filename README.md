# Laporan Lawatan Tapak

Aplikasi laporan lawatan tapak untuk iPhone, Android dan Windows.

## Link Kod GitHub

Kod aplikasi berada di repository:

```text
https://github.com/Hafize92/LaporanLawatan
```

Branch kerja yang dipush oleh Codex:

```text
codex/lawatan-tapak-pwa-drawing
```

## Link Aplikasi

GitHub Pages workflow dalam repository ini akan publish folder `lawatan_tapak_pwa` sebagai PWA.
Selepas workflow selesai, link aplikasi dijangka:

```text
https://hafize92.github.io/LaporanLawatan/
```

Jika link belum aktif, pergi ke `Settings` > `Pages` di GitHub dan pastikan source Pages ialah `GitHub Actions`, kemudian run workflow `Deploy PWA to GitHub Pages`.

## Login

Code login default:

```text
123456
```

Tukar code selepas login melalui tab `Tetapan`.

## Fungsi Utama

- Laporan lawatan tapak dengan maklumat projek, tarikh, pegawai, cuaca dan nota.
- GPS/lokasi lawatan dengan pilihan ketepatan tinggi.
- Gambar tapak dengan koordinat, altitude, adjusted level dan accuracy.
- Kategori kerja: Kerja tanah, Jalan, Sistem saliran, Retikulasi air dan Pembentungan.
- Lukis anak panah lurus dan bulatan pada gambar menggunakan mouse atau touch screen.
- Warna markup boleh ditukar, dan bulatan boleh ada diskripsi.
- Integrasi Google Maps untuk marker lokasi dan gambar.
- Export HTML, print/save PDF, export/import JSON.
- Boleh dipasang sebagai PWA di iPhone, Android dan Windows.

## Folder Penting

- `lawatan_tapak_pwa` - aplikasi PWA yang boleh dipublish ke HTTPS.
- `lawatan_tapak_app` - scaffold Flutter untuk pembangunan native iOS, Android dan Windows.
- `SPESIFIKASI_APLIKASI.md` - spesifikasi fungsi aplikasi dalam Bahasa Melayu.

## Install

Panduan install penuh:

```text
lawatan_tapak_pwa/docs/INSTALL.md
```

Panduan publish HTTPS:

```text
lawatan_tapak_pwa/docs/DEPLOY_HTTPS.md
```
