import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

// Halaman Analisis & anggaran
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Memuat data transaksi dan anggaran saat layar pertama kali ditampilkan
      print('▶️ AnalysisScreen init: calling providers load');
      context.read<TransactionProvider>().loadAll();
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  // Fungsi untuk format angka menjadi format mata uang Rupiah
  String formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    return 'Rp' +
        s.replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  // Hitung total pengeluaran per kategori
  Map<String, double> _getExpensesByCategory(List<TransactionModel> items) {
    final Map<String, double> map = {};
    for (var t in items) {
      if (t.type == TransactionType.expense) {
        final cat = t.category;
        map[cat] = (map[cat] ?? 0) + t.amount;
      }
    }
    return map;
  }

  // Hitung Pemasukan & pengeluaran bulanan (4 bulan terakhir)
  List<Map<String, double>> _getMonthlyFlow(List<TransactionModel> items) {
    final Map<String, Map<String, double>> grouped = {};
    for (var t in items) {
      final d = t.date;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});
      if (t.type == TransactionType.income) {
        grouped[key]!['income'] = grouped[key]!['income']! + t.amount;
      } else {
        grouped[key]!['expense'] = grouped[key]!['expense']! + t.amount;
      }
    }

    // Mengambil max 4 bulan terakhir untuk ditampilkan
    final sortedKeys = grouped.keys.toList()..sort();
    final keysToUse = sortedKeys.length > 4
        ? sortedKeys.sublist(sortedKeys.length - 4)
        : sortedKeys;
    final result = <Map<String, double>>[];
    for (var k in keysToUse) {
      result.add({
        'income': grouped[k]!['income'] ?? 0.0,
        'expense': grouped[k]!['expense'] ?? 0.0,
      });
    }
    return result;
  }

  // Mengatur anggaran bulanan per kategori
  void _showEditBudgetDialog(
      BuildContext context,
      BudgetProvider budgetProvider,
      TransactionProvider transactionProvider,
      ) {
    // Menampilkan kategori transaksi & kategori yang sudah ada di anggaran
    final transactionCategories = transactionProvider.items
        .where((t) => t.type == TransactionType.expense)
        .map((t) => t.category)
        .toSet();

    final budgetCategories =
    budgetProvider.budgets.map((b) => b.category).toSet();
    final allCategories = {...transactionCategories, ...budgetCategories}.toList();

    // Default kategori & controller input nilai anggaran
    String selectedCategory =
    allCategories.isNotEmpty ? allCategories.first : '';
    final controller = TextEditingController();

    // input anggaran
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Atur Anggaran Bulanan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allCategories.isNotEmpty)
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                    items: allCategories
                        .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                  ),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Batas Anggaran (Rp)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal')),
              ElevatedButton(
                onPressed: () async {
                  final text = controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '');
                  final value = double.tryParse(text);

                  // Ambil User ID
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return; // Safety Check

                  if (value != null && selectedCategory.isNotEmpty) {
                    // Simpan anggaran berdasarkan bulan saat ini
                    final now = DateTime.now();
                    final currentMonth =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}';

                    // Cek apakah sudah ada anggaran kategori tersebut di bulan ini
                    final existing = budgetProvider.budgets.firstWhere(
                          (b) =>
                      b.category == selectedCategory &&
                          b.month == currentMonth,
                      orElse: () => Budget(
                        id: null,
                        userId: user.uid,
                        category: selectedCategory,
                        limitAmount: value,
                        month: currentMonth,
                      ),
                    );

                    // Jika belum ada data, add new
                    if (existing.id == null) {
                      await budgetProvider.addBudget(
                        Budget(
                          userId: user.uid,
                          category: selectedCategory,
                          limitAmount: value,
                          month: currentMonth,
                        ),
                      );
                    } else {
                      // Jika sudah ada data, update data
                      final updated = Budget(
                        id: existing.id,
                        userId: user.uid,
                        category: selectedCategory,
                        limitAmount: value,
                        month: currentMonth,
                      );
                      await budgetProvider.updateBudget(updated);
                    }

                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  // Fungsi Dialog Konfirmasi Hapus
  void _confirmDeleteBudget(BuildContext context, BudgetProvider provider, int budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggaran?'),
        content: const Text('Anggaran ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteBudget(budgetId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anggaran berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi Dialog Edit Anggaran (Khusus Limit)
  void _showUpdateBudgetDialog(BuildContext context, BudgetProvider provider, Budget budget) {
    final controller = TextEditingController(text: budget.limitAmount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Anggaran: ${budget.category}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Batas Baru (Rp)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text.replaceAll('.', '').replaceAll(',', ''));
              if (value != null) {
                // Buat objek budget baru dengan nilai yang diupdate
                final updatedBudget = Budget(
                  id: budget.id,
                  userId: budget.userId,
                  category: budget.category,
                  month: budget.month,
                  limitAmount: value,
                );

                await provider.updateBudget(updatedBudget);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anggaran berhasil diperbarui')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // UI Utama halaman analisis & anggaran
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    // Menampilkan loading jika data belum siap
    if (transactionProvider.loading || budgetProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ambil data transaksi & anggaran
    final transactions = transactionProvider.items;
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final budgets = budgetProvider.budgets
        .where((b) => b.month == currentMonth)
        .toList();

    final expensesByCategory = _getExpensesByCategory(transactions);
    final monthlyFlow = _getMonthlyFlow(transactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analisis & Anggaran',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),

          // Header Anggaran Bulan Ini
          Text(
            'Anggaran Bulan Ini (${currentMonth})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),

          // Jika belum ada anggaran
          if (budgets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada anggaran untuk bulan ini. Tekan tombol "Kelola Anggaran" untuk menambahkan.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            )
          else
            // Tampilkan setiap anggaran dalam bentuk kartu
            ...budgets.map((b) {
              final spent = expensesByCategory[b.category] ?? 0.0;
              final percentage =
              b.limitAmount > 0 ? (spent / b.limitAmount) : 0.0;

              // Warna Progress Bar
              Color barColor;
              if (percentage < 0.5) {
                barColor = AppColors.incomeGreen;
              } else if (percentage < 0.85) {
                barColor = Colors.orange;
              } else {
                barColor = AppColors.expenseRed;
              }

              // Tampilkan kartu untuk setiap anggaran
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector( // Tambahkan GestureDetector
                  onTap: () => _showUpdateBudgetDialog(context, budgetProvider, b), // Ketuk untuk Edit
                  onLongPress: () => _confirmDeleteBudget(context, budgetProvider, b.id!), // Tahan untuk Hapus
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Menambahkan Icon petunjuk kecil di pojok kanan atas (opsional)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                b.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.edit, size: 16, color: Colors.grey), // Indikator bisa diedit
                            ],
                          ),

                          const SizedBox(height: 8),
                          // Progress Bar anggaran
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: percentage.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(barColor),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terpakai: ${formatCurrency(spent)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Batas: ${formatCurrency(b.limitAmount)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _showEditBudgetDialog(
                    context, budgetProvider, transactionProvider);
              },
              child: const Text('Kelola Anggaran'),
            ),
          ),

          const SizedBox(height: 30),

          // Grafik Aliran dana bulanan
          _buildMonthlyFlowChart(monthlyFlow),
          const SizedBox(height: 30),

          // Grafik proporsi pengeluaran
          _buildCategoryExpenseChart(expensesByCategory),
        ],
      ),
    );
  }

  // Bar chart untuk pemasukan & pengeluaran bulanan
  Widget _buildMonthlyFlowChart(List<Map<String, double>> monthlyFlow) {
    if (monthlyFlow.isEmpty) return const Text('Belum ada data aliran dana');

    double maxY = 0;
    for (var m in monthlyFlow) {
      maxY = [maxY, m['income'] ?? 0.0, m['expense'] ?? 0.0]
          .reduce((a, b) => a > b ? a : b);
    }
    maxY *= 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aliran Dana Bulanan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20)),
          child: BarChart(
            BarChartData(
              maxY: maxY <= 0 ? 1.0 : maxY,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      final now = DateTime.now();
                      final currentMonth = now.month;
                      final monthLabels = List.generate(monthlyFlow.length, (i) {
                        final date = DateTime(now.year, currentMonth - (monthlyFlow.length - 1 - i));
                        const monthNames = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                        ];
                        return monthNames[(date.month - 1) % 12];
                      });

                      if (idx < 0 || idx >= monthLabels.length) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          monthLabels[idx],
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: maxY / 5,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final label =
                          'Rp${(value / 1000000).toStringAsFixed(1)}J';
                      return SideTitleWidget(
                        meta: meta,
                        child:
                        Text(label, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: monthlyFlow.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                        toY: m['income'] ?? 0.0,
                        color: AppColors.incomeGreen,
                        width: 14,
                        borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(
                        toY: m['expense'] ?? 0.0,
                        color: AppColors.expenseRed,
                        width: 14,
                        borderRadius: BorderRadius.circular(4)),
                  ],
                  barsSpace: 4,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Sunburst chart untuk pengeluaran per kategori
  Widget _buildCategoryExpenseChart(Map<String, double> expensesByCat) {
    final total = expensesByCat.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const Text('Belum ada data pengeluaran');

    final colors = [
      Colors.red.shade300,
      Colors.blue.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.green.shade300
    ];
    final entries = expensesByCat.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Proporsi Pengeluaran per Kategori',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 280,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sections: entries.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final cat = entry.value.key;
                      final val = entry.value.value;
                      final perc = val / total * 100;
                      return PieChartSectionData(
                        color: colors[idx % colors.length],
                        value: val,
                        title: '${perc.toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cat = entry.value.key;
                    return Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          color: colors[idx % colors.length],
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Text(cat, style: const TextStyle(fontSize: 10)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
