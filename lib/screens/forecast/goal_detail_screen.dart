import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/forecast_item.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/add_forecast_item_dialog.dart';
import '../../utils/currency_format.dart';

class GoalDetailScreen extends StatefulWidget {
  final ForecastItem item;

  const GoalDetailScreen({super.key, required this.item});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  // Local state for the simulation slider
  double _simulatedMonthlyContribution = 0;

  @override
  void initState() {
    super.initState();
    // Initialize simulation with the actual plan amount, or a default if 0
    _simulatedMonthlyContribution = widget.item.monthlyEmiOrContribution > 0
        ? widget.item.monthlyEmiOrContribution
        : 5000; // Default start point for simulation if no plan exists
  }

  String _formatDuration(DateTime targetDate) {
    final now = DateTime.now();
    final monthsDiff =
        (targetDate.year - now.year) * 12 + targetDate.month - now.month;
    if (monthsDiff <= 0) return "This month!";
    if (monthsDiff < 12) return "in $monthsDiff months";
    final years = monthsDiff ~/ 12;
    final months = monthsDiff % 12;
    if (months == 0) return "in $years years";
    return "in $years yr $months mo";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    late final ForecastItem item;
    try {
      item = provider.forecastItems.firstWhere((i) => i.id == widget.item.id);
    } catch (_) {
      Future.microtask(() {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    // 1. Progress Calculation
    double progress = 0.0;
    if (item.targetAmount > 0) {
      progress = (item.currentOutstanding / item.targetAmount).clamp(0.0, 1.0);
    }

    // 2. Simulation Calculation
    DateTime? completionDate;
    final double monthlyContribution = _simulatedMonthlyContribution;
    final bool hasContribution = monthlyContribution > 0;

    if (item.targetAmount > 0 && hasContribution) {
      double needed = item.targetAmount - item.currentOutstanding;
      if (needed <= 0) {
        completionDate = DateTime.now();
      } else {
        // Simple projection
        double months = needed / monthlyContribution;

        // Simple Interest impact approx
        if (item.interestRate > 0) {
          // Basic heuristic for display speed
          // Not doing full loop for UI responsiveness
          double rateFactor = 1.0 + (item.interestRate / 100.0);
          // slightly faster
          months = months / sqrt(rateFactor);
        }

        if (months < 600) { // Limit to 50 years
          final now = DateTime.now();
          int mInt = months.ceil();
          completionDate = DateTime(now.year, now.month + mInt, now.day);
        }
      }
    }

    // 3. Slider Range Configuration (FIXED)
    // We base the max on the *static* plan amount (or 1 Lakh), NOT the dynamic slider value.
    const double baseLimit = 100000.0; // 1 Lakh limit
    final double planAmount = item.monthlyEmiOrContribution;

    // If the user's actual plan is huge (e.g. 2 Lakhs), allow the slider to go higher.
    // Otherwise, cap it at 1 Lakh.
    final double sliderMax = planAmount > (baseLimit * 0.8)
        ? max(baseLimit, planAmount * 2)
        : baseLimit;

    // Determine divisions for nice snapping (e.g., increments of 500 or 1000)
    int divisions = (sliderMax / 500).floor();
    if (divisions < 10) divisions = 10;
    if (divisions > 200) divisions = 200;

    final isLight = theme.brightness == Brightness.light;
    final heroPrimaryText = isLight ? Colors.black : Colors.white;
    final heroSecondaryText = isLight ? Colors.black.withOpacity(0.7) : Colors.white70;

    final recentContributions = _getRecentContributions(provider, item);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onBg),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: onBg),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: onBg.withOpacity(0.7)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AddForecastItemDialog(itemToEdit: item),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // ─── HERO CARD ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Current goal balance",
                      style: TextStyle(color: heroSecondaryText, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormat.formatCompact(context, item.currentOutstanding),
                      style: TextStyle(
                        color: heroPrimaryText,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.black26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}% of goal",
                      style: TextStyle(
                        color: heroSecondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── SIMULATION SLIDER CARD ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: onBg.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Simulated Monthly Contribution",
                      style: TextStyle(
                        color: onBg.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "+ ${CurrencyFormat.formatCompact(context, _simulatedMonthlyContribution)}",
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((_simulatedMonthlyContribution - item.monthlyEmiOrContribution).abs() < 1 && item.monthlyEmiOrContribution > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: onBg.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Current Plan",
                              style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),

                    // SLIDER
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF10B981),
                        thumbColor: Colors.white,
                        inactiveTrackColor: onBg.withOpacity(0.1),
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: _simulatedMonthlyContribution.clamp(0, sliderMax),
                        min: 0,
                        max: sliderMax,
                        divisions: divisions,
                        onChanged: (val) {
                          setState(() {
                            _simulatedMonthlyContribution = val;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // FEEDBACK TEXT
                    if (completionDate != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flag_rounded, size: 20, color: Color(0xFF10B981)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Goal reached ${_formatDuration(completionDate)}",
                                  style: TextStyle(
                                    color: onBg,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMMM yyyy').format(completionDate),
                                  style: TextStyle(
                                    color: onBg.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: onBg.withOpacity(0.4)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Move the slider to see how fast you can reach your goal.",
                              style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── RECENT CONTRIBUTIONS ───
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    "Recent contributions",
                    style: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: true,
                  iconColor: onBg,
                  collapsedIconColor: onBg.withOpacity(0.5),
                  children: [
                    if (recentContributions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                        child: Text(
                          "No contributions recorded yet",
                          style: TextStyle(color: onBg.withOpacity(0.6)),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: recentContributions.map((tx) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: onBg.withOpacity(0.05)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "+${CurrencyFormat.formatCompact(context, tx.amount)}",
                                            style: const TextStyle(
                                              color: Color(0xFF10B981),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(tx.date),
                                            style: TextStyle(color: onBg.withOpacity(0.6), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  List<TransactionModel> _getRecentContributions(
      FinanceProvider provider,
      ForecastItem item, {
        int limit = 10,
      }) {
    if (item.categoryId == null) return [];
    final txs = provider.transactions
        .where((t) => t.categoryId == item.categoryId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (txs.length > limit) {
      return txs.sublist(0, limit);
    }
    return txs;
  }
}
