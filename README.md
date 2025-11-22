# Green Savings App

GreenSavings adalah sebuah aplikasi mobile Finance Tracker (pengelolaan keuangan) personal yang cerdas dan interaktif, dikembangkan dengan menggunakan framework **Flutter** dengan bahasa pemrograman **Dart**.

Aplikasi ini tidak hanya membantu user dalam mencatat pemasukan (income) dan pengeluaran (expenses), tetapi juga dilengkapi dengan **AI Financial Advisor (Leafy)** yang dapat memberikan saran keuangan, serta fitur konversi mata uang asing secara real-time.

## Fitur Utama

### 🌟 Fitur Baru (v2.0)
* **AI Financial Advisor (Tanya Leafy):** Terintegrasi dengan **Google Gemini AI**, pengguna dapat berkonsultasi mengenai pola pengeluaran dan meminta saran hemat langsung di dalam aplikasi.
* **Multi-Currency Support:** Fitur konversi mata uang otomatis menggunakan **Frankfurter API**. Pengguna dapat mencatat transaksi dalam mata uang asing (USD, SGD, EUR, dll) dan otomatis terkonversi ke IDR.
* **Sistem Login & Register:** Manajemen autentikasi pengguna yang aman menggunakan **Firebase Authentication**.
* **Cloud User Profile:** Penyimpanan data profil pengguna secara online menggunakan **Cloud Firestore**.

### 🚀 Fitur Inti
* **Pencatatan Transaksi:** Menambah dan mengelola transaksi keuangan (income & expenses).
* **Visualisasi Data:** Grafik interaktif (Bar Chart & Sunburst Chart) untuk memantau aliran dana.
* **Smart Budgeting:** Fitur penetapan anggaran bulanan per kategori dengan indikator batas pemakaian.
* **Riwayat Transaksi:** List transaksi yang detail berdasarkan tanggal.

## Arsitektur & Database (Hybrid)

Aplikasi ini menggunakan pendekatan **Hybrid Database** untuk keamanan dan performa:

1.  **SQLite (Lokal):** Digunakan untuk menyimpan data **Transaksi** dan **Budget**. Ini memastikan aplikasi tetap cepat, responsif, dan data keuangan tersimpan privat di perangkat pengguna.
2.  **Firebase (Cloud):**
    * **Authentication:** Menangani proses Login dan Register.
    * **Firestore:** Menyimpan data profil pengguna (Nama, Email, Tanggal Bergabung).

## API & Layanan yang Digunakan

* **Google Gemini AI:** Untuk fitur asisten keuangan cerdas "Tanya Leafy".
* **Frankfurter API:** Untuk mendapatkan nilai tukar mata uang asing secara *real-time*.
* **Firebase Auth & Firestore:** Untuk manajemen pengguna dan penyimpanan profil.

## Dependencies Utama

* **State Management:** `provider`
* **Local Database:** `sqflite`, `path_provider`
* **Cloud & Auth:** `firebase_core`, `firebase_auth`, `cloud_firestore`
* **AI & Networking:** `google_generative_ai`, `http`
* **UI & Utilities:** `intl`, `fl_chart`, `flutter_launcher_icons`

## Desain & Branding

* **Warna Utama:** Mint Green dan Blush Pink (Nuansa pastel yang ramah).
* **Maskot:** **Leafy** (Karakter daun cerdas yang menemani pengguna).
* **UI/UX:** Desain bersih dengan navigasi intuitif dan *Floating Action Button* untuk akses cepat ke AI.

## Struktur Project

* `models`: Struktur data (Transaction, Budget, User).
* `providers`: Logika bisnis dan state management.
* `services`: Komunikasi dengan API eksternal (AuthService, CurrencyService, GeminiService).
* `data`: Manajemen database lokal (DbHelper).
* `screens`: Halaman antarmuka (Login, Home, Analysis, Transaction Entry, Transaction Edit, AI Chat).
* `widgets`: Komponen UI reusable (BottomNavBar, Transaction Card).
* `main.dart`: Entry point aplikasi.

## Cara Menjalankan Project

1.  **Prasyarat:**
    * Pastikan Flutter SDK terinstall (Versi terbaru).
    * Pastikan memiliki file `google-services.json` di folder `android/app/` (Diperlukan untuk koneksi Firebase).
    * Mendapatkan API Key Google Gemini (untuk fitur AI).

2.  **Instalasi:**
    Jalankan command berikut di terminal proyek:
    ```bash
    flutter pub get
    ```

3.  **Menjalankan Aplikasi:**
    Hubungkan device (HP/Emulator) dan jalankan:
    ```bash
    flutter run
    ```

**Catatan Penting:**
* Aplikasi ini membutuhkan **Minimum Android SDK 28** (Android 9.0) karena penggunaan library terbaru.
* Pastikan koneksi internet aktif untuk fitur Login, Konversi Mata Uang, dan Chat AI.

---

**Dibuat oleh:**
* Evangeline Audrey Kartawahyudi (825230015)
* Jessica (825230027)
* Selvanie (825230111)

**Leafy hadir untuk menemani kamu menabung dengan senyum 🌿**