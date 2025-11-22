import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_colors.dart';
import 'models/transaction.dart';
import 'models/budget.dart';
import 'screens/home_screen.dart';
import 'screens/transaction_entry_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase

  runApp(
    //MultiProvider untuk state management
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const PiggyFlowApp(),
    ),
  );
}

// Widget utama aplikasi
class PiggyFlowApp extends StatelessWidget {
  const PiggyFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Savings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      // halaman awal login
      home: const InitialLoaderScreen(),
      routes: {
        '/main': (context) {
          // Mengambil data user yang dikirim lewat Navigator.pushNamed
          final userData =
          ModalRoute.of(context)!.settings.arguments as UserData;
          return MainScreen(userData: userData);
        },
      },
    );
  }
}

// Menampilkan homeScreen ketika sudah berhasil login
class MainScreen extends StatefulWidget {
  final UserData userData;

  const MainScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class InitialLoaderScreen extends StatelessWidget {
  const InitialLoaderScreen({super.key});

  // Fungsi untuk menjalankan semua tugas berat
  Future<void> _initializeApp(BuildContext context) async {
    // 1. Inisialisasi Firebase (WAJIB)
    // await Firebase.initializeApp();

    // 2. Muat data provider (Sekarang aman dilakukan karena tidak memblokir render pertama)
    await context.read<TransactionProvider>().loadAll();
    await context.read<BudgetProvider>().loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(context),
      builder: (context, snapshot) {
        // Jika masih loading (Waiting), tampilkan CircularProgressIndicator atau animasi logo
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Atau tampilkan logo di sini
            ),
          );
        }

        // Jika sudah selesai, pindah ke halaman Login
        return const LoginRegisterScreen();
      },
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; //index 1 : default untuk HomeScreen

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    //daftar halaman berdasarkan index
        _screens = [
      const Placeholder(), // Tombol tengah untuk input data transaksi
      HomeScreen(data: widget.userData),
      const AnalysisScreen(), // halaman grafik & analisis
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
      bottomNavigationBar: PiggyBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}