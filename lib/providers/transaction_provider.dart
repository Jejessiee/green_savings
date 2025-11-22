import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Deklarasi Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter untuk User ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Constructor: langsung load semua data saat provider dibuat
  TransactionProvider();

  // Fungsi untuk mengambil semua data transaksi dari database
    Future<void> loadAll() async {
    // Cek apakah user sudah login dan ada koneksi (sederhana)
      try {
        _loading = true;
        notifyListeners();

        // Cek apakah user sudah login
        if (currentUserId != null) {
          // 1. MUAT DARI FIRESTORE
          final snapshot = await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('transactions')
              .get();

          // 2. KONVERSI & UPDATE SQLite Lokal
          List<TransactionModel> cloudTransactions = snapshot.docs.map((doc) {
            // Ambil data dan tambahkan Firestore ID untuk referensi
            Map<String, dynamic> data = doc.data();
            // Asumsi: TransactionModel.fromMap sekarang sudah bisa menangani data Firestore
            return TransactionModel.fromMap(data);
          }).toList();

          // **Catatan:** Metode deleteAllTransactions() harus ditambahkan di DbHelper.
          // await _db.deleteAllTransactions();

          // Memuat dan menimpa data di SQLite (untuk offline-first)
          for (var t in cloudTransactions) {
            await _db.insertTransaction(t);
          }

          _items = cloudTransactions; // Gunakan data dari cloud

        } else {
          // Jika tidak ada user login, muat dari SQLite (Data Anonim/Lokal)
          _items = await _db.getAllTransactions();
        }

      } catch (e) {
        print('Error during synchronization: $e');
        // Fallback: Jika terjadi error di cloud (misalnya, izin), muat dari SQLite
        _items = await _db.getAllTransactions();
      } finally {
        _loading = false;
        notifyListeners();
      }
    }

  // Fungsi untuk menambahkan transaksi baru ke database
  Future<void> addTransaction(TransactionModel transaction) async {
    if (currentUserId == null) {
      // Jika user belum login, simpan hanya ke lokal (SQLite)
      await _db.insertTransaction(transaction);
      await loadAll();
      return;
    }

    try {
      // 1. SIMPAN KE FIRESTORE (CLOUD)
      // Pastikan TransactionModel punya metode toMap() yang cocok
      await _firestore
          .collection('users')
          .doc(currentUserId) // Simpan data di bawah ID pengguna
          .collection('transactions')
          .add(transaction.toMap());

      // 2. SIMPAN KE SQLite (LOKAL) - Tetap dilakukan agar cepat diakses offline
      await _db.insertTransaction(transaction);

    } catch (e) {
      print('Error saving transaction to cloud: $e');
      // Jika gagal ke cloud, tetap simpan lokal sebagai fallback
      await _db.insertTransaction(transaction);
    } finally {
      // 3. REFRESH DATA
      await loadAll();
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
