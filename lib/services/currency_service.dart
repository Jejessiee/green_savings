import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Base URL Frankfurter
  static const String _baseUrl = 'https://api.frankfurter.app/latest';

  // Fungsi untuk mendapatkan nilai tukar dari mata uang asing ke IDR
  static Future<double> getExchangeRate(String fromCurrency) async {
    if (fromCurrency == 'IDR') return 1.0; // Tidak perlu konversi

    try {
      // Request ke API: https://api.frankfurter.app/latest?from=USD&to=IDR
      final url = Uri.parse('$_baseUrl?from=$fromCurrency&to=IDR');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mengambil nilai rate, misal: data['rates']['IDR']
        return (data['rates']['IDR'] as num).toDouble();
      } else {
        throw Exception('Gagal mengambil kurs');
      }
    } catch (e) {
      print('Error converting currency: $e');
      // Jika gagal (misal offline), kembalikan 0 atau throw error agar user tahu
      throw Exception('Koneksi internet diperlukan untuk konversi mata uang');
    }
  }
}