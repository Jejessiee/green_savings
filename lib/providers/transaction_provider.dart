import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/db_helper.dart';
import '../models/transaction.dart';

// Provider untuk mengelola data transaksi di database SQLite
class TransactionProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper();
  List<TransactionModel> _items = []; // List transaksi yang tersimpan
  bool _loading = false; // Status loading untuk UI

  // Getter untuk akses data transaksi dan status loading
  List<TransactionModel> get items => _items;
  bool get loading => _loading;

  // Ambil User ID dari Firebase Auth
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

    // Fungsi untuk mengambil semua data transaksi dari database
  Future<void> loadAll() async {
    // Keamanan: Jika user belum login, jangan tampilkan data apa pun
    if (_userId.isEmpty) {
      _items = [];
      notifyListeners();
      return;
    }

    print('🔄 [TransactionProvider] Loading data for UserID: $_userId');
    _loading = true;
    notifyListeners();

    try {
      // Mengambil data HANYA milik user yang sedang login
      _items = await _db.getTransactionsByUser(_userId);
      print('✅ Loaded ${_items.length} transactions');
    } catch (e, st) {
      print('❌ Error loadAll: $e');
      print(st);
      _items = [];
    }

    _loading = false;
    notifyListeners();
  }

  // Fungsi untuk menambahkan transaksi baru ke database
  Future<void> addTransaction(TransactionModel t) async {
    try {
      await _db.insertTransaction(t); // Simpan ke SQLite
      await loadAll(); // Refresh list agar data baru muncul
    } catch (e) {
      print('❌ addTransaction error: $e');
      rethrow; // Lempar error ke UI (agar muncul SnackBar gagal)
    }
  }

  // Fungsi untuk mengupdate transaksi yang sudah ada
  Future<void> updateTransaction(TransactionModel t) async {
    try {
      await _db.updateTransaction(t);
      await loadAll();
    } catch (e) {
      print('❌ updateTransaction error: $e');
      rethrow;
    }
  }

  // Fungsi untuk menghapus transaksi berdasarkan ID
  Future<void> removeTransaction(int id) async {
    try {
      await _db.deleteTransaction(id);
      await loadAll();
    } catch (e) {
      print('❌ removeTransaction error: $e');
      rethrow;
    }
  }
}