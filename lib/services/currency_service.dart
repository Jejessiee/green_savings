import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Menggunakan API Frankfurter (Gratis)
  static Future<double> convertToIDR(double amount, String fromCurrency) async {
    if (fromCurrency == 'IDR') return amount;

    final url = Uri.parse('https://api.frankfurter.app/latest?from=$fromCurrency&to=IDR');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates']['IDR'];
        return amount * rate;
      }
    } catch (e) {
      print("Error fetching rates: $e");
    }
    return amount; // Fallback jika gagal
  }
}