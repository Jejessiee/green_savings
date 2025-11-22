import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';

//Halaman Login & Register
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService(); // Instance AuthService

  // Controller TextFields
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _obscure = true; // Visibilitas password
  bool _isLoading = false; // Status loading

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk Registrasi ke Firebase
  void _register() async {
    if (_nameController.text.isEmpty ||
        _registerEmailController.text.isEmpty ||
        _registerPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil AuthService untuk daftar & simpan profil
      await _authService.register(
        _registerEmailController.text.trim(),
        _registerPasswordController.text.trim(),
        _nameController.text.trim(),
      );
      // Jika sukses, tidak perlu navigasi manual.
      // StreamBuilder di main.dart akan mendeteksi user login dan pindah ke Home.

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi Gagal: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk Login ke Firebase
  void _login() async {
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil AuthService untuk login
      await _authService.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text.trim(),
      );

      // Jika sukses, StreamBuilder di main.dart akan otomatis pindah ke Home.

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Gagal: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                Image.asset(
                  'images/leafy.png',
                  height: 150,
                ),
                const SizedBox(height: 15),

                const Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4E6C50),
                  ),
                ),
                const Text(
                  "GreenSaving 🌿",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  // TAB LOGIN & REGISTER
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TabBar(
                        controller: _tabController,
                        labelColor: Color(0xFF2E7D32),
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: Color(0xFF81C784),
                        tabs: const [
                          Tab(text: "Login"),
                          Tab(text: "Register"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 380,
                        padding: const EdgeInsets.all(20),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Halaman Login
                            Column(
                              children: [
                                TextField(
                                  controller: _loginEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _loginPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon:
                                    const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF81C784),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Halaman Register
                            Column(
                              children: [
                                TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: "Nama",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon:
                                    const Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _registerEmailController, // Gunakan controller khusus register
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _registerPasswordController, // Gunakan controller khusus register
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () => setState(
                                              () => _obscure = !_obscure),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton.icon(
                                  onPressed: _register,
                                  icon: const Icon(Icons.person_add_alt),
                                  label: const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF81C784),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
