import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/forecast_item.dart';
import '../../widgets/add_forecast_item_dialog.dart';
import 'liability_detail_screen.dart';
import 'asset_detail_screen.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final items = provider.forecastItems;

    final liabilities = items.where((i) => i.isLiability).toList();
    final assets = items.where((i) => !i.isLiability).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header & Net Worth Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // --- BRAND HEADER ---
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
                        _buildAddItemButton(context), // CHANGED: Date pill becomes Add Item button
                      ],
                    ),

                    const SizedBox(height: 24),

                    // NET WORTH CARD
                    _buildNetWorthCard(provider),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 2. Liabilities Section
            if (liabilities.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Liabilities", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "-${provider.currencyFormat.format(liabilities.fold(0.0, (sum, item) => sum + item.currentAmount))}",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildLiabilityCard(context, liabilities[index], provider),
                  childCount: liabilities.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // 3. Assets Section
            if (assets.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Assets & Goals", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAssetCard(context, assets[index], provider),
                    childCount: assets.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],

            // 4. Empty State (UPDATED MESSAGE)
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline_outlined, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      const Text(
                        "No strategies yet.",
                        style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Tap 'Add Item' above to track your first goal or debt.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      // REMOVED: FloatingActionButton is now removed
    );
  }

  // --- WIDGETS ---

  // NEW: Add Item button (replacing date pill)
  Widget _buildAddItemButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Color(0xFF3B82F6), size: 16),
            SizedBox(width: 6),
            Text(
              'Add Item',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthCard(FinanceProvider provider) {
    final netWorth = provider.netWorth;
    final isPositive = netWorth >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFF43F5E), const Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Projected Net Worth", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            provider.currencyFormat.format(netWorth),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            isPositive ? "You are building wealth!" : "Let's clear those debts.",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilityCard(BuildContext context, ForecastItem item, FinanceProvider provider) {
    double progress = 0;
    if (item.targetAmount > 0) {
      progress = (1.0 - (item.currentAmount / item.targetAmount)).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LiabilityDetailScreen(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Color(item.colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        item.type == ForecastType.debtInterestOnly ? "Interest Only Loan" : "Reducing Balance",
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(provider.currencyFormat.format(item.currentAmount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("Outstanding", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3))),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 6, decoration: BoxDecoration(color: Color(item.colorValue), borderRadius: BorderRadius.circular(3))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${(progress * 100).toStringAsFixed(0)}% Paid Off", style: TextStyle(color: Color(item.colorValue), fontSize: 11, fontWeight: FontWeight.bold)),
                if (item.monthlyPayment > 0)
                  Text("EMI: ${provider.currencyFormat.format(item.monthlyPayment)}", style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, ForecastItem item, FinanceProvider provider) {
    double progress = 0;
    if (item.targetAmount > 0) {
      progress = (item.currentAmount / item.targetAmount).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssetDetailScreen(item: item)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 24)),
                if (item.targetAmount > 0)
                  Text("${(progress * 100).toStringAsFixed(0)}%", style: TextStyle(color: Color(item.colorValue), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(provider.currencyFormat.format(item.currentAmount), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black26,
                color: Color(item.colorValue),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddForecastItemDialog(),
    );
  }
}
