import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:isar/isar.dart';

import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../models/transaction_model.dart' as model;
import '../../models/category_model.dart';
import '../../models/recurring_pattern.dart';
import '../../utils/currency_format.dart';
import '../../services/database_service.dart';

import '../settings/settings_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/categories_screen.dart';
import '../forecast/forecast_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1);

  // 🟢 Cache for patterns to enable "Soft Matching"
  List<RecurringPattern> _recurringPatterns = [];

  int _currentNavIndex = 1;
  bool _isActivityExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecurringPatterns();
  }

  // 🟢 Load patterns so we can "guess" recurring transactions
  Future<void> _loadRecurringPatterns() async {
    final isar = DatabaseService().syncDb;
    final patterns = await isar.recurringPatterns.where().filter().isActiveEqualTo(true).findAll();
    if (mounted) {
      setState(() {
        _recurringPatterns = patterns;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 2) {
      _showTransactionDialog(context, null);
      return;
    }
    final pageIndex = index > 2 ? index - 1 : index;

    setState(() {
      _currentNavIndex = index;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int pageIndex) {
    int navIndex;
    if (pageIndex <= 1) {
      navIndex = pageIndex;
    } else {
      navIndex = pageIndex + 1;
    }

    setState(() {
      _currentNavIndex = navIndex;
    });
  }

  void _showTransactionDialog(
      BuildContext context,
      model.TransactionModel? transaction,
      ) {
    final finance = Provider.of<FinanceProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AddTransactionSheet(
            transactionToEdit: transaction,
            allowedBuckets: const [
              CategoryBucket.income,
              CategoryBucket.expense,
              CategoryBucket.invest,
              CategoryBucket.liability,
              CategoryBucket.goal,
            ],
            onSave: (tx, {required bool isEditing}) async {
              if (isEditing) {
                finance.updateTransaction(tx);
              } else {
                finance.addTransaction(tx);
              }
              // 🟢 Refresh patterns to immediately show icon if a new rule was made
              await _loadRecurringPatterns();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final bottomBarColor = theme.bottomNavigationBarTheme.backgroundColor ??
        theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: null,
      floatingActionButtonLocation: null,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          const AnalyticsScreen(),
          _buildDashboard(provider, theme, onBg, themeProvider.homeCardColors),
          const ForecastScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: theme.copyWith(
          canvasColor: bottomBarColor,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bottomBarColor,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: onBg.withOpacity(0.6),
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Analytics',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              activeIcon: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'Forecast',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── DASHBOARD ─────────────────

  Widget _buildDashboard(
      FinanceProvider provider,
      ThemeData theme,
      Color onBg,
      List<Color> gradientColors,
      ) {
    final now = DateTime.now();
    final List<model.TransactionModel> allTransactions = provider.transactions;
    final hasAnyData = allTransactions.isNotEmpty;

    final currentMonthTransactions = allTransactions
        .where((tx) => tx.date.month == now.month && tx.date.year == now.year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final groupedTransactions =
    _groupTransactionsByWeek(currentMonthTransactions);

    final bool hasCurrentMonthData = currentMonthTransactions.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: onBg.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: onBg.withOpacity(0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getCurrentMonthYear(),
                              style: TextStyle(
                                color: onBg,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSafeToSpendCard(provider, theme, hasAnyData, gradientColors),
                  const SizedBox(height: 24),
                  if (hasCurrentMonthData) ...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isActivityExpanded = !_isActivityExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Monthly Transactions",
                              style: TextStyle(
                                color: onBg,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              _isActivityExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: onBg.withOpacity(0.8),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            if (!hasCurrentMonthData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    "No spending data for this month.",
                    style: TextStyle(
                      color: onBg.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            if (hasCurrentMonthData && _isActivityExpanded)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final groupKey = groupedTransactions.keys.elementAt(index);
                    final transactions = groupedTransactions[groupKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _weekHeader(groupKey, onBg),
                        ...transactions.map(
                              (tx) => _buildTransactionItem(
                            context,
                            tx,
                            provider,
                            theme,
                            onBg,
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: groupedTransactions.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _weekHeader(String label, Color onBg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        label,
        style: TextStyle(
          color: onBg.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, List<model.TransactionModel>> _groupTransactionsByWeek(
      List<model.TransactionModel> transactions,
      ) {
    final Map<String, List<model.TransactionModel>> groups = {};
    final now = DateTime.now();

    final currentWeekday = now.weekday;
    final startOfThisWeek =
    DateTime(now.year, now.month, now.day - currentWeekday + 1);
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final startOf2WeeksAgo = startOfThisWeek.subtract(const Duration(days: 14));

    for (var tx in transactions) {
      String label;
      if (tx.date
          .isAfter(startOfThisWeek.subtract(const Duration(seconds: 1)))) {
        label = "This week";
      } else if (tx.date
          .isAfter(startOfLastWeek.subtract(const Duration(seconds: 1)))) {
        label = "Last week";
      } else if (tx.date
          .isAfter(startOf2WeeksAgo.subtract(const Duration(seconds: 1)))) {
        label = "2 Weeks ago";
      } else {
        label = "Earlier this month";
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(tx);
    }
    return groups;
  }

  // ───────────────── HERO CARD ─────────────────

  Color _progressColor(double pct) {
    if (pct >= 1.0) return const Color(0xFF22C55E);
    if (pct >= 0.75) return const Color(0xFF4ADE80);
    if (pct >= 0.5) return const Color(0xFFFACC15);
    return const Color(0xFFFB7185);
  }

  Widget _buildSafeToSpendCard(
      FinanceProvider provider,
      ThemeData theme,
      bool hasAnyData,
      List<Color> gradientColors,
      ) {
    final safe = provider.totalBalance;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;
    final dailySafe = safe > 0 ? (safe / daysRemaining) : 0.0;

    final mandateCats = provider.categories.where(
          (c) =>
      c.bucket == CategoryBucket.expense &&
          c.isMandate &&
          c.monthlyMandate != null,
    );

    final hasAnyBudget = mandateCats.isNotEmpty;
    double progress = 0;
    double spentThisMonth = 0;
    double totalBudget = 0;

    if (hasAnyBudget) {
      totalBudget = mandateCats.fold<double>(
        0.0,
            (sum, c) => sum + (c.monthlyMandate ?? 0),
      );
      spentThisMonth = provider.transactions
          .where(
            (tx) =>
        tx.categoryBucket == CategoryBucket.expense &&
            tx.date.month == now.month &&
            tx.date.year == now.year &&
            mandateCats.any((c) => c.id == tx.categoryId),
      )
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);
      progress = totalBudget > 0
          ? (spentThisMonth / totalBudget).clamp(0.0, 1.2)
          : 0.0;
    }

    final clamped = progress.clamp(0.0, 1.0);
    final progressPct = (clamped * 100).round();

    final isLight = theme.brightness == Brightness.light;
    final Color primaryText = isLight ? Colors.black : Colors.white;
    final Color secondaryText =
    isLight ? Colors.black.withOpacity(0.7) : Colors.white70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 110,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_moon_rounded,
                            color: secondaryText,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Safe to spend",
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormat.format(context, safe),
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Total available",
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  height: 110,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sunny,
                            color: Color(0xFFFACC15), // Electric yellow
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Daily Average",
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormat.format(context, dailySafe),
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "For next $daysRemaining days",
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          if (hasAnyBudget)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Essentials for this month",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = constraints.maxWidth;
                      return Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: clamped,
                            ),
                            builder: (context, value, _) {
                              final color = _progressColor(value);
                              return Stack(
                                children: [
                                  Container(
                                    width: barWidth * value,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: LinearGradient(
                                        colors: [
                                          color.withOpacity(0.9),
                                          color,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(999),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.45),
                                              blurRadius: 10,
                                              spreadRadius: 0.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${CurrencyFormat.format(context, spentThisMonth)} of ${CurrencyFormat.format(context, totalBudget)}",
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "${progressPct.clamp(0, 120)}%",
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(initialIndex: 0),
                ),
              ),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: secondaryText,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Add rough amounts to mandates to see progress.",
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────── TRANSACTION ITEM ─────────────────

  // 🟢 Helper to "Soft Match" transactions to rules
  bool _isPotentialRecurringMatch(model.TransactionModel tx) {
    if (_recurringPatterns.isEmpty) return false;
    return _recurringPatterns.any((p) =>
    p.categoryId == tx.categoryId &&
        p.categoryBucket == tx.categoryBucket &&
        (p.amount - tx.amount).abs() < 0.01);
  }

  Widget _buildTransactionItem(
      BuildContext context,
      model.TransactionModel tx,
      FinanceProvider provider,
      ThemeData theme,
      Color onBg,
      ) {
    final isIncome = tx.type == model.TransactionType.income;
    final isInvestment = tx.type == model.TransactionType.investment;
    final color = isIncome
        ? Colors.greenAccent
        : (isInvestment ? Colors.blueAccent : Colors.redAccent);
    final sign = isIncome ? "+" : "-";

    final bool isRecurring =
        (tx.recurringRuleId != null) || _isPotentialRecurringMatch(tx);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onBg.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              tx.categoryIcon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tx.categoryName,
                      style: TextStyle(
                        color: onBg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // 🟢 SHOW ICON
                    if (isRecurring) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.update,
                        size: 13,
                        color: onBg.withOpacity(0.5),
                      ),
                    ],
                  ],
                ),
                if (tx.note != null && tx.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onBg.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  "${tx.date.day} ${_getMonthName(tx.date.month)}",
                  style: TextStyle(
                    color: onBg.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$sign${CurrencyFormat.format(context, tx.amount)}",
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  color: onBg.withOpacity(0.5),
                  size: 18,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showTransactionDialog(context, tx);
                  } else if (value == 'delete') {
                    // 🟢 UPDATED: Pass the full object to check recurring status
                    _confirmDelete(context, provider, tx);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🟢 IMPROVED DELETE DIALOG
  void _confirmDelete(
      BuildContext context,
      FinanceProvider provider,
      model.TransactionModel tx,
      ) {
    // Check if this transaction is linked to a rule
    final isLinkedToRule = tx.recurringRuleId != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: const Text("Delete Transaction?"),
        content: Text(
          isLinkedToRule
              ? "This is a recurring transaction. Do you want to stop future repeats too?"
              : "This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),

          // Option 1: Delete Only This Transaction
          TextButton(
            onPressed: () {
              provider.deleteTransaction(tx.id);
              Navigator.pop(ctx);
              _loadRecurringPatterns(); // Refresh UI
            },
            child: Text(
              isLinkedToRule ? "Delete This One" : "Delete",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),

          // Option 2: Delete AND Stop Recurrence (Only if linked)
          if (isLinkedToRule)
            TextButton(
              onPressed: () async {
                // Delete the transaction
                provider.deleteTransaction(tx.id);
                // Delete the recurring rule
                await provider.deleteRecurringPattern(tx.recurringRuleId!);

                if (context.mounted) Navigator.pop(ctx);
                _loadRecurringPatterns(); // Refresh UI
              },
              child: const Text(
                "Stop Repeating",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    return "${_getMonthName(now.month)} '${now.year.toString().substring(2)}";
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}
