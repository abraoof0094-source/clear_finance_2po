import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Required for ImageFilter blur

import '../../providers/finance_provider.dart';
import '../../widgets/add_transaction_dialog.dart'; // Your custom dialog
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- NAVIGATION HANDLER WITH BLUR DIALOG ---
  void _onNavTapped(int index) {
    if (index == 2) {
      // Open Add Transaction Dialog with Blur
      showDialog(
        context: context,
        barrierDismissible: true,
        // Semi-transparent barrier to let blur shine but darken BG
        barrierColor: Colors.black.withOpacity(0.2),
        builder: (context) => Stack(
          children: [
            // 1. The Blur Layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Nice frosted glass
                child: Container(color: Colors.transparent),
              ),
            ),
            // 2. The Actual Dialog
            const AddTransactionDialog(),
          ],
        ),
      );
    } else {
      // Normal Navigation
      setState(() {
        _currentNavIndex = index;
      });
      // Adjust pageIndex because index 2 is the FAB, not a page
      int pageIndex = index > 2 ? index - 1 : index;
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int pageIndex) {
    // Sync BottomNav with PageView swipes
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

      // MAIN PAGE VIEW
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          // Page 0: Analytics
          const AnalyticsScreen(),

          // Page 1: Home (Dashboard)
          _buildDashboard(provider),

          // Page 2: Forecast (Formerly History)
          const ForecastScreen(),

          // Page 3: Settings
          const SettingsScreen(),
        ],
      ),

      // BOTTOM NAVIGATION BAR
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
            // THE ADD BUTTON
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
              icon: Icon(Icons.insights_outlined), // Outline version
              activeIcon: Icon(Icons.insights_rounded), // Filled/Rounded version
              label: 'Forecast', // Changed label
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

  // --- DASHBOARD CONTENT ---

  Widget _buildDashboard(FinanceProvider provider) {
    if (provider.salaryProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch_rounded, size: 64, color: Color(0xFF3B82F6)),
            const SizedBox(height: 24),
            const Text(
              "Welcome to clear finance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // --- HEADER (Brand + Date Pill) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Title
                const Text(
                  'clear finance',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                // Date Pill
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
                        _getCurrentMonthYear(), // "Dec '25"
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500], size: 16),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- SAFE TO SPEND CARD ---
            Container(
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
            ),

            const SizedBox(height: 24),

            // --- RECENT ACTIVITY ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Activity",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (provider.transactions.isNotEmpty)
                  Text(
                    "${provider.transactions.length} entries",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // --- TRANSACTION LIST ---
            Expanded(
              child: provider.transactions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[700]),
                    const SizedBox(height: 12),
                    Text(
                      "No transactions yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: provider.transactions.length > 10 ? 10 : provider.transactions.length,
                itemBuilder: (context, index) {
                  final tx = provider.transactions[index];
                  final isIncome = tx.type == model.TransactionType.income;
                  final isInvestment = tx.type == model.TransactionType.investment;
                  final color = isIncome
                      ? Colors.greenAccent
                      : (isInvestment ? Colors.blueAccent : Colors.redAccent);
                  final sign = isIncome ? "+" : "-";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${tx.date.day}/${tx.date.month} • ${tx.note ?? ''}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "$sign${provider.currencyFormat.format(tx.amount)}",
                          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final month = months[now.month - 1];
    final year = now.year.toString().substring(2); // '25
    return "$month '$year";
  }
}
