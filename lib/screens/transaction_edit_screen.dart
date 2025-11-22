import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../app_colors.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController descriptionController;
  late TextEditingController amountController;

  late DateTime selectedDate;
  late String selectedCategory;
  late TransactionType selectedType;

  // Sesuaikan kategori dengan yang ada di Entry Screen
  final List<String> categories = [
    'Makanan & Minuman', 'Transportasi', 'Belanja',
    'Hiburan', 'Tagihan', 'Lain-lain',
    'Gaji', 'Bonus', 'Investasi', 'Hadiah' // Gabungan expense & income
  ];

  @override
  void initState() {
    super.initState();
    descriptionController =
        TextEditingController(text: widget.transaction.description);
    amountController =
        TextEditingController(text: widget.transaction.amount.toStringAsFixed(0));

    selectedDate = widget.transaction.date;
    selectedCategory = widget.transaction.category;
    selectedType = widget.transaction.type;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime? result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  void saveTransaction() {
    final provider = context.read<TransactionProvider>();
    final double? amount = double.tryParse(amountController.text);

    if (descriptionController.text.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon isi data dengan benar"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Update data menggunakan copyWith
    final updated = widget.transaction.copyWith(
      description: descriptionController.text,
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
      type: selectedType,
      // Reset original currency info karena diedit manual dalam IDR
      originalCurrency: 'IDR',
      originalAmount: amount,
    );

    provider.updateTransaction(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Transaksi berhasil diperbarui!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaksi", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryPink,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah (IDR)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: categories.contains(selectedCategory) ? selectedCategory : categories.first,
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tipe Transaksi", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    const Text("Expense"),
                    Switch(
                      value: selectedType == TransactionType.income,
                      activeColor: AppColors.incomeGreen,
                      inactiveThumbColor: AppColors.expenseRed,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value ? TransactionType.income : TransactionType.expense;
                        });
                      },
                    ),
                    const Text("Income"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Tanggal: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
              trailing: const Icon(Icons.calendar_month),
              onTap: pickDate,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}