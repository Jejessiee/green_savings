import 'package:flutter/foundation.dart';
import '../data/db_helper.dart';
import '../models/budget.dart';

// Provider untuk mengelola data anggaran (budget) dan komunikasi dengan database
class BudgetProvider with ChangeNotifier {
  final DbHelper dbHelper = DbHelper();
  List<Budget> _budgets = [];
  bool _loading = true;

  List<Budget> get budgets => _budgets;
  bool get loading => _loading;

  BudgetProvider() {
    loadBudgets();
  }

  // Fungsi untuk mengambil semua data anggaran dari database
  Future<void> loadBudgets() async {
    _loading = true;
    notifyListeners();
    _budgets = await dbHelper.getBudgets();
    _loading = false;
    notifyListeners();
  }

// Fungsi untuk menambahkan anggaran baru ke database
  Future<void> addBudget(Budget budget) async {
    await dbHelper.insertBudget(budget); // Simpan ke SQLite
    await loadBudgets(); // Refresh data setelah insert
  }

  // Fungsi untuk mengupdate anggaran yang sudah ada
  Future<void> updateBudget(Budget budget) async {
    await dbHelper.updateBudget(budget); // Update data di SQLite
    await loadBudgets(); // Refresh data setelah update
  }

  // Fungsi untuk menghapus anggaran berdasarkan ID
  Future<void> deleteBudget(int id) async {
    await dbHelper.deleteBudget(id); // Hapus dari SQLite
    await loadBudgets(); // Refresh data setelah delete
  }
}
