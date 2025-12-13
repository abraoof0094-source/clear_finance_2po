import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart' as model;
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart'; // <--- IMPORT THIS
import '../../utils/currency_format.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  int _selectedMonthIndex = DateTime.now().month;

  int _touchedIndex = -1;
  String? _expandedCategory;
  bool _isListExpanded = false;
  Timer? _pieResetTimer;

  @override
  void dispose() {
    _pieResetTimer?.cancel();
    super.dispose();
  }

  void _updateSelectedMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedYear, _selectedMonthIndex, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    // FETCH THEME PROVIDER FOR GRADIENT COLORS
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final monthTx =
    _getTransactionsForMonth(provider.transactions, _selectedMonth);

    final income = monthTx
        .where((t) => t.type == model.TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final investments = monthTx
        .where((t) => t.type == model.TransactionType.investment)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses =
    monthTx.where((t) => t.type == model.TransactionType.expense).toList();
    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);

    final savings = income - (totalExpense + investments);

    final groupedExpenses = _groupExpensesByCategory(expenses);
    final topCategory =
    groupedExpenses.isNotEmpty ? groupedExpenses.first : null;

    return SafeArea(
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
                      _buildYearMonthSelector(onBg),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildHealthCard(
                    theme,
                    provider,
                    income,
                    investments,
                    totalExpense,
                    savings,
                    themeProvider.analyticsCardColors, // <--- PASS DYNAMIC GRADIENT
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          if (expenses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  "No spending data for this period",
                  style: TextStyle(color: onBg.withOpacity(0.5)),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Where did it go?",
                          style: TextStyle(
                            color: onBg,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (topCategory != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: topCategory.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: topCategory.color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: topCategory.color,
                                  size: 12,
                                ),
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event,
                                  PieTouchResponse? response) {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  return;
                                }

                                final newIndex = response
                                    .touchedSection!.touchedSectionIndex;

                                if (newIndex == _touchedIndex) return;

                                setState(() {
                                  _touchedIndex = newIndex;
                                });

                                _pieResetTimer?.cancel();
                                _pieResetTimer =
                                    Timer(const Duration(seconds: 1), () {
                                      if (!mounted) return;
                                      if (_touchedIndex == newIndex) {
                                        setState(() {
                                          _touchedIndex = -1;
                                        });
                                      }
                                    });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                            sections: _buildPieSections(
                                groupedExpenses, totalExpense),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _touchedIndex == -1
                                    ? "Total"
                                    : groupedExpenses[_touchedIndex]
                                    .categoryName,
                                style: TextStyle(
                                  color: onBg.withOpacity(0.6),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                CurrencyFormat.format(
                                  context,
                                  _touchedIndex == -1
                                      ? totalExpense
                                      : groupedExpenses[_touchedIndex].amount,
                                ),
                                style: TextStyle(
                                  color: onBg,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ─── COLLAPSIBLE HEADER ───
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isListExpanded = !_isListExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Here it is!",
                            style: TextStyle(
                              color: onBg,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Icon(
                            _isListExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: onBg.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ─── COLLAPSIBLE LIST ───
            if (_isListExpanded)
              SliverPadding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final category = groupedExpenses[index];
                      final isExpanded =
                          _expandedCategory == category.categoryName;
                      final percentage =
                      (category.amount / totalExpense * 100);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isExpanded
                              ? Border.all(
                            color: const Color(0xFF3B82F6)
                                .withOpacity(0.3),
                          )
                              : null,
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedCategory = isExpanded
                                      ? null
                                      : category.categoryName;
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
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        category.icon,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                category.categoryName,
                                                style: TextStyle(
                                                  color: onBg,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                CurrencyFormat.format(
                                                    context, category.amount),
                                                style: TextStyle(
                                                  color: onBg.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor:
                                              onBg.withOpacity(0.08),
                                              color: category.color,
                                              minHeight: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "${percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        color: onBg.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  children: category.transactions
                                      .map(
                                        (tx) => ListTile(
                                      dense: true,
                                      title: Text(
                                        tx.note ?? tx.categoryName,
                                        style: TextStyle(
                                          color: onBg.withOpacity(0.7),
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "${tx.date.day}/${tx.date.month}",
                                        style: TextStyle(
                                          color: onBg.withOpacity(0.5),
                                          fontSize: 11,
                                        ),
                                      ),
                                      trailing: Text(
                                        CurrencyFormat.format(
                                            context, tx.amount),
                                        style: TextStyle(
                                          color: onBg,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                      .toList(),
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
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ]
        ],
      ),
    );
  }

  // ───────────────── WIDGETS ─────────────────

  Widget _buildYearMonthSelector(Color onBg) {
    final theme = Theme.of(context);
    const monthLabels = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    final now = DateTime.now();
    final years = List<int>.generate(3, (i) => now.year - i);

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: onBg.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<int>(
            padding: EdgeInsets.zero,
            offset: const Offset(0, 28),
            onSelected: (value) {
              setState(() {
                _selectedYear = value;
                _updateSelectedMonth();
              });
            },
            itemBuilder: (ctx) => years
                .map((y) =>
                PopupMenuItem<int>(value: y, child: Text(y.toString())))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    _selectedYear.toString(),
                    style: TextStyle(
                      color: onBg,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: onBg.withOpacity(0.7), size: 16),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 18, color: onBg.withOpacity(0.15)),
          PopupMenuButton<int>(
            padding: EdgeInsets.zero,
            offset: const Offset(0, 28),
            onSelected: (value) {
              setState(() {
                _selectedMonthIndex = value;
                _updateSelectedMonth();
              });
            },
            itemBuilder: (ctx) => List.generate(12, (i) {
              final month = i + 1;
              return PopupMenuItem<int>(
                  value: month, child: Text(monthLabels[i]));
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    monthLabels[_selectedMonthIndex - 1],
                    style: TextStyle(
                      color: onBg,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: onBg.withOpacity(0.7), size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(
      ThemeData theme,
      FinanceProvider provider,
      double income,
      double invested,
      double spent,
      double savings,
      List<Color> gradientColors, // <--- ACCEPT DYNAMIC COLORS
      ) {
    final isLight = theme.brightness == Brightness.light;
    final Color primaryText = isLight ? Colors.black : Colors.white;
    final Color secondaryText =
    isLight ? Colors.black.withOpacity(0.7) : Colors.white70;

    return SizedBox(
      height: 220,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors, // <--- USE DYNAMIC COLORS
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3), // <--- USE DYNAMIC COLORS
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Income",
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  CurrencyFormat.format(context, income),
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    label: "Invested",
                    amount: invested,
                    icon: Icons.trending_up_rounded,
                    provider: provider,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    label: "Spent",
                    amount: spent,
                    icon: Icons.trending_down_rounded,
                    provider: provider,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.savings_outlined,
                        color: secondaryText, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Net Savings",
                      style: TextStyle(
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormat.format(context, savings),
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required double amount,
    required IconData icon,
    required FinanceProvider provider,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: secondaryText, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: secondaryText, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormat.format(context, amount),
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      List<_CategoryGroup> data, double total) {
    return List.generate(data.length, (i) {
      final isTouched = i == _touchedIndex;
      final item = data[i];
      final radius = isTouched ? 65.0 : 55.0;

      return PieChartSectionData(
        color: item.color,
        value: item.amount,
        title: "",
        radius: radius,
        badgeWidget: isTouched
            ? _Badge(item.icon, size: 36, color: item.color)
            : null,
        badgePositionPercentageOffset: .98,
      );
    });
  }

  List<model.TransactionModel> _getTransactionsForMonth(
      List<model.TransactionModel> all, DateTime month) {
    return all
        .where((tx) =>
    tx.date.year == month.year && tx.date.month == month.month)
        .toList();
  }

  List<_CategoryGroup> _groupExpensesByCategory(
      List<model.TransactionModel> expenses) {
    final Map<String, _CategoryGroup> map = {};
    final palette = [
      const Color(0xFFF43F5E),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
      const Color(0xFF14B8A6),
    ];
    int colorIndex = 0;

    for (var tx in expenses) {
      if (map.containsKey(tx.categoryName)) {
        map[tx.categoryName]!.amount += tx.amount;
        map[tx.categoryName]!.transactions.add(tx);
      } else {
        map[tx.categoryName] = _CategoryGroup(
          categoryName: tx.categoryName,
          icon: tx.categoryIcon,
          amount: tx.amount,
          color: palette[colorIndex % palette.length],
          transactions: [tx],
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
  final List<model.TransactionModel> transactions;

  _CategoryGroup({
    required this.categoryName,
    required this.icon,
    required this.amount,
    required this.color,
    required this.transactions,
  });
}

class _Badge extends StatelessWidget {
  final String icon;
  final double size;
  final Color color;

  const _Badge(this.icon, {required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      alignment: Alignment.center,
      child: Text(icon, style: const TextStyle(fontSize: 18)),
    );
  }
}
