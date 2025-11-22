import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan User ID saat ini
  String? get currentUserId => _auth.currentUser?.uid;

  // Register
  Future<User?> register(String email, String password, String name) async {
    try {
      // 1. Buat Akun Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan Profil ke Firestore (Cloud)
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'joinDate': DateTime.now().toIso8601String(),
        });

        // Update display name di Auth juga
        await cred.user!.updateDisplayName(name);

        // Paksa user local untuk refresh data agar nama yang baru diupdate terbaca
        await cred.user!.reload();
      }
      return cred.user;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}