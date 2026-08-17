<p align="center">
  <img src="assets/icon/icon.png" width="120" alt="Reelo logo" />
</p>

<h1 align="center">Reelo</h1>

<p align="center">
  <em>Your local videos. Reels-style. No internet needed.</em>
</p>

Reelo memutar koleksi video lokal di HP kamu secara fullscreen dengan tampilan swipe-able ala Instagram Reels / TikTok — video diacak dari satu folder pilihanmu, sepenuhnya offline. Tidak ada upload, tidak ada tracking, tidak butuh internet sama sekali.

## Fitur

- **Auto-play saat dibuka** — langsung memutar video begitu app dibuka, tanpa loading screen tambahan
- **Random shuffle** — urutan video diacak tiap kali sesi dibuka
- **Swipe up/down** — pindah ke video berikutnya / sebelumnya
- **Tap layar** — pause / resume
- **Seek ±10 detik** — kontrol cepat maju/mundur
- **Fullscreen murni** — tanpa status bar maupun navigation bar
- **Pilih & simpan folder** — path folder tersimpan permanen, tidak perlu pilih ulang tiap buka app

## Download

Unduh APK terbaru dari halaman **[Releases](../../releases/latest)**, lalu:

1. Buka file `.apk` yang sudah diunduh di HP Android kamu.
2. Kalau muncul peringatan "Install blocked" / "Unknown sources", izinkan instalasi dari sumber tersebut (Settings > izinkan untuk browser/file manager yang kamu pakai).
3. Install dan buka Reelo, lalu pilih folder berisi video kamu.

**Requirement:** Android 8.0 (Oreo, API 26) ke atas.

## Format video yang didukung

`.mp4` `.mkv` `.avi` `.mov` `.webm` `.3gp`

Kompatibilitas playback tergantung codec yang tersedia di perangkat — `.mp4` (H.264) paling aman dan universal.

## Build dari source

```bash
flutter pub get
flutter run                     # jalankan di device/emulator
flutter build apk --release     # build APK release
```

Lihat [CLAUDE.md](CLAUDE.md) untuk detail arsitektur dan struktur project, atau [REELO_APP_DOCUMENTATION.md](REELO_APP_DOCUMENTATION.md) untuk spesifikasi lengkap.

## Privasi

Reelo tidak punya koneksi internet sama sekali — semua video diputar langsung dari storage lokal HP kamu. Tidak ada data yang dikirim ke mana pun.
