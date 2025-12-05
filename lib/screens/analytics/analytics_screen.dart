import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/finance_provider.dart';
import '../../models/transaction.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // State
  DateTime _selectedMonth = DateTime.now();
  int _touchedIndex = -1;
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    // 1. Filter Data for Selected Month
    final monthTx = _getTransactionsForMonth(provider.transactions, _selectedMonth);

    // 2. Calculate Stats
    final income = monthTx.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final investments = monthTx.where((t) => t.type == TransactionType.investment).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = monthTx.where((t) => t.type == TransactionType.expense).toList();
    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);

    // Savings Logic
    final savings = income - (totalExpense + investments);

    // 3. Group for Chart
    final groupedExpenses = _groupExpensesByCategory(expenses);
    final topCategory = groupedExpenses.isNotEmpty ? groupedExpenses.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // --- HEADER (Matches Home Screen) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'clear finance',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        _buildMonthSelector(), // New Narrow Dropdown
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- FINANCIAL HEALTH CARD (Orange) ---
                    _buildHealthCard(provider, income, investments, totalExpense, savings),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            if (expenses.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text("No spending data for this month", style: TextStyle(color: Colors.grey[600])),
                ),
              )
            else ...[
              // --- SPENDING CHART SECTION ---
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CHART HEADER: "Where did it go?"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Where did it go?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          // Dynamic Insight Badge (Top Category)
                          if (topCategory != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: topCategory.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: topCategory.color.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, color: topCategory.color, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Top: ${topCategory.categoryName}",
                                    style: TextStyle(
                                      color: topCategory.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // THE CHART
                    SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions || response?.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = response!.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: _buildPieSections(groupedExpenses, totalExpense),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _touchedIndex == -1 ? "Total" : groupedExpenses[_touchedIndex].categoryName,
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                Text(
                                  provider.currencyFormat.format(
                                      _touchedIndex == -1 ? totalExpense : groupedExpenses[_touchedIndex].amount
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // LIST HEADER: "Here it is!"
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Here it is!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // --- EXPANDABLE LIST ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final category = groupedExpenses[index];
                      final isExpanded = _expandedCategory == category.categoryName;
                      final percentage = (category.amount / totalExpense * 100);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: isExpanded ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)) : null,
                        ),
                        child: Column(
                          children: [
                            // Category Header
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedCategory = isExpanded ? null : category.categoryName;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: category.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(category.icon, style: const TextStyle(fontSize: 18)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(category.categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                              Text(provider.currencyFormat.format(category.amount), style: const TextStyle(color: Colors.white70)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor: Colors.black12,
                                              color: category.color,
                                              minHeight: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text("${percentage.toStringAsFixed(1)}%", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),

                            // Expanded Transactions
                            if (isExpanded)
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                                ),
                                child: Column(
                                  children: category.transactions.map((tx) => ListTile(
                                    dense: true,
                                    title: Text(tx.note ?? "Expense", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    subtitle: Text("${tx.date.day}/${tx.date.month}", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                                    trailing: Text(
                                      provider.currencyFormat.format(tx.amount),
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: groupedExpenses.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ]
          ],
        ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildMonthSelector() {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final monthShort = months[_selectedMonth.month - 1];
    final yearShort = _selectedMonth.year.toString().substring(2); // '25

    final now = DateTime.now();
    final availableMonths = List.generate(12, (index) {
      return DateTime(now.year, now.month - index, 1);
    });

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          textStyle: const TextStyle(color: Colors.white),
        ),
      ),
      child: PopupMenuButton<DateTime>(
        offset: const Offset(0, 40),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E293B),
        constraints: const BoxConstraints(
          minWidth: 140,
          maxWidth: 160,
        ),
        onSelected: (date) {
          setState(() {
            _selectedMonth = date;
          });
        },
        itemBuilder: (context) {
          return availableMonths.map((date) {
            final mLabel = "${months[date.month - 1]} ${date.year}";
            final isSelected = date.year == _selectedMonth.year && date.month == _selectedMonth.month;

            return PopupMenuItem<DateTime>(
              value: date,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mLabel,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_rounded, color: Color(0xFF3B82F6), size: 16),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 8),
              Text(
                "$monthShort '$yearShort",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white60, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(FinanceProvider provider, double income, double invested, double spent, double savings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          // Income
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Income", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(provider.currencyFormat.format(income), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 24),
          // Invested & Spent
          Row(
            children: [
              Expanded(child: _buildStatBox("Invested", invested, Icons.trending_up_rounded, provider)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox("Spent", spent, Icons.trending_down_rounded, provider)),
            ],
          ),
          const SizedBox(height: 20),
          // Savings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.savings_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text("Net Savings", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
              Text(provider.currencyFormat.format(savings), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, double amount, IconData icon, FinanceProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(provider.currencyFormat.format(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // --- HELPERS ---

  List<PieChartSectionData> _buildPieSections(List<_CategoryGroup> data, double total) {
    return List.generate(data.length, (i) {
      final isTouched = i == _touchedIndex;
      final item = data[i];
      final radius = isTouched ? 55.0 : 45.0;
      return PieChartSectionData(
        color: item.color,
        value: item.amount,
        title: "",
        radius: radius,
        badgeWidget: isTouched ? _Badge(item.icon, size: 36, color: item.color) : null,
        badgePositionPercentageOffset: .98,
      );
    });
  }

  List<Transaction> _getTransactionsForMonth(List<Transaction> all, DateTime month) {
    return all.where((tx) => tx.date.year == month.year && tx.date.month == month.month).toList();
  }

  List<_CategoryGroup> _groupExpensesByCategory(List<Transaction> expenses) {
    final Map<String, _CategoryGroup> map = {};
    final palette = [
      const Color(0xFFF43F5E), const Color(0xFF8B5CF6), const Color(0xFF10B981),
      const Color(0xFFF59E0B), const Color(0xFF3B82F6), const Color(0xFFEC4899),
      const Color(0xFF6366F1), const Color(0xFF14B8A6),
    ];
    int colorIndex = 0;

    for (var tx in expenses) {
      if (map.containsKey(tx.categoryName)) {
        map[tx.categoryName]!.amount += tx.amount;
        map[tx.categoryName]!.transactions.add(tx);
      } else {
        map[tx.categoryName] = _CategoryGroup(
          categoryName: tx.categoryName, icon: tx.categoryIcon, amount: tx.amount,
          color: palette[colorIndex % palette.length], transactions: [tx],
        );
        colorIndex++;
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}

class _CategoryGroup {
  final String categoryName;
  final String icon;
  double amount;
  final Color color;
  final List<Transaction> transactions;
  _CategoryGroup({required this.categoryName, required this.icon, required this.amount, required this.color, required this.transactions});
}

class _Badge extends StatelessWidget {
  final String icon;
  final double size;
  final Color color;
  const _Badge(this.icon, {required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
      alignment: Alignment.center,
      child: Text(icon, style: const TextStyle(fontSize: 18)),
    );
  }
}
