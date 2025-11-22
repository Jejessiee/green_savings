import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/transaction.dart';

// Provider untuk mengelola data transaksi dan komunikasi dengan database
class TransactionProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper(); // Inisialisasi helper database SQLite
  List<TransactionModel> _items = []; // List transaksi yang tersimpan
  bool _loading = true; // Status loading untuk UI

  // Getter untuk akses data transaksi dan status loading
  List<TransactionModel> get items => _items;
  bool get loading => _loading;

  // Constructor: langsung load semua data saat provider dibuat
  TransactionProvider() {
    loadAll();
  }

  // Fungsi untuk mengambil semua data transaksi dari database
  Future<void> loadAll() async {
    print('🔄 [TransactionProvider] loadAll() start');
    _loading = true;
    notifyListeners();

    try {
      // Mengambil data dari SQLite
      _items = await _db.getAllTransactions();
      print('✅ [TransactionProvider] loaded ${_items.length} transactions');
    } catch (e, st) {
      print('❌ [TransactionProvider] error in loadAll: $e');
      print(st);
      _items = [];
    }

    _loading = false;
    notifyListeners();
    print('🔵 [TransactionProvider] loadAll() finished');
  }

  // Fungsi untuk menambahkan transaksi baru ke database
  Future<void> addTransaction(TransactionModel t) async {
    try {
      await _db.insertTransaction(t); // Simpan ke SQLite
      await loadAll();
    } catch (e) {
      print('❌ addTransaction error: $e');
    }
  }

  // Fungsi untuk mengupdate transaksi yang sudah ada
  Future<void> updateTransaction(TransactionModel t) async {
    try {
      await _db.updateTransaction(t); // Update data di SQLite
      await loadAll();
    } catch (e) {
      print('❌ updateTransaction error: $e');
    }
  }

  // Fungsi untuk menghapus transaksi berdasarkan ID
  Future<void> removeTransaction(int id) async {
    try {
      await _db.deleteTransaction(id); // Hapus dari SQLite
      await loadAll();
    } catch (e) {
      print('❌ removeTransaction error: $e');
    }
  }
}
