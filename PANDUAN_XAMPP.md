# SIMFARS — Panduan Setup XAMPP

---

## 📂 LANGKAH 1 — Letakkan File API di XAMPP

1. Buka folder XAMPP kamu:
   - Windows: `C:\xampp\htdocs\`
   - Mac/Linux: `/Applications/XAMPP/htdocs/`

2. Buat folder baru: `htdocs\simfars\`

3. **Copy folder `api/`** ke dalam folder simfars:
   ```
   C:\xampp\htdocs\simfars\api\
       ├── config.php
       ├── login.php
       ├── dashboard.php
       ├── surat_masuk.php
       └── surat_keluar.php
   ```

4. **Pastikan XAMPP Apache & MySQL sudah Running** (hijau di XAMPP Control Panel)

---

## 🗄️ LANGKAH 2 — Cek Database

Database kamu sudah ada (`db_surat`) karena web sudah jalan.
**Tidak perlu import SQL lagi.**

Cek saja di phpMyAdmin: `http://localhost/phpmyadmin`
→ pastikan database `db_surat` ada dengan tabel `admin`, `surat_masuk`, `surat_keluar`

---

## ✅ LANGKAH 3 — Test API

Buka browser, akses:
```
http://localhost/simfars/api/login.php
```

Harusnya muncul:
```json
{"status":"error","message":"Method tidak diizinkan"}
```

Kalau muncul JSON seperti itu → **API sudah jalan!** ✅

Kalau muncul error PHP atau 404 → cek lokasi folder api.

---

## 📱 LANGKAH 4 — Setting Flutter Berdasarkan Cara Testing

### A) Pakai Emulator Android (AVD)
File `lib/services/api_service.dart` sudah diset:
```dart
static const String baseUrl = 'http://10.0.2.2/simfars/api';
```
**10.0.2.2** adalah alamat khusus emulator untuk mengakses localhost komputer. ✅

### B) Pakai HP Fisik (USB/WiFi)
1. Cari IP komputer kamu:
   - Windows: buka CMD → ketik `ipconfig` → lihat **IPv4 Address**
   - Contoh: `192.168.1.5`

2. Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.5/simfars/api';
   //                                      ↑ ganti dengan IP komputer kamu
   ```

3. Pastikan HP dan komputer **terhubung ke WiFi yang sama**

---

## 🔨 LANGKAH 5 — Jalankan / Build APK

```bash
# Masuk ke folder flutter_app
cd flutter_app

# Install dependencies
flutter pub get

# Jalankan di emulator/device (testing)
flutter run

# Build APK release
flutter build apk --release

# File APK ada di:
# flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

---

## ❓ Troubleshooting XAMPP

| Masalah | Solusi |
|---------|--------|
| `SocketException: Connection refused` | XAMPP Apache belum running, atau salah IP/port |
| `404 Not Found` | Cek path folder: harus di `htdocs/simfars/api/` |
| Login gagal terus | Cek password di DB pakai `password_hash()`. Buka phpMyAdmin → tabel admin → lihat kolom password |
| HP fisik tidak connect | Pastikan satu WiFi, cek firewall Windows (matikan sementara untuk test) |
| Emulator tidak connect | Pastikan baseUrl pakai `10.0.2.2` bukan `localhost` |

---

## 🔑 Default Login

```
Username : admin
Password : password
```
