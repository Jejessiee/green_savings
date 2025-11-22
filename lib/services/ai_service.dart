import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction.dart';

class LeafyAIService {
  // Inisialisasi API Key
  static const _apiKey = 'YAIzaSyAEF5dbwd-3FjwuOp3WUcHHFzA8ojVeYhg';

  Future<String> getFinancialAdvice(List<TransactionModel> transactions) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);

    // 1. Ringkas data transaksi menjadi String sederhana agar hemat token
    String dataSummary = transactions.map((t) {
      return "${t.type.name}: ${t.amount} (${t.category})";
    }).join("\n");

    // 2. Buat Prompt untuk Leafy
    final prompt = '''
      Kamu adalah Leafy, maskot daun yang ramah dari aplikasi keuangan.
      Berikut adalah data transaksi pengguna bulan ini:
      $dataSummary
      
      Berikan saran keuangan singkat, ramah, dan memotivasi dalam bahasa Indonesia untuk pengguna ini.
      Panggil pengguna dengan sebutan "Sahabat Leafy".
    ''';

    // 3. Kirim ke Gemini
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response.text ?? "Leafy sedang istirahat, coba lagi nanti ya!";
  }
}