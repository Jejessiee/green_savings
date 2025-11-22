import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'package:greensavings/main.dart';
import 'login_screen.dart';

// model untuk menyimpan informasi dasar tentang user
class UserData {
  final String name;
  final String email;
  final String password;

  const UserData({
    required this.name,
    required this.email,
    required this.password,
  });
}

//Halaman Login & Register
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // variabel untuk menyimpan data user yang berhasil registrasi
  UserData? registeredUser;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true; // mengatur visibilitas password

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Fungsi untuk registrasi
  void _register() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    // Simpan data user ke variabel registeredUser
    setState(() {
      registeredUser = UserData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    });

    // Pesan Berhasil registrasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil! Silakan login')),
    );

    // langsung pindah ke tab login setelah registrasi
    _tabController.animateTo(0);
  }

  // Fungsi untuk Login
  void _login() {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    // Pesan yang muncul jika tidak ada user yang terdaftar
    if (registeredUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada akun terdaftar!')),
      );
      return;
    }

    // Cek kesesuaian email & password
    if (email == registeredUser!.email && password == registeredUser!.password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(userData: registeredUser!)),
      );
    } else {
      // Jika tidak cocok maka akan memunculkan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau password salah!'),
          backgroundColor: Colors.redAccent,
        ),
      );
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

                  // TAB LOGIN
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
                        height: 360,
                        padding: const EdgeInsets.all(20),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Column(
                              children: [
                                TextField(
                                  controller: _loginEmailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon:
                                    const Icon(Icons.email_outlined),
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

                            // TAB REGISTER
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
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon:
                                    const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon:
                                    const Icon(Icons.lock_outline),
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
                                ElevatedButton.icon(
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
                                    backgroundColor: Color(0xFF81C784),
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
