import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/currency_service.dart';

// Daftar kategori pengeluaran
final List<String> expenseCategories = [
  'Makanan & Minuman',
  'Transportasi',
  'Belanja',
  'Hiburan',
  'Tagihan',
  'Lain-lain'
];

// daftar kategori pemasukan
final List<String> incomeCategories = [
  'Gaji',
  'Bonus',
  'Investasi',
  'Hadiah',
  'Lain-lain'
];

// Halaman input data transaksi
class TransactionEntryScreen extends StatefulWidget {
  final TransactionType initialType;

  const TransactionEntryScreen({Key? key, required this.initialType})
      : super(key: key);

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  late TransactionType _type;
  late String _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String _selectedCurrency = 'IDR';
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'SGD', 'JPY', 'MYR'];
  bool _isConverting = false; // Status loading saat ambil API

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    // Set kategori default berdasarkan tipe transaksi
    _selectedCategory = _type == TransactionType.income
        ? incomeCategories.first
        : expenseCategories.first;
  }

  // Getter untuk kategori yang sesuai dengan tipe transaksi
  List<String> get currentCategories =>
      _type == TransactionType.income ? incomeCategories : expenseCategories;

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() async {
    final amountInput = double.tryParse(_amountController.text);

    // 1. Validasi Input
    if (amountInput == null || amountInput <= 0 || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah atau Deskripsi tidak valid.')),
      );
      return;
    }

    // 2. Cek Login User (Wajib ada user untuk menyimpan data)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis. Silakan login kembali.')),
      );
      return;
    }

    setState(() => _isConverting = true); // Mulai Loading

    try {
      double finalAmountInIDR = amountInput;

      // 3. Konversi Mata Uang (Jika bukan IDR)
      if (_selectedCurrency != 'IDR') {
        try {
          double rate = await CurrencyService.getExchangeRate(_selectedCurrency);
          finalAmountInIDR = amountInput * rate;
        } catch (e) {
          // Jika gagal ambil kurs (misal offline), lempar error agar proses batal
          throw Exception("Gagal mengambil kurs mata uang. Periksa internet.");
        }
      }

      // 4. Buat Model Transaksi dengan UserID
      final newTransaction = TransactionModel(
        userId: user.uid, // ID User Firebase
        description: _descController.text,
        amount: finalAmountInIDR, // Simpan dalam Rupiah
        category: _selectedCategory,
        type: _type,
        date: _selectedDate,
        originalCurrency: _selectedCurrency,
        originalAmount: amountInput,
      );

      if (!mounted) return;

      // 5. Simpan ke Database via Provider
      // Karena di Provider sudah ada 'rethrow', jika ini gagal, kode akan lompat ke 'catch' di bawah
      await context.read<TransactionProvider>().addTransaction(newTransaction);

      // 6. Pesan Sukses
      String message = '${_type == TransactionType.income ? "Pemasukan" : "Pengeluaran"} berhasil disimpan!';
      if (_selectedCurrency != 'IDR') {
        message += ' (Dikonversi: Rp ${finalAmountInIDR.toStringAsFixed(0)})';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      // Tutup halaman
      Navigator.of(context).pop();

    } catch (e) {
      // 7. Tangkap Error (Gagal Simpan / Gagal Koneksi)
      // Pesan error akan muncul di sini, dan halaman TIDAK tertutup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi Kesalahan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // Stop Loading
      if (mounted) setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _type == TransactionType.expense
                    ? 'Catat Pengeluaran'
                    : 'Catat Pemasukan',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Icon(
                _type == TransactionType.income
                    ? Icons.arrow_circle_up
                    : Icons.arrow_circle_down,
                color: _type == TransactionType.income
                    ? AppColors.incomeGreen
                    : AppColors.expenseRed,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Input jumlah transaksi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    // Prefix text disesuaikan agar tidak double dengan dropdown
                    prefixText: _selectedCurrency == 'IDR' ? 'Rp ' : '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Dropdown Currency
              Expanded(
                flex: 1,
                child: Container(
                  height: 60, // Samakan tinggi dengan TextField default
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCurrency,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        items: _currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Info kecil jika mata uang asing dipilih
          if (_selectedCurrency != 'IDR')
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5),
              child: Text(
                '*Otomatis dikonversi ke IDR saat disimpan',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),

          const SizedBox(height: 15),

          // Input deskripsi transaksi
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Deskripsi / Catatan',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 15),

          // Pilihan kategori transaksi
          Wrap(
            spacing: 8.0,
            children: currentCategories.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.accentGreen,
                backgroundColor:
                AppColors.primaryPink.withOpacity(0.5),
                labelStyle: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 15),

          // Pilihan tanggal transaksi
          ListTile(
            title: Text(
                'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing:
            const Icon(Icons.calendar_today, color: AppColors.darkText),
            onTap: () => _selectDate(context),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            tileColor: AppColors.primaryPink.withOpacity(0.3),
          ),
          const SizedBox(height: 20),

          // Tombol simpan data
          ElevatedButton(
            // Disable tombol saat sedang converting/loading
            onPressed: _isConverting ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: _type == TransactionType.expense
                  ? AppColors.expenseRed
                  : AppColors.incomeGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: _isConverting
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : const Text(
              'Simpan Transaksi',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
