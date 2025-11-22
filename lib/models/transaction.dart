// Enum untuk tipe transaksi: pemasukan atau pengeluaran
enum TransactionType { income, expense }

// Model data untuk transaksi keuangan
class TransactionModel {
  final int? id; // ID transaksi (nullable, karena bisa auto-increment)
  final String userId; // Untuk membedakan data antar user
  final String description; // Deskripsi atau catatan transaksi
  final double amount; // Jumlah uang
  final String category; // Kategori transaksi (misal: Makanan, Gaji)
  final TransactionType type; // Tipe transaksi (income/expense)
  final DateTime date; // Tanggal transaksi
  final String originalCurrency; // Mata uang awal
  final double originalAmount;   // Nilai awal

  // Constructor untuk membuat objek transaksi
  TransactionModel({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.originalCurrency = 'IDR',
    double? originalAmount,
  }) : this.originalAmount = originalAmount ?? amount; // Jika null, samakan dengan amount

  // Konversi objek transaksi ke Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // SQLite butuh ID jika update, tapi null jika insert (auto-generate)
      'userId': userId, // Simpan ID pemilik data
      'description': description,
      'amount': amount,
      'category': category,
      'type': type == TransactionType.income ? 1 : 0, // 1 = income, 0 = expense
      'date': date.toIso8601String(), // Format untuk tanggal
      'originalCurrency': originalCurrency,
      'originalAmount': originalAmount,
    };
  }

  // Factory constructor untuk membuat objek dari Map (saat ambil dari database)
  factory TransactionModel.fromMap(Map<String, dynamic> m) {
    return TransactionModel(
      id: m['id'] as int?,
      userId: m['userId'] ?? '',
      description: m['description'] as String,
      amount: (m['amount'] as num).toDouble(),
      category: m['category'] as String,
      type: (m['type'] as int) == 1
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(m['date'] as String),
      originalCurrency: m['originalCurrency'] ?? 'IDR',
      originalAmount: (m['originalAmount'] as num?)?.toDouble() ?? (m['amount'] as num).toDouble(),
    );
  }
}
