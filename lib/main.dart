import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_colors.dart';
import 'models/transaction.dart'; // Diperlukan untuk Enum TransactionType
import 'screens/home_screen.dart';
import 'screens/transaction_entry_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Init Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const LeafyFlowApp(),
    ),
  );
}

// Widget utama aplikasi
class LeafyFlowApp extends StatelessWidget {
  const LeafyFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // fallback color jika AppColors.background ternyata gelap/hitam saat debugging
    final Color bg = AppColors.background;

    return MaterialApp(
      title: 'Green Savings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      // Menggunakan StreamBuilder untuk cek status login otomatis
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Tampilkan loading saat cek status auth
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // 2. Jika User sudah login (ada data User)
          if (snapshot.hasData) {
            return MainScreen(user: snapshot.data!);
          }

          // 3. Jika User belum login
          return const LoginRegisterScreen();
        },
      ),
      // Routes '/main' dihapus karena navigasi sudah ditangani StreamBuilder
    );
  }
}

// Menampilkan homeScreen ketika sudah berhasil login
class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; //index 1 : default untuk HomeScreen

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Load data dari SQLite saat MainScreen dibuat
    // Menggunakan Future.microtask agar tidak error saat build belum selesai
    Future.microtask(() {
      context.read<TransactionProvider>().loadAll();
      context.read<BudgetProvider>().loadBudgets();
    });

    //daftar halaman berdasarkan index
    _screens = [
      const Placeholder(), // Index 0: Tombol Add
      HomeScreen(user: widget.user), // Index 1: Home
      const AnalysisScreen(), // Index 2: Analysis
      const AIChatScreen(),   // Index 3: Halaman Chat AI
    ];
  }

  // Menampilkan pilihan jenis transaksi yang akan dilakukan (pemasukan/pengeluaran)
  void _showTransactionChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Catat Apa?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 20),
              // mencatat pemasukan
              ListTile(
                leading: const Icon(Icons.arrow_circle_up,
                    color: AppColors.incomeGreen, size: 30),
                title: const Text(
                  'Pemasukan (Revenue)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                tileColor: AppColors.incomeGreen.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransactionEntry(context, TransactionType.income);
                },
              ),
              const SizedBox(height: 10),
              // mencatatan pengeluaran
              ListTile(
                leading: const Icon(Icons.arrow_circle_down,
                    color: AppColors.expenseRed, size: 30),
                title: const Text(
                  'Pengeluaran (Expense)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                tileColor: AppColors.expenseRed.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransactionEntry(context, TransactionType.expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // form input data transaksi
  void _showTransactionEntry(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => TransactionEntryScreen(initialType: type),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _showTransactionChoice(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex], // menampilkan halaman sesuai index yang dipilih
      ),
      // Tombol Floating AI di pojok kanan bawah
      // Hanya muncul jika bukan sedang di halaman AI itu sendiri
      floatingActionButton: _selectedIndex == 3 ? null : FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 3; // Pindah ke halaman AI Chat
          });
        },
        backgroundColor: AppColors.darkGreen,
        child: const Icon(Icons.psychology, color: Colors.white),
        tooltip: 'Tanya Leafy',
      ),

      // Navigasi Bawah Custom
      bottomNavigationBar: LeafyBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}