import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Future<double> convertToIDR(double amount, String fromCurrency) async {
    // Jika mata uang sudah IDR, tidak perlu konversi
    if (fromCurrency == 'IDR') return amount;

    // Panggil API Frankfurter
    final url = Uri.parse('https://api.frankfurter.app/latest?from=$fromCurrency&to=IDR');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Ambil nilai rate dari JSON
        final rate = data['rates']['IDR'];
        return amount * rate;
      }
    } catch (e) {
      print("Gagal mengambil kurs: $e");
    }

    // Jika gagal (offline/error), kembalikan nilai asli sebagai fallback
    return amount;
  }
}