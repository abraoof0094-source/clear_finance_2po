import 'dart:math';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/forecast_item.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/add_forecast_item_dialog.dart';
import '../../utils/currency_format.dart';

class LiabilityDetailScreen extends StatefulWidget {
  final ForecastItem item;

  const LiabilityDetailScreen({super.key, required this.item});

  @override
  State<LiabilityDetailScreen> createState() => _LiabilityDetailScreenState();
}

class _LiabilityDetailScreenState extends State<LiabilityDetailScreen> {
  double _plannerMonthlyPayment = 0;

  @override
  void initState() {
    super.initState();
    final monthlyInterest = (widget.item.currentOutstanding * (widget.item.interestRate / 100)) / 12;
    // Fix: Ensure we divide by 100 before ceiling, then multiply back
    double startValue = max(widget.item.monthlyEmiOrContribution, monthlyInterest);
    _plannerMonthlyPayment = (startValue / 100).ceil() * 100.0;
  }

  int _calculateMonthsToPayOff(double totalDebt, double monthlyRate, double monthlyPayment) {
    if (monthlyPayment <= (totalDebt * monthlyRate)) return 999;
    try {
      final numerator = -log(1 - (monthlyRate * totalDebt) / monthlyPayment);
      final denominator = log(1 + monthlyRate);
      return (numerator / denominator).ceil();
    } catch (_) {
      return 999;
    }
  }

  String _formatMonthsToText(int months) {
    if (months >= 999) return "Never (Increase Amount)";
    if (months <= 0) return "1 Month";
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return "$remainingMonths Months";
    if (remainingMonths == 0) return "$years Years";
    return "$years Yr $remainingMonths Mo";
  }

  void _showHelpDialog(BuildContext context, bool isInterestOnly) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.info_outline_rounded, color: Colors.blue),
          ),
          const SizedBox(width: 14),
          Text("How this works", style: TextStyle(fontWeight: FontWeight.bold, color: onBg, fontSize: 20)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isInterestOnly) ...[
              Text("Interest-Only Strategy", style: TextStyle(color: onBg, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                "Your payments are split automatically. Small payments cover interest first; larger payments reduce your principal.",
                style: TextStyle(color: onBg.withOpacity(0.7), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.calculate_outlined, color: Colors.purple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Use the planner to simulate how different monthly payments affect your payoff date.", style: TextStyle(color: Colors.purple[300], fontSize: 12, fontWeight: FontWeight.bold))),
                ]),
              ),
            ] else ...[
              Text("Standard Loan", style: TextStyle(color: onBg, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text("Use the slider to plan extra repayments and see your debt-free date accelerate.", style: TextStyle(color: onBg.withOpacity(0.7), fontSize: 14, height: 1.5)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.blue, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatBox(BuildContext context, String label, String value, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: tint),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
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
      Future.microtask(() => mounted ? Navigator.of(context).pop() : null);
      return const Scaffold(body: Center(child: Text("Item not found.")));
    }

    final bool hasInterest = item.interestRate > 0;

    // Core Data
    final double monthlyInterestRate = (item.interestRate / 100) / 12;
    final double approxInterest = item.currentOutstanding * monthlyInterestRate;

    // Real Split Logic
    final recentPayments = _getRecentPayments(provider, item);
    final now = DateTime.now();
    double totalPaidThisMonth = recentPayments
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double interestPaidReal = 0.0;
    double principalPaidReal = 0.0;

    if (totalPaidThisMonth > 0) {
      double toleranceCap = approxInterest * 1.2;
      if (totalPaidThisMonth <= toleranceCap) {
        interestPaidReal = totalPaidThisMonth;
        principalPaidReal = 0;
      } else {
        interestPaidReal = approxInterest;
        principalPaidReal = totalPaidThisMonth - approxInterest;
      }
    }

    // ─── FIXED SLIDER LOGIC ───
    // 1. Min: Approx Interest (Rounded Up to nearest 100)
    // BUG FIX: Added (/ 100) inside the ceil() logic.
    final double rawMin = approxInterest > 100 ? approxInterest : 100.0;
    final double plannerMin = (rawMin / 100).ceil() * 100.0;

    // 2. Max: 50% of Outstanding (Rounded Down to nearest 100), but at least Min + 5000
    double calculatedMax = (item.currentOutstanding * 0.5 / 100).floor() * 100.0;
    if (calculatedMax < plannerMin + 5000) calculatedMax = plannerMin + 5000;
    final double plannerMax = calculatedMax;

    // 3. Ensure slider state is valid
    if (_plannerMonthlyPayment < plannerMin) _plannerMonthlyPayment = plannerMin;
    if (_plannerMonthlyPayment > plannerMax) _plannerMonthlyPayment = plannerMax;

    // 4. Divisions: Ensure exactly 1 step per 100 units
    final int divisions = max(1, (plannerMax - plannerMin) ~/ 100);

    final int projectedMonths = _calculateMonthsToPayOff(item.currentOutstanding, monthlyInterestRate, _plannerMonthlyPayment);
    final DateTime? projectedDate = projectedMonths < 999 ? DateTime(now.year, now.month + projectedMonths, now.day) : null;
    final double progress = item.targetAmount > 0 ? (item.targetAmount - item.currentOutstanding) / item.targetAmount : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onBg),
        title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: onBg)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: onBg.withOpacity(0.7)),
            onPressed: () => _showHelpDialog(context, hasInterest),
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded, color: onBg.withOpacity(0.7)),
            onPressed: () => showDialog(context: context, builder: (ctx) => AddForecastItemDialog(itemToEdit: item)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        child: Column(
          children: [
            // ─── COMPACT HERO CARD ───
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 8,
              shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                  ),
                ),
                child: Column(
                  children: [
                    const Text("Outstanding Principal", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormat.format(context, item.currentOutstanding),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))]),
                    ),
                    const SizedBox(height: 16),

                    // Reference Line (Compact)
                    if (hasInterest)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flag_rounded, color: Color(0xFFFCD34D), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "Approx. Monthly Interest: ${CurrencyFormat.format(context, approxInterest)}",
                              style: const TextStyle(color: Color(0xFFFCD34D), fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Glass Stats (Compact)
                    if (hasInterest)
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassStatBox(
                              context,
                              "Interest Paid",
                              CurrencyFormat.format(context, interestPaidReal),
                              const Color(0xFFFCD34D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildGlassStatBox(
                              context,
                              "Principal Paid",
                              CurrencyFormat.format(context, principalPaidReal),
                              const Color(0xFF34D399),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── REPAYMENT PLANNER ───
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.tune_rounded, size: 16, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Repayment Planner", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text("Simulate monthly impact", style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Slider Value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                            CurrencyFormat.format(context, _plannerMonthlyPayment),
                            style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.w800)
                        ),
                        const Text("per month", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: theme.colorScheme.primary,
                        thumbColor: theme.colorScheme.primary,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayColor: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: _plannerMonthlyPayment.clamp(plannerMin, plannerMax),
                        min: plannerMin,
                        max: plannerMax,
                        divisions: divisions,
                        onChanged: (val) {
                          final snapped = (val / 100).round() * 100.0;
                          setState(() => _plannerMonthlyPayment = snapped);
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Result Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: projectedDate != null ? const Color(0xFF10B981).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(projectedDate != null ? Icons.verified_rounded : Icons.warning_amber_rounded, color: projectedDate != null ? const Color(0xFF10B981) : Colors.orange, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: projectedDate != null
                                ? Text.rich(TextSpan(
                                style: TextStyle(color: onBg, fontSize: 12),
                                children: [
                                  const TextSpan(text: "Debt free in "),
                                  TextSpan(text: _formatMonthsToText(projectedMonths), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: " (${DateFormat('MMM yyyy').format(projectedDate)})", style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 11)),
                                ]
                            ))
                                : const Text("Amount covers interest only", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // History
            ExpansionTile(
              title: const Text("History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              children: recentPayments.isEmpty
                  ? [const ListTile(title: Center(child: Text("No payments yet", style: TextStyle(color: Colors.grey))))]
                  : recentPayments.map((tx) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long, color: Colors.grey, size: 16),
                ),
                title: Text(DateFormat('dd MMM yyyy').format(tx.date), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                trailing: Text("-${CurrencyFormat.format(context, tx.amount)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _getRecentPayments(FinanceProvider provider, ForecastItem item, {int limit = 5}) {
    if (item.categoryId == null) return [];
    final txs = provider.transactions.where((t) => t.categoryId == item.categoryId).toList()..sort((a, b) => b.date.compareTo(a.date));
    return txs.length > limit ? txs.sublist(0, limit) : txs;
  }
}
