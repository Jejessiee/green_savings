# Green Savings App
GreenSavings adalah sebuah aplikasi mobile Finance Tracker (pengelolaan keuangan) personal yang dikembangkan dengan menggunakan framework Flutter dengan bahasa pemrograman dart.

Aplikasi ini dapat membantu user dalam membuat pencatatan pemasukan (income) dan pengeluaran (expenses) secara visual, ringan, dan menyenangkan. Aplikasi ini dirancang untuk mendorong kebiasaan menabung dengan cara yang ramah dan menyenangkan.

## Fitur Utama
- Menambah dan mengelola transaksi keuangan (income & expenses)
- Visualisasi data keuangan dalam bentuk grafik (bar chart & sunburst chart)
- Riwayat transaksi berdasarkan tanggal dan kategori
- Fitur budgetting sesuai kategori

## Dependencies yang digunakan
- provider : state management
- sqflite : Database lokal SQLite
- path_provider : akses direktori lokal
- intl : format tanggal & angka
- fl_chart : grafik keuangan
- flutter_launcher_icons : custom icon untuk aplikasi

## Database
Menggunakan SQLite yang disediakan oleh sqflite untuk menyimpan data transaksi dan data budgetting secara lokal (offline support)

## Desain & Branding
- warna utama : Mint green dan Blush Pink
- Maskot : **Leafy** (karakter daun chibi yang muncul di UI aplikasi)
- UI yang clean dan responsif, cocok untuk semua target pengguna

## Struktur Project
- models : struktur data transaksi
- providers : state management
- screens : halaman utama dari aplikasi
- widgets : komponen UI yang reusable (contohnya: BottomNavigationBar)
- main.dart : entry point dari aplikasi

## Cara menjalankan project
- pilih device (disarankan langsung emulate ke handphone)
Jalankan command berikut di cmd android studio/visual studio code
- flutter pub get
- flutter run

Catatan:
- Pastikan Flutter SDK yang terinstall sudah versi terbaru

Dibuat oleh:
- Evangeline Audrey Kartawhayudi (825230015)
- Jessica (825230027)
- Selvanie (825230111)

**Leafy hadir untuk menemani kamu menabung dengan senyum**
