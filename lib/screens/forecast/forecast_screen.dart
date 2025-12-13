import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/forecast_item.dart';
import '../../widgets/add_forecast_item_dialog.dart';
import '../../utils/currency_format.dart';
import 'liability_detail_screen.dart';
import 'goal_detail_screen.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final items = provider.forecastItems;

    final liabilities = items.where((i) => i.isLiability).toList();
    final goals = items.where((i) => !i.isLiability).toList();
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── HEADER SECTION ───
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'clear finance',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // OPTIMIZED HERO CARD
                    _buildForecastHeroCard(
                      context,
                      provider,
                      theme,
                      themeProvider.forecastCardColors,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ─── LIABILITIES LIST ───
              if (liabilities.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Liabilities",
                          style: TextStyle(
                            color: onBg,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "-${CurrencyFormat.format(
                              context,
                              liabilities.fold<double>(
                                0.0,
                                    (sum, item) => sum + item.currentOutstanding,
                              ),
                            )}",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildLiabilityCard(
                      context,
                      liabilities[index],
                      provider,
                    ),
                    childCount: liabilities.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // ─── GOALS LIST ───
              if (goals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Goals",
                          style: TextStyle(
                            color: onBg,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "+${CurrencyFormat.format(
                              context,
                              goals.fold<double>(
                                0.0,
                                    (sum, item) => sum + item.currentOutstanding,
                              ),
                            )}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildGoalHorizontalCard(
                      context,
                      goals[index],
                      provider,
                    ),
                    childCount: goals.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],

              // ─── EMPTY STATE ───
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "No goals or liabilities found.\nTap the + in the card above to start.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: onBg.withOpacity(0.5),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Hero Card code remains unchanged) ...
  Widget _buildForecastHeroCard(
      BuildContext context,
      FinanceProvider provider,
      ThemeData theme,
      List<Color> gradientColors,
      ) {
    final hasDebt = provider.totalCurrentDebt > 0;
    final hasAssets = provider.getTotalAssets() > 0;

    final isLight = theme.brightness == Brightness.light;
    final heroPrimaryText = isLight ? Colors.black : Colors.white;
    final heroSecondaryText =
    isLight ? Colors.black.withOpacity(0.6) : Colors.white70;

    final netWorth = provider.netWorth;
    final netWorthText = CurrencyFormat.format(context, netWorth);

    String leftLabel = "";
    String leftValue = "";
    String rightLabel = "";
    String rightValue = "";
    String bottomText = "";

    if (hasDebt) {
      leftLabel = "Total goals";
      leftValue = CurrencyFormat.format(context, provider.getTotalAssets());
      rightLabel = "Total debt";
      rightValue = CurrencyFormat.format(context, provider.totalCurrentDebt);
      bottomText = "Every payment is progress.";
    } else if (hasAssets) {
      leftLabel = "Goals value";
      leftValue = CurrencyFormat.format(context, provider.getTotalAssets());
      rightLabel = "Saved this month";
      rightValue = "—";
      bottomText = "You’re growing real wealth.";
    } else {
      bottomText = "Start tracking your wealth.";
    }

    final showPills = hasDebt || hasAssets;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── TOP ROW: NET WORTH & ADD BUTTON ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Net Worth Glass Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your net worth",
                        style: TextStyle(
                          color: heroSecondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        netWorthText,
                        style: TextStyle(
                          color: heroPrimaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Square Add Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAddDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: heroPrimaryText,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (showPills) ...[
            const SizedBox(height: 12),
            // ─── BOTTOM ROW: INFO PILLS ───
            Row(
              children: [
                Expanded(
                  child: _buildGlassInfoPill(
                    leftLabel,
                    leftValue,
                    heroPrimaryText,
                    heroSecondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGlassInfoPill(
                    rightLabel,
                    rightValue,
                    heroPrimaryText,
                    heroSecondaryText,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          Text(
            bottomText,
            style: TextStyle(
              color: heroSecondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInfoPill(
      String label,
      String value,
      Color primaryColor,
      Color secondaryColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilityCard(
      BuildContext context,
      ForecastItem item,
      FinanceProvider provider,
      ) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    double progress = 0;
    if (item.targetAmount > 0) {
      progress =
          (1.0 - (item.currentOutstanding / item.targetAmount)).clamp(0.0, 1.0);
    }

    // ✨ UPDATED: Correct Subtitle Logic
    String subtitle;
    switch (item.type) {
      case ForecastType.emiInterestOnly:
        subtitle = "Interest only loan";
        break;
      case ForecastType.debtSimple:
        subtitle = "Personal Debt";
        break;
      case ForecastType.emiAmortized:
      default:
        subtitle = "Reducing balance loan";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiabilityDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onBg.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(item.colorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: onBg,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle, // Using dynamic subtitle
                        style: TextStyle(
                          color: onBg.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormat.format(context, item.currentOutstanding),
                      style: TextStyle(
                        color: onBg,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Outstanding",
                      style: TextStyle(
                        color: onBg.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: onBg.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(item.colorValue),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(progress * 100).toStringAsFixed(0)}% paid off",
                  style: TextStyle(
                    color: Color(item.colorValue),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.monthlyEmiOrContribution > 0)
                  Text(
                    "EMI: ${CurrencyFormat.format(context, item.monthlyEmiOrContribution)}",
                    style: TextStyle(
                      color: onBg.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHorizontalCard(
      BuildContext context,
      ForecastItem item,
      FinanceProvider provider,
      ) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    double progress = 0;
    if (item.targetAmount > 0) {
      progress = (item.currentOutstanding / item.targetAmount).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onBg.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(item.colorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: onBg,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.targetAmount > 0
                            ? "Target: ${CurrencyFormat.format(context, item.targetAmount)}"
                            : "Savings Goal",
                        style: TextStyle(
                          color: onBg.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormat.format(context, item.currentOutstanding),
                      style: TextStyle(
                        color: onBg,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Saved",
                      style: TextStyle(
                        color: onBg.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: onBg.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(item.colorValue),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(progress * 100).toStringAsFixed(0)}% achieved",
                  style: TextStyle(
                    color: Color(item.colorValue),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.monthlyEmiOrContribution > 0)
                  Text(
                    "Monthly: ${CurrencyFormat.format(context, item.monthlyEmiOrContribution)}",
                    style: TextStyle(
                      color: onBg.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddForecastItemDialog(),
    );
  }
}
