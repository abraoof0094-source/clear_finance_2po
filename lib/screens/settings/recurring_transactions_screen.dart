import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/database_service.dart';
import '../../models/recurring_pattern.dart';
import '../../providers/finance_provider.dart';
import '../../providers/preferences_provider.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  late Stream<List<RecurringPattern>> _patternsStream;

  @override
  void initState() {
    super.initState();
    final isar = DatabaseService().syncDb;
    _patternsStream = isar.recurringPatterns.where().watch(fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final currency = context.watch<PreferencesProvider>().currencySymbol;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Recurring & Subscriptions"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: onBg, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: onBg),
      ),
      body: StreamBuilder<List<RecurringPattern>>(
        stream: _patternsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final patterns = snapshot.data ?? [];

          if (patterns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_repeat_rounded, size: 64, color: onBg.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text("No active subscriptions", style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Transactions marked 'Recurring' appear here.", style: TextStyle(color: onBg.withOpacity(0.3), fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: patterns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pattern = patterns[index];
              return _SubscriptionCard(pattern: pattern, currency: currency);
            },
          );
        },
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final RecurringPattern pattern;
  final String currency;

  const _SubscriptionCard({required this.pattern, required this.currency});

  // Helper to get category name from Provider if not stored in pattern
  String _getCategoryName(BuildContext context, int catId) {
    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final cat = provider.categories.firstWhere((c) => c.id == catId);
      return cat.name;
    } catch (e) {
      return pattern.categoryBucket.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isar = DatabaseService().syncDb;
    final onBg = theme.colorScheme.onSurface;

    final daysLeft = pattern.nextDueDate.difference(DateTime.now()).inDays;
    String dueText = daysLeft < 0
        ? "Overdue"
        : (daysLeft == 0 ? "Due Today" : "Due in $daysLeft days");

    Color dueColor = daysLeft <= 0 ? Colors.redAccent : onBg.withOpacity(0.4);

    // Resolve category name
    final categorySubtitle = _getCategoryName(context, pattern.categoryId);

    return Dismissible(
      key: Key(pattern.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async => await _confirmDelete(context),
      onDismissed: (direction) async {
        await isar.writeTxn(() async => await isar.recurringPatterns.delete(pattern.id));
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subscription removed")));
      },
      child: GestureDetector(
        onTap: () => _showEditSheet(context, pattern),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: onBg.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Emoji Icon
              Container(
                width: 48, height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
                child: Text(pattern.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE (from Note)
                    Text(pattern.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: onBg)),

                    // SUBTITLE (Category Name)
                    const SizedBox(height: 2),
                    Text(categorySubtitle, style: TextStyle(fontSize: 12, color: onBg.withOpacity(0.6), fontWeight: FontWeight.w500)),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(pattern.frequency.name.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        ),
                        const SizedBox(width: 8),
                        Text("$currency${pattern.amount.toStringAsFixed(0)}", style: TextStyle(fontSize: 13, color: onBg.withOpacity(0.7))),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 24,
                    child: Switch(
                      value: pattern.isActive,
                      onChanged: (val) async {
                        await isar.writeTxn(() async {
                          pattern.isActive = val;
                          await isar.recurringPatterns.put(pattern);
                        });
                      },
                      activeColor: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      DateFormat('MMM d').format(pattern.nextDueDate),
                      style: TextStyle(fontSize: 12, color: dueColor, fontWeight: FontWeight.w600)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Rule?"),
        content: const Text("This will stop future auto-logging. Past transactions remain."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  void _showEditSheet(BuildContext context, RecurringPattern pattern) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditRecurringSheet(pattern: pattern),
    );
  }
}

class _EditRecurringSheet extends StatefulWidget {
  final RecurringPattern pattern;
  const _EditRecurringSheet({required this.pattern});

  @override
  State<_EditRecurringSheet> createState() => _EditRecurringSheetState();
}

class _EditRecurringSheetState extends State<_EditRecurringSheet> {
  late TextEditingController _amountCtrl;
  late RecurrenceFrequency _frequency;
  late DateTime _nextDate;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.pattern.amount.toStringAsFixed(0));
    _frequency = widget.pattern.frequency;
    _nextDate = widget.pattern.nextDueDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final currencySymbol = context.watch<PreferencesProvider>().currencySymbol;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Edit Subscription", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBg)),
              const Spacer(),
              IconButton(
                onPressed: () => _deletePattern(),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: "Delete",
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: onBg, fontSize: 18),
            decoration: InputDecoration(
              labelText: "Amount",
              labelStyle: TextStyle(color: onBg.withOpacity(0.5)),
              prefixIcon: Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  currencySymbol,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onBg.withOpacity(0.5)),
                ),
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<RecurrenceFrequency>(
            value: _frequency,
            dropdownColor: theme.cardColor,
            decoration: InputDecoration(
              labelText: "Frequency",
              labelStyle: TextStyle(color: onBg.withOpacity(0.5)),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: RecurrenceFrequency.values.map((freq) {
              return DropdownMenuItem(
                value: freq,
                child: Text(freq.name[0].toUpperCase() + freq.name.substring(1), style: TextStyle(color: onBg)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _frequency = val);
            },
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: onBg.withOpacity(0.5)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Next Due Date", style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 12)),
                      Text(DateFormat('MMM d, y').format(_nextDate), style: TextStyle(color: onBg, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _nextDate = picked);
  }

  Future<void> _saveChanges() async {
    final isar = DatabaseService().syncDb;
    final newAmount = double.tryParse(_amountCtrl.text) ?? widget.pattern.amount;
    await isar.writeTxn(() async {
      widget.pattern.amount = newAmount;
      widget.pattern.frequency = _frequency;
      widget.pattern.nextDueDate = _nextDate;
      await isar.recurringPatterns.put(widget.pattern);
    });
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deletePattern() async {
    final isar = DatabaseService().syncDb;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Stop Subscription?"),
        content: const Text("This removes the rule. Past transactions are safe."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Stop", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await isar.writeTxn(() async {
        await isar.recurringPatterns.delete(widget.pattern.id);
      });
      if (mounted) Navigator.pop(context);
    }
  }
}
