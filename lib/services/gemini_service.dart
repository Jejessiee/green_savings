import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyCqX1BqpFZEgiv_VQ8xKriBJSEqsjMuCiA';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getFinancialAdvice(
      List<TransactionModel> transactions, String userQuestion) async {
    try {
      // 1. Format data transaksi
      String transactionHistory = transactions.isEmpty
          ? "Belum ada data transaksi."
          : transactions.map((t) {
        return "- ${t.date.day}/${t.date.month}/${t.date.year}: ${t.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'} sebesar Rp${t.amount} untuk ${t.category} (${t.description})";
      }).join("\n");

      // 2. Prompt
      final prompt = '''
Kamu adalah asisten keuangan pribadi yang bijak, ramah, dan hemat bernama "Leafy".
Tugasmu adalah membantu pengguna menganalisis keuangan mereka berdasarkan data berikut:

Riwayat Transaksi Pengguna:
$transactionHistory

Pertanyaan Pengguna: "$userQuestion"

Jawablah pertanyaan pengguna berdasarkan data di atas. Berikan saran yang spesifik, praktis, dan memotivasi. Gunakan Bahasa Indonesia yang santai.
''';

      // 3. Kirim ke Gemini
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? "Maaf, Leafy sedang bingung. Coba lagi ya!";
    } catch (e) {
      return "Terjadi kesalahan koneksi ke AI: $e";
    }
  }
}