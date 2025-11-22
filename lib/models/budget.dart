// Model data untuk anggaran (budget) bulanan pengguna
class Budget {
  final int? id; // ID anggaran (nullable, karena bisa auto-increment dari database)
  final String category; // Kategori anggaran (misal: Makanan, Transportasi)
  final double limitAmount; // Batas maksimal pengeluaran untuk kategori tersebut
  final String month; // Bulan anggaran dalam format string (misal: "Oktober 2025")

  // Constructor untuk membuat objek anggaran
  Budget({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
  });

  // Konversi objek Budget ke Map (untuk disimpan ke database SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'month': month,
    };
  }

  // Factory constructor untuk membuat objek Budget dari Map (saat ambil dari database)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      // Memastikan nilai limitAmount selalu dalam bentuk double
      limitAmount: map['limitAmount'] is int
          ? (map['limitAmount'] as int).toDouble()
          : map['limitAmount'],
      month: map['month'],
    );
  }
}
