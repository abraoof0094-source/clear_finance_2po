import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/forecast_item.dart';
import '../../models/transaction_record.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/add_forecast_item_dialog.dart';

class AssetDetailScreen extends StatefulWidget {
  final ForecastItem item;

  const AssetDetailScreen({super.key, required this.item});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late double _projectedValue;

  @override
  void initState() {
    super.initState();
    // Temporary initial value; will be overwritten in build with latest item
    _projectedValue = widget.item.currentAmount;
  }

  double _calculateProjectedValue(ForecastItem item) {
    if (item.interestRate <= 0) return item.currentAmount;

    final monthlyRate = (item.interestRate / 100) / 12;
    double fv = item.currentAmount;

    for (int i = 0; i < 120; i++) {
      fv = fv * (1 + monthlyRate);
      if (item.monthlyPayment > 0) {
        fv += item.monthlyPayment;
      }
    }
    return fv;
  }

  String _formatDuration(DateTime endDate) {
    final now = DateTime.now();
    final monthsDiff =
        (endDate.year - now.year) * 12 + endDate.month - now.month;
    if (monthsDiff <= 0) return "Already achieved!";
    if (monthsDiff < 12) return "in $monthsDiff months";
    final years = monthsDiff ~/ 12;
    final months = monthsDiff % 12;
    if (months == 0) return "in $years years";
    return "in $years yr $months mo";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    ForecastItem item;
    try {
      item =
          provider.forecastItems.firstWhere((i) => i.id == widget.item.id);
    } catch (e) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currency = provider.currencyFormat;

    // Recompute projection using latest item from provider
    _projectedValue = _calculateProjectedValue(item);

    DateTime? achievementDate;
    if (item.targetAmount > 0 && item.currentAmount < item.targetAmount) {
      final monthlyRate = (item.interestRate / 100) / 12;
      double balance = item.currentAmount;
      int months = 0;

      while (balance < item.targetAmount && months < 600) {
        balance = balance * (1 + monthlyRate) + item.monthlyPayment;
        months++;
      }
      if (months < 600) {
        final now = DateTime.now();
        achievementDate = DateTime(now.year, now.month + months, now.day);
      }
    }

    double progress = 0.0;
    if (item.targetAmount > 0) {
      progress =
          (item.currentAmount / item.targetAmount).clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) =>
                    AddForecastItemDialog(itemToEdit: item),
              ).then((_) => setState(() {}));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Current Balance",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(item.currentAmount),
                      style: const TextStyle(
                        color: Colors.white,
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
                      "${(progress * 100).toStringAsFixed(0)}% of Goal",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // PROJECTION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "10-Year Projection",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currency.format(_projectedValue),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "@ ${item.interestRate}% annual return",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ACHIEVEMENT DATE
              if (achievementDate != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.greenAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Goal Achieved By",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formatDuration(achievementDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "(${DateFormat('MMM yyyy').format(achievementDate)})",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      "Increase contributions to see achievement date",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // TRANSACTION HISTORY (COLLAPSIBLE)
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    "Recent Contributions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  initiallyExpanded: false,
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.grey,
                  children: [
                    Consumer<FinanceProvider>(
                      builder: (ctx, prov, _) {
                        final history =
                        prov.getRecentForecastTransactions(item.id,
                            limit: 10);
                        if (history.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(
                              "No contributions yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return Column(
                          children: history
                              .map(
                                (tx) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.greenAccent
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prov.currencyFormat
                                                .format(tx.amount),
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(tx.date),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        final newItem = ForecastItem(
                                          id: item.id,
                                          name: item.name,
                                          icon: item.icon,
                                          type: item.type,
                                          currentAmount:
                                          item.currentAmount -
                                              tx.amount,
                                          targetAmount:
                                          item.targetAmount,
                                          interestRate:
                                          item.interestRate,
                                          monthlyPayment:
                                          item.monthlyPayment,
                                          colorValue: item.colorValue,
                                        );
                                        provider
                                            .updateForecastItem(newItem);
                                        provider.deleteForecastTransaction(
                                            tx.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BUTTONS (no delete here; delete will live in edit dialog)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.4),
                  ),
                  onPressed: () =>
                      _showAddContributionDialog(context, item, provider),
                  icon: const Icon(Icons.add_circle_rounded,
                      color: Colors.white),
                  label: const Text(
                    "Add Contribution",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContributionDialog(
      BuildContext context,
      ForecastItem item,
      FinanceProvider provider,
      ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Add to ${item.name}",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "How much did you contribute?",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: "₹",
                prefixStyle: const TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                ),
                hintText: "Enter amount",
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.greenAccent.withOpacity(0.5),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.greenAccent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount <= 0) return;

              final newItem = ForecastItem(
                id: item.id,
                name: item.name,
                icon: item.icon,
                type: item.type,
                currentAmount: item.currentAmount + amount,
                targetAmount: item.targetAmount,
                interestRate: item.interestRate,
                monthlyPayment: item.monthlyPayment,
                colorValue: item.colorValue,
              );

              provider.updateForecastItem(newItem);

              final transaction = TransactionRecord(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                itemId: item.id,
                itemName: item.name,
                amount: amount,
                date: DateTime.now(),
                type: 'contribution',
              );
              provider.addForecastTransaction(transaction);

              Navigator.pop(ctx);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
