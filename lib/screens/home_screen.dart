import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart'; // Import AuthService untuk logout

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
                    ...transactions.map((t) => _buildTransactionTile(t)).toList(),
                  ],
                ),
              ),
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

  // Widget untuk setiap transaksi di daftar transaksi
  Widget _buildTransactionTile(TransactionModel t) {
    final Map<String, dynamic> iconData = _getIconForCategory(t);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: iconData['color'].withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData['icon'], color: iconData['color'], size: 24),
          ),
          const SizedBox(width: 15),

          // Deskripsi Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.description,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(t.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // Jumlah transaksi
          Text(
            (t.type == TransactionType.income ? '+ ' : '- ') +
                formatCurrency(t.amount),
            style: TextStyle(
              color:
              t.type == TransactionType.income ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Menampilkan ikon transaksi berdasarkan kategori
  Map<String, dynamic> _getIconForCategory(TransactionModel t) {
    IconData icon;
    Color color;

    // Jika transaksi berupa income
    if (t.type == TransactionType.income) {
      color = Colors.green;
      if (t.category.toLowerCase().contains('gaji')) {
        icon = Icons.attach_money;
      } else if (t.category.toLowerCase().contains('bonus')) {
        icon = Icons.card_giftcard;
      } else {
        icon = Icons.account_balance_wallet;
      }

      // Jika transaksi berupa expense
    } else {
      color = Colors.redAccent;
      if (t.category.toLowerCase().contains('makan')) {
        icon = Icons.fastfood;
      } else if (t.category.toLowerCase().contains('transport')) {
        icon = Icons.directions_car;
      } else if (t.category.toLowerCase().contains('hiburan')) {
        icon = Icons.movie;
      } else if (t.category.toLowerCase().contains('belanja')) {
        icon = Icons.shopping_bag;
      } else {
        icon = Icons.money_off;
      }
    }

    return {'icon': icon, 'color': color};
  }
}
