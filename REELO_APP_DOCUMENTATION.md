# Reelo — Local Video Reels App
> Dokumentasi Komprehensif untuk Vibe Coding dengan Claude Code

---

## 1. Deskripsi Aplikasi

**Reelo** adalah aplikasi Android yang memungkinkan pengguna menonton video pendek dari penyimpanan lokal HP secara fullscreen dengan tampilan swipe-able mirip Instagram Reels atau TikTok. Video diputar secara acak (random shuffle) dari folder yang telah dipilih pengguna, dan pengaturan folder tersebut tersimpan secara permanen di perangkat.

### Tagline
> *"Your local videos. Reels-style. No internet needed."*

---

## 2. Tujuan & Motivasi

- Menonton koleksi video lokal di HP dengan cara yang lebih menyenangkan dan immersive
- Tidak bergantung pada koneksi internet atau platform streaming
- Privasi penuh — video tidak pernah diunggah ke server manapun
- Pengalaman menonton yang simpel: buka aplikasi, langsung putar

---

## 3. Target Platform

| Properti | Detail |
|---|---|
| Platform | Android |
| Minimum SDK | API 26 (Android 8.0 Oreo) |
| Target SDK | API 33 (Android 13) |
| Distribusi | GitHub Releases (APK) |

---

## 4. Tech Stack

| Komponen | Teknologi | Versi |
|---|---|---|
| Framework | Flutter | ^3.x (stable) |
| Bahasa | Dart | ^3.x |
| State Management | Provider atau Riverpod | Latest |
| Video Player | `video_player` | ^2.x |
| Video UI | `chewie` | ^1.x |
| File Picker | `file_picker` | ^6.x |
| Penyimpanan Setting | `shared_preferences` | ^2.x |
| Permission Handler | `permission_handler` | ^11.x |
| Path Utility | `path` | ^1.x |

---

## 5. Fitur Aplikasi

### 5.1 Fitur Utama (MVP)

| Fitur | Deskripsi |
|---|---|
| **Auto-play saat buka** | Langsung memutar video begitu aplikasi dibuka, tanpa layar loading tambahan |
| **Random shuffle** | Urutan video diacak setiap sesi dibuka |
| **Swipe Up** | Pindah ke video berikutnya |
| **Swipe Down** | Kembali ke video sebelumnya |
| **Tap layar** | Pause / Resume video |
| **Pilih folder** | Pengguna memilih satu folder dari storage lokal HP |
| **Simpan pengaturan folder** | Path folder tersimpan secara permanen (SharedPreferences) |
| **Fullscreen** | Video ditampilkan fullscreen tanpa status bar / navigation bar |

### 5.2 Fitur Tambahan (Post-MVP, Opsional)

- Loop otomatis saat video selesai sebelum swipe
- Indikator progress video (progress bar tipis di bagian bawah)
- Tampilkan nama file video di overlay
- Ganti folder via long press atau menu settings
- Animasi transisi antar video

---

## 6. Alur Aplikasi (User Flow)

```
Pengguna membuka Reelo
        │
        ▼
Cek SharedPreferences: apakah folder sudah disetting?
        │
   ┌────┴────┐
  BELUM     SUDAH
   │          │
   ▼          ▼
Tampilkan   Load semua file video (.mp4, .mkv, dll)
layar       dari folder yang tersimpan
"Pilih        │
Folder"       ▼
   │        Acak urutan video (shuffle)
   │          │
   ▼          ▼
User       Tampilkan video pertama — auto-play fullscreen
pilih        │
folder       ├── Swipe Up   → Video berikutnya (random)
   │         ├── Swipe Down → Video sebelumnya
   ▼         ├── Tap        → Pause / Resume
Simpan       └── Long Press → Opsi ganti folder
ke
SharedPreferences
   │
   ▼
Lanjut ke
load video
```

---

## 7. Roadmap Pengembangan

### Phase 1 — Core Logic (Estimasi: 1–2 minggu)
- [ ] Implementasi `permission_handler` untuk akses storage
- [ ] Implementasi `file_picker` untuk pilih folder
- [ ] Implementasi `StorageService` (SharedPreferences)
- [ ] Implementasi `FileService` (scan & shuffle video)
- [ ] Buat `SplashScreen` dengan logika redirect

### Phase 2 — UI & Video Player (Estimasi: 1–2 minggu)
- [ ] Buat `VideoFeedScreen` dengan `PageView.builder` vertikal
- [ ] Integrasi `video_player` + `chewie` untuk tiap item
- [ ] Auto-play saat video masuk layar
- [ ] Pause/play dengan tap gesture
- [ ] Fullscreen tanpa status bar

### Phase 3 — Polish & Distribusi (Estimasi: 3–5 hari)
- [ ] Test di HP fisik via USB
- [ ] Setup GitHub repository
- [ ] Setup GitHub Actions untuk auto-build APK
- [ ] Buat Release di GitHub

---

## 8. Catatan Penting

### Kompatibilitas Storage Android

| Versi Android | API | Permission yang Dipakai |
|---|---|---|
| Android 8–9 | API 26–28 | `READ_EXTERNAL_STORAGE` |
| Android 10–12 | API 29–32 | `READ_EXTERNAL_STORAGE` |
| Android 13+ | API 33+ | `READ_MEDIA_VIDEO` |

### Format Video yang Didukung
`.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`, `.3gp`
> Kompatibilitas bergantung pada codec yang tersedia di perangkat pengguna. Format `.mp4` (H.264) paling aman dan universal.
---

## 9. Referensi & Dokumentasi

- [Flutter Official Docs](https://docs.flutter.dev)
- [video_player package](https://pub.dev/packages/video_player)
- [chewie package](https://pub.dev/packages/chewie)
- [file_picker package](https://pub.dev/packages/file_picker)
- [permission_handler package](https://pub.dev/packages/permission_handler)
- [shared_preferences package](https://pub.dev/packages/shared_preferences)
- [GitHub Actions Flutter](https://github.com/subosito/flutter-action)

---

*Dokumen ini dibuat sebagai panduan vibe coding menggunakan Claude Code. Versi: 1.0 | Platform: Android*
