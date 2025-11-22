import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

// Daftar kategori pemasukan
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

  // Variabel State Currency
  String _selectedCurrency = 'IDR';
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'SGD'];


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

  // Menyimpan data transaksi ke dalam database
  void _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    // validasi data yang diinput
    if (amount == null || amount <= 0 || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah atau Deskripsi tidak valid.')),
      );
      return;
    }

    // Konversi Mata Uang
    double finalAmount = amount;

    // KONVERSI OTOMATIS KE IDR SEBELUM SIMPAN
    if (_selectedCurrency != 'IDR') {

      // Panggil service konversi
      finalAmount = await CurrencyService.convertToIDR(amount, _selectedCurrency);
    }

    // Membuat objek transaksi baru
    final newTransaction = TransactionModel(
      description: _descController.text,
      amount: amount,
      category: _selectedCategory,
      type: _type,
      date: _selectedDate,
    );

    // simpan data ke provider
    final provider = context.read<TransactionProvider>();
    await provider.addTransaction(newTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_type == TransactionType.income ? "Pemasukan" : "Pengeluaran"} berhasil disimpan!',
        ),
      ),
    );

    // Tutup halaman input data transaksi
    Navigator.of(context).pop();
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Dropdown Mata Uang
              DropdownButton<String>(
                value: _selectedCurrency,
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
                style: TextStyle(color: AppColors.darkText, fontSize: 16),
                underline: Container(height: 2, color: AppColors.primaryPink),
              ),
              const SizedBox(width: 10),
              // TextField Jumlah
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    prefixText: ' ', // Hilangkan 'Rp' karena sudah ada dropdown
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
            ],
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
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: _type == TransactionType.expense
                  ? AppColors.expenseRed
                  : AppColors.incomeGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
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
