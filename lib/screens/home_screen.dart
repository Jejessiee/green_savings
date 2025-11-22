import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart'; // Import AuthService untuk logout
import '../widgets/transaction_card.dart';

// Halaman utama aplikasi
class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel lokal untuk user agar bisa di-refresh
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _refreshUserData(); // Refresh data saat halaman dimuat
  }

  // Fungsi untuk memaksa refresh data user (agar nama muncul)
  Future<void> _refreshUserData() async {
    await _currentUser.reload(); // Ambil data terbaru dari Firebase
    if (mounted) {
      setState(() {
        // Update variabel _currentUser dengan data terbaru
        _currentUser = FirebaseAuth.instance.currentUser!;
      });
    }
  }

  // Format angka menjadi format mata uang Rupiah
  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil instance TransactionProvider untuk mendapatkan data transaksi
    final provider = context.watch<TransactionProvider>();

    // Jika data masih dimuat, tampilkan loading
    if (provider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final transactions = provider.items;

    // Hitung total pemasukan, pengeluaran, dan saldo
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else if (t.type == TransactionType.expense) {
        totalExpense += t.amount;
      }
    }

    double totalBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Saldo Utama
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: _buildSavingsCard(
                  totalBalance: totalBalance,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                ),
              ),

              // Daftar Transaksi Terbaru
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    // List transaksi
                    const SizedBox(height: 10),

                    // Menggunakan Widget TransactionCard untuk setiap item
                    if (transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text("Belum ada transaksi")),
                      )
                    else
                      ...transactions.map((t) => TransactionCard(transaction: t)).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space untuk BottomNav
            ],
          ),
        ),
      ),
    );
  }

  // Menampilkan profile, Welcome, dan tombol logout
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        color: AppColors.babypink,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('images/profile.png', height: 70),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Tampilkan nama dari Firebase User
                  Text(
                    '${_currentUser.displayName ?? "User"}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tombol Logout
          GestureDetector(
            onTap: () async {
              // Panggil logout dari AuthService
              // StreamBuilder di main.dart akan otomatis mendeteksi logout dan pindah ke LoginScreen
              await AuthService().logout();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.grey, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  // Menampilkan total saldo, income, dan expenses)
  Widget _buildSavingsCard({
    required double totalBalance,
    required double totalIncome,
    required double totalExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryPink, AppColors.peach],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [

          // Saldo Total
          const Text('Total Balance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(formatCurrency(totalBalance),
              style:
              const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Kolom income & Expenses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountRow('Income', totalIncome, Colors.green, Icons.arrow_downward),
              _buildAmountRow('Expenses', totalExpense, Colors.redAccent, Icons.arrow_upward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              formatCurrency(amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
