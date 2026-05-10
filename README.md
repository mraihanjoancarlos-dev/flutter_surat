# SIMFARS Flutter App
## Panduan Setup Lengkap

---

## 📁 Struktur Project

```
simfars/
├── api/                        ← Upload ke server hosting
│   ├── config.php              ← Konfigurasi DB + helper token
│   ├── login.php               ← POST /api/login.php
│   ├── dashboard.php           ← GET  /api/dashboard.php
│   ├── surat_masuk.php         ← CRUD surat masuk
│   └── surat_keluar.php        ← CRUD surat keluar
│
└── flutter_app/                ← Project Flutter
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── core/
        │   └── theme.dart      ← Warna & tema (sama dg web)
        ├── services/
        │   └── api_service.dart← HTTP client ke PHP API
        └── screens/
            ├── login_screen.dart
            ├── main_screen.dart
            ├── dashboard_screen.dart
            ├── surat_masuk_screen.dart
            └── surat_keluar_screen.dart
```

---

## 🚀 LANGKAH 1 — Setup API PHP di Server

1. **Upload folder `/api/`** ke dalam folder web kamu di hosting/server.
   Contoh: `public_html/api/` atau `htdocs/simfars/api/`

2. **Edit `config.php`** — sesuaikan:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'nama_user_mysql');
   define('DB_PASS', 'password_mysql');
   define('DB_NAME', 'db_surat');         // nama DB yang sudah ada
   define('JWT_SECRET', 'ganti_ini_random_string_panjang');
   ```

3. **Database sudah ada** karena pakai DB yang sama dengan web.
   Tidak perlu import ulang SQL.

4. **Test API** di browser:
   ```
   GET https://domain-kamu.com/api/dashboard.php
   → harusnya muncul: {"status":"error","message":"Unauthorized..."}
   ```
   Kalau muncul response JSON berarti API sudah jalan ✅

---

## 📱 LANGKAH 2 — Setup Flutter

### Install Flutter
```bash
# Cek versi Flutter
flutter --version   # minimal 3.x

# Install dependencies
cd flutter_app
flutter pub get
```

### Edit Base URL API
Buka `lib/services/api_service.dart`, ganti:
```dart
static const String baseUrl = 'https://domain-kamu.com/api';
// Contoh: 'https://simfars.myserver.com/api'
// Atau localhost pakai IP: 'http://192.168.1.5/simfars/api'
```

> ⚠ **Untuk emulator Android**, gunakan `http://10.0.2.2/simfars/api`
> ⚠ **Untuk device fisik**, gunakan IP lokal komputer: `http://192.168.x.x/simfars/api`

### Izin Internet (Android)
File `android/app/src/main/AndroidManifest.xml`, tambahkan:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Untuk HTTP (bukan HTTPS) di `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"   ← tambahkan ini
    ...>
```

---

## 🔨 LANGKAH 3 — Build APK

```bash
cd flutter_app

# Debug APK (untuk testing)
flutter build apk --debug

# Release APK (untuk distribusi)
flutter build apk --release

# APK tersimpan di:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Cara Kerja Login & Token

```
Flutter App
    │
    ├─ POST /api/login.php  { username, password }
    │
    └─ Response: { token: "xxx.yyy", admin: {...} }
           │
           └─ Token disimpan di SharedPreferences
              Setiap request berikutnya kirim:
              Header: "Authorization: Bearer xxx.yyy"
```

Token berlaku **24 jam**. Setelah expired, user perlu login ulang.

---

## 📋 Default Login

| Field    | Value      |
|----------|------------|
| Username | `admin`    |
| Password | `password` |

> Password di database menggunakan `password_hash()` PHP.
> Default hash di database.sql adalah untuk kata sandi: **password**

---

## ❓ Troubleshooting

| Masalah | Solusi |
|---------|--------|
| "Tidak dapat terhubung ke server" | Cek baseUrl di api_service.dart |
| API tidak merespons | Cek CORS di config.php, pastikan header sudah ada |
| Login gagal padahal data benar | Pastikan password di DB di-hash dengan password_hash() |
| APK tidak bisa HTTP | Tambahkan `android:usesCleartextTraffic="true"` |
| Emulator tidak connect | Gunakan `10.0.2.2` bukan `localhost` |
