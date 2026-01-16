# Aplikasi Manajemen Lagu

Aplikasi Android sederhana berbasis Flutter untuk autentikasi user dan CRUD data lagu menggunakan SQLite.

Aplikasi ini dibuat menggunakan Flutter (Dart) yang memungkinkan pengguna untuk:

- Login menggunakan username dan password
- Mengelola data lagu (tambah, ubah, hapus, lihat)
- Menyimpan data secara lokal menggunakan SQLite (sqflite)

## Fitur

- Autentikasi user (Login)
- CRUD data lagu
  - Judul lagu
  - Penyanyi
  - Genre
- Penyimpanan data lokal menggunakan SQLite
- Validasi input form
- Tampilan UI sederhana dan responsif

## Teknologi

- Flutter (Dart)
- SQLite (sqflite)
- SharedPreferences
- Material Design

## Alur Aplikasi

1. Aplikasi dibuka
2. User login menggunakan username dan password (admin/admin)
3. Jika login berhasil, user masuk ke halaman utama
4. User dapat menambah, mengedit, atau menghapus data lagu
5. Data disimpan secara lokal menggunakan SQLite

## Cara Menjalankan Aplikasi

1. Clone repository ini
2. Jalankan perintah:
   flutter clean
   flutter pub get
3. Hubungkan emulator atau device
4. Jalankan aplikasi:
   flutter run

## Akun Login

Username: admin  
Password: admin
