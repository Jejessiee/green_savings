import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/db_helper.dart';
import '../models/budget.dart';

// Provider untuk mengelola data anggaran (budget) dan komunikasi dengan database
class BudgetProvider with ChangeNotifier {
  final DbHelper dbHelper = DbHelper();
  List<Budget> _budgets = [];
  bool _loading = false;

  List<Budget> get budgets => _budgets;
  bool get loading => _loading;

  // Getter untuk mengambil User ID dari Firebase Auth
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Fungsi untuk mengambil semua data anggaran dari database
  Future<void> loadBudgets() async {
    // Keamanan: Jika user belum login, kosongkan data
    if (_userId.isEmpty) {
      _budgets = [];
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      // Panggil fungsi getBudgetsByUser dengan userId
      _budgets = await dbHelper.getBudgetsByUser(_userId);
    } catch (e) {
      print("❌ Error loadBudgets: $e");
      _budgets = [];
    }

    _loading = false;
    notifyListeners();
  }

  // Fungsi untuk menambahkan anggaran baru ke database
  Future<void> addBudget(Budget budget) async {
    try {
      await dbHelper.insertBudget(budget); // Simpan ke SQLite
      await loadBudgets(); // Refresh list agar data baru muncul
    } catch (e) {
      print("❌ Error addBudget: $e");
      rethrow; // Lempar error ke UI jika gagal
    }
  }

  // Fungsi untuk mengupdate anggaran yang sudah ada
  Future<void> updateBudget(Budget budget) async {
    try {
      await dbHelper.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      print("❌ Error updateBudget: $e");
      rethrow;
    }
  }

  // Fungsi untuk menghapus anggaran berdasarkan ID
  Future<void> deleteBudget(int id) async {
    try {
      await dbHelper.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      print("❌ Error deleteBudget: $e");
      rethrow;
    }
  }
}
