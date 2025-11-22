import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

// Helper class untuk mengelola database SQLite
class DbHelper {
  // Singleton pattern: hanya satu instance DbHelper yang digunakan
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _db;// Database instance

  // Getter untuk mengakses database, akan inisialisasi jika belum tersedia
  Future<Database> get database async {
    if (_db != null) return _db!;
    try {
      _db = await _initDatabase();
      return _db!;
    } catch (e, st) {
      print('❌ [DbHelper] error opening DB: $e');
      print(st);
      rethrow;
    }
  }

  // Fungsi untuk inisialisasi database dan menentukan path penyimpanan
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'greensavings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Fungsi untuk membuat tabel saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    //table transactions
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        amount REAL,
        category TEXT,
        type INTEGER,
        date TEXT,
        originalCurrency TEXT, 
        originalAmount REAL
      )
    ''');

    //table budgets
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        limitAmount REAL NOT NULL,
        month TEXT NOT NULL
      )
    ''');

  }

  // ==================== CRUD Transactions ====================
  // Simpan transaksi baru ke database
  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return await db.insert('transactions', t.toMap());
  }

  // Update data transaksi berdasarkan ID
  Future<int> updateTransaction(TransactionModel t) async {
    final db = await database;
    return await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  // Hapus transaksi berdasarkan ID
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ambil semua data transaksi dari database
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // ==================== CRUD Budgets ====================

  // Simpan anggaran baru ke database
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace jika duplikat
    );
  }

  // Ambil semua data anggaran dari database
  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets');
    return maps.map((e) => Budget.fromMap(e)).toList();
  }

  // Update data anggaran berdasarkan ID
  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Hapus anggaran berdasarkan ID
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}