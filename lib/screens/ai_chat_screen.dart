import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Agar format bold/list rapi
import '../app_colors.dart';
import '../providers/transaction_provider.dart';
import '../services/gemini_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  // Menyimpan riwayat chat (User & AI)
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'text': 'Halo! Saya Leafy 🌿. Ada yang bisa saya bantu terkait keuanganmu hari ini?'}
  ];

  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
    });
    _controller.clear();

    // Ambil data transaksi terbaru dari Provider
    final transactions = context.read<TransactionProvider>().items;

    // Minta jawaban dari Gemini
    final aiResponse = await _geminiService.getFinancialAdvice(transactions, userMessage);

    if (mounted) {
      setState(() {
        _messages.add({'role': 'ai', 'text': aiResponse});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tanya Leafy 🌿", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.accentGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          // List Pesan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primaryPink : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(15),
                      ),
                    ),
                    // Gunakan MarkdownBody agar teks bold (**teks**) dari AI terlihat rapi
                    child: isUser
                        ? Text(msg['text']!, style: const TextStyle(color: AppColors.darkText))
                        : MarkdownBody(data: msg['text']!),
                  ),
                );
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Leafy sedang berpikir...", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Tanya tentang pengeluaranmu...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: AppColors.darkGreen,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}