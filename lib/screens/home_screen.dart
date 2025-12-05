import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../providers/finance_provider.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../models/transaction.dart' as model;
import 'settings/settings_screen.dart';
import 'analytics/analytics_screen.dart';
import 'forecast/forecast_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentNavIndex = 1;

  // Default collapsed
  bool _isActivityExpanded = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 2) {
      // Open dialog for NEW transaction (pass null)
      _showTransactionDialog(context, null);
    } else {
      setState(() {
        _currentNavIndex = index;
      });
      int pageIndex = index > 2 ? index - 1 : index;
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showTransactionDialog(BuildContext context, model.Transaction? transaction) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          // --- HERE IS THE FIX ---
          // We pass the transaction to the dialog so it knows to Edit!
          AddTransactionDialog(transactionToEdit: transaction),
        ],
      ),
    );
  }

  void _onPageChanged(int pageIndex) {
    int navIndex = pageIndex >= 2 ? pageIndex + 1 : pageIndex;
    setState(() {
      _currentNavIndex = navIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final bool isSetupComplete = provider.salaryProfile != null;

    if (!isSetupComplete) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: _buildDashboard(provider),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          const AnalyticsScreen(),
          _buildDashboard(provider),
          const ForecastScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1E293B),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFF3B82F6),
          unselectedItemColor: Colors.grey,
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
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x663B82F6),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
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

  Widget _buildDashboard(FinanceProvider provider) {
    if (provider.salaryProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    // Show ALL transactions for the current month
    final currentMonthTransactions = provider.transactions.where((tx) {
      return tx.date.month == now.month && tx.date.year == now.year;
    }).toList();

    currentMonthTransactions.sort((a, b) => b.date.compareTo(a.date));

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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: Colors.grey[400], size: 14),
                            const SizedBox(width: 8),
                            Text(
                              _getCurrentMonthYear(),
                              style: const TextStyle(
                                color: Colors.white,
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

                  _buildSafeToSpendCard(provider),

                  const SizedBox(height: 24),

                  // Transactions Header
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isActivityExpanded = !_isActivityExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Transactions",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Icon(
                            _isActivityExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            if (_isActivityExpanded)
              if (currentMonthTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text(
                        "No transactions this month.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final tx = currentMonthTransactions[index];
                      return _buildTransactionItem(context, tx, provider);
                    },
                    childCount: currentMonthTransactions.length,
                  ),
                ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeToSpendCard(FinanceProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Safe to Spend",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            provider.currencyFormat.format(provider.totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                  "Income",
                  provider.salaryProfile != null
                      ? (provider.salaryProfile!.monthlySalary ?? 0.0)
                      : provider.totalIncome,
                  Icons.arrow_downward,
                  Colors.greenAccent),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildMiniStat("Spent", provider.totalExpenses,
                  Icons.arrow_upward, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, model.Transaction tx, FinanceProvider provider) {
    final isIncome = tx.type == model.TransactionType.income;
    final isInvestment = tx.type == model.TransactionType.investment;
    final color = isIncome
        ? Colors.greenAccent
        : (isInvestment ? Colors.blueAccent : Colors.redAccent);
    final sign = isIncome ? "+" : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(tx.categoryIcon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.categoryName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "${tx.date.day} ${_getMonthName(tx.date.month)}",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            "$sign${provider.currencyFormat.format(tx.amount)}",
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(width: 16),

          // EDIT BUTTON
          GestureDetector(
            onTap: () => _showTransactionDialog(context, tx),
            child: Icon(Icons.edit_outlined, color: Colors.grey[600], size: 20),
          ),

          const SizedBox(width: 16),

          // DELETE BUTTON
          GestureDetector(
            onTap: () => _confirmDelete(context, provider, tx.id),
            child: Icon(Icons.delete_outline_rounded, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FinanceProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Delete Transaction?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              // --- HERE IS THE FIX ---
              // We actually call the provider method now!
              provider.deleteTransaction(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              "₹${amount.toStringAsFixed(0)}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    return "${_getMonthName(now.month)} '${now.year.toString().substring(2)}";
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
