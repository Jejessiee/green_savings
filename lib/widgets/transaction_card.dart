import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../screens/transaction_edit_screen.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  // Helper format currency
  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final iconData = _getIconForCategory(transaction);

    return Dismissible(
      key: Key(transaction.id.toString()),
      // Swipe ke kiri untuk hapus
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),

      // Konfirmasi Hapus
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Hapus Transaksi"),
            content: const Text("Apakah Anda yakin ingin menghapus transaksi ini?"),
            actions: [
              TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, true),
              )
            ],
          ),
        );
      },

      // Aksi Hapus
      onDismissed: (_) {
        provider.removeTransaction(transaction.id!); // Menggunakan removeTransaction sesuai provider jejessiee
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaksi dihapus")),
        );
      },

      child: GestureDetector(
        // Long Press untuk Edit
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTransactionScreen(transaction: transaction),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: iconData['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child:
                Icon(iconData['icon'], color: iconData['color'], size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.description,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(transaction.category,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (transaction.type == TransactionType.income ? '+ ' : '- ') +
                        formatCurrency(transaction.amount),
                    style: TextStyle(
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Jika ada konversi mata uang, tampilkan aslinya kecil di bawah
                  if (transaction.originalCurrency != 'IDR')
                    Text(
                      '${transaction.originalCurrency} ${transaction.originalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getIconForCategory(TransactionModel t) {
    IconData icon;
    Color color;

    if (t.type == TransactionType.income) {
      color = Colors.green;
      if (t.category.toLowerCase().contains('gaji')) icon = Icons.attach_money;
      else if (t.category.toLowerCase().contains('bonus')) icon = Icons.card_giftcard;
      else icon = Icons.account_balance_wallet;
    } else {
      color = Colors.redAccent;
      if (t.category.toLowerCase().contains('makan')) icon = Icons.fastfood;
      else if (t.category.toLowerCase().contains('transport')) icon = Icons.directions_car;
      else if (t.category.toLowerCase().contains('hiburan')) icon = Icons.movie;
      else if (t.category.toLowerCase().contains('belanja')) icon = Icons.shopping_bag;
      else icon = Icons.money_off;
    }
    return {'icon': icon, 'color': color};
  }
}