import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import '../providers/finance_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_pattern.dart';
import '../services/database_service.dart';

import 'add_transaction_widgets.dart';

class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  final void Function(TransactionModel tx, {required bool isEditing}) onSave;
  final List<CategoryBucket> allowedBuckets;

  const AddTransactionSheet({
    super.key,
    this.transactionToEdit,
    required this.onSave,
    required this.allowedBuckets,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  String _rawAmount = '';
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  CategoryBucket? _selectedBucket;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool _isRecurring = false;
  RecurrenceFrequency _recurrenceFreq = RecurrenceFrequency.monthly;
  int? _existingRuleId;

  @override
  void initState() {
    super.initState();
    _selectedBucket = null;

    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _rawAmount = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.date;
      _selectedBucket = tx.categoryBucket;
      _existingRuleId = tx.recurringRuleId;

      if (tx.recurringRuleId != null) {
        _isRecurring = true;
        _fetchExistingRule(tx.recurringRuleId!);
      } else {
        _checkForMatchingRule(tx);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectedCategory = _findCategoryFromTx(tx);
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingRule(int ruleId) async {
    final isar = DatabaseService().syncDb;
    final rule = await isar.recurringPatterns.get(ruleId);
    if (rule != null && mounted) {
      setState(() {
        _recurrenceFreq = rule.frequency;
      });
    }
  }

  Future<void> _checkForMatchingRule(TransactionModel tx) async {
    if (tx.categoryId == null) return;
    final isar = DatabaseService().syncDb;
    final patterns = await isar.recurringPatterns
        .filter()
        .isActiveEqualTo(true)
        .categoryIdEqualTo(tx.categoryId!)
        .findAll();

    if (patterns.isEmpty) return;
    try {
      final match = patterns.firstWhere(
            (p) => (p.amount - tx.amount).abs() < 0.1,
      );
      if (mounted) {
        setState(() {
          _isRecurring = true;
          _recurrenceFreq = match.frequency;
          _existingRuleId = match.id;
        });
      }
    } catch (_) {}
  }

  CategoryModel? _findCategoryFromTx(TransactionModel tx) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    try {
      return provider.categories.firstWhere((c) => c.id == tx.categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final isEditing = widget.transactionToEdit != null;
    final symbol = context.watch<PreferencesProvider>().currencySymbol;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    isEditing ? 'Edit Transaction' : 'New Transaction',
                    style: TextStyle(
                      color: onBg,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.help_outline_rounded,
                        color: onBg.withOpacity(0.5), size: 22),
                    onPressed: _showStylishHelpDialog,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: onBg.withOpacity(0.05),
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: onBg.withOpacity(0.5), size: 22),
                    onPressed: () => Navigator.pop(context),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: onBg.withOpacity(0.05),
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          GlassContainer(
                            height: 72,
                            radius: 20,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    symbol,
                                    style: TextStyle(
                                      color: onBg.withOpacity(0.6),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _rawAmount.isEmpty ? '0' : _rawAmount,
                                    style: TextStyle(
                                      color: onBg,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_isRecurring) {
                                    setState(() => _isRecurring = false);
                                  } else {
                                    _showRecurrencePicker();
                                  }
                                },
                                onLongPress: _isRecurring ? _showRecurrencePicker : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 54,
                                  width: 54,
                                  decoration: BoxDecoration(
                                    color: _isRecurring
                                        ? theme.colorScheme.primary.withOpacity(0.2)
                                        : (theme.brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.white.withOpacity(0.6)),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _isRecurring
                                          ? theme.colorScheme.primary
                                          : (theme.brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.12)
                                          : Colors.white.withOpacity(0.4)),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.repeat_rounded,
                                      size: 24,
                                      color: _isRecurring
                                          ? theme.colorScheme.primary
                                          : onBg.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              GestureDetector(
                                onTap: () async {
                                  final newDate = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (newDate != null) setState(() => _selectedDate = newDate);
                                },
                                child: GlassContainer(
                                  height: 54,
                                  width: 54,
                                  radius: 14,
                                  padding: EdgeInsets.zero,
                                  child: Center(
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 22,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

// 3. NOTE FIELD
                              Expanded(
                                child: GlassContainer(
                                  height: 54,
                                  radius: 14,
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // 🔸 Slight tint + border when recurring
                                      color: _isRecurring
                                          ? theme.colorScheme.primary.withOpacity(0.06)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _isRecurring
                                            ? theme.colorScheme.primary.withOpacity(0.7)
                                            : Colors.transparent,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _noteController,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(
                                        color: onBg,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      cursorColor: theme.colorScheme.primary,
                                      decoration: InputDecoration(
                                        hintText: _isRecurring
                                            ? 'Name this recurring transaction (e.g. Netflix, House Rent)'
                                            : 'Add note...',
                                        hintStyle: TextStyle(
                                          color: _isRecurring
                                              ? theme.colorScheme.primary.withOpacity(0.7)
                                              : onBg.withOpacity(0.3),
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_isRecurring || !isDateToday(_selectedDate))
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Row(
                                children: [
                                  if (_isRecurring)
                                    GestureDetector(
                                      onTap: _showRecurrencePicker,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.sync,
                                                size: 10,
                                                color: theme.colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Repeats ${_recurrenceFreq.name.toLowerCase()}",
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (_isRecurring && !isDateToday(_selectedDate))
                                    const SizedBox(width: 8),
                                  if (!isDateToday(_selectedDate))
                                    Text(
                                      DateFormat('MMM d, y').format(_selectedDate),
                                      style: TextStyle(
                                        color: onBg.withOpacity(0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (_selectedCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_selectedCategory!.icon,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCategory!.name,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = null;
                                    _selectedBucket = null;
                                  });
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    if (_selectedCategory == null) ...[
                      const SectionDivider(title: "GROUPS"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: widget.allowedBuckets.take(5).map((b) {
                            final isSelected = _selectedBucket == b;
                            final activeColor = _getColorForBucket(b);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBucket = b;
                                    _openCategoryPickerForSnappyFlow();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? activeColor.withOpacity(0.15)
                                              : theme.cardColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? activeColor
                                                : onBg.withOpacity(0.05),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _getBucketIcon(b),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getBucketShortLabel(b),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isSelected
                                              ? activeColor
                                              : onBg.withOpacity(0.5),
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FixedGridQuickAccess(
                        onSelect: (cat) {
                          setState(() => _selectedBucket = cat.bucket);
                          _quickSave(cat);
                        },
                      ),
                    ],

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            SlimNumberPad(onKey: _onKeyPressed),

            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSave() ? _saveManually : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
                    ),
                    child: Text(
                      isEditing ? "Update" : "Save",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _finalizeSave(
      CategoryBucket bucket,
      CategoryModel cat,
      double amount,
      ) async {
    final isEditing = widget.transactionToEdit != null;
    final finance = Provider.of<FinanceProvider>(context, listen: false);

    TransactionType type = TransactionType.expense;
    if (bucket == CategoryBucket.income) type = TransactionType.income;
    if (bucket == CategoryBucket.invest) type = TransactionType.investment;

    int? finalRecurringRuleId = _existingRuleId;

    if (_isRecurring) {
      if (_existingRuleId != null) {
        await finance.deleteRecurringPattern(_existingRuleId!);
      }

      final recurringName = _noteController.text.trim().isEmpty
          ? cat.name
          : _noteController.text.trim();

      final pattern = RecurringPattern()
        ..name = recurringName
        ..amount = amount
        ..emoji = cat.icon
        ..categoryId = cat.id
        ..categoryBucket = bucket
        ..startDate = _selectedDate
        ..frequency = _recurrenceFreq
        ..nextDueDate = finance.calculateNextDate(_selectedDate, _recurrenceFreq)
        ..isActive = true
        ..autoLog = true;

      await finance.addRecurringPattern(pattern);
      finalRecurringRuleId = pattern.id;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Recurring rule updated!"),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
    } else if (!_isRecurring && _existingRuleId != null) {
      await finance.deleteRecurringPattern(_existingRuleId!);
      finalRecurringRuleId = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Stopped recurring."),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }

    final tx = TransactionModel(
      id: isEditing
          ? widget.transactionToEdit!.id
          : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      amount: amount,
      type: type,
      categoryId: cat.id,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      categoryBucket: bucket,
      recurringRuleId: finalRecurringRuleId,
    );

    if (isEditing) {
      finance.updateTransaction(tx);
    } else {
      finance.addTransaction(tx);
    }

    widget.onSave(tx, isEditing: isEditing);
    if (mounted) Navigator.pop(context);
  }

  void _saveManually() {
    final amount = double.tryParse(_rawAmount);
    if (_selectedCategory != null && amount != null) {
      _finalizeSave(_selectedBucket!, _selectedCategory!, amount);
    }
  }

  void _quickSave(CategoryModel cat) {
    final amount = double.tryParse(_rawAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter amount first!"),
          duration: Duration(milliseconds: 600),
        ),
      );
      return;
    }
    _finalizeSave(cat.bucket, cat, amount);
  }

  Future<void> _openCategoryPickerForSnappyFlow() async {
    if (_selectedBucket == null) return;
    final selected = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(bucket: _selectedBucket!),
    );
    if (selected != null) {
      setState(() => _selectedCategory = selected);
    }
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'back') {
        if (_rawAmount.isNotEmpty) {
          _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
        }
      } else if (key == 'clear') {
        _rawAmount = '';
      } else if (key == '.') {
        if (!_rawAmount.contains('.')) {
          _rawAmount = _rawAmount.isEmpty ? '0.' : '$_rawAmount.';
        }
      } else {
        if (_rawAmount.length < 9) {
          if (_rawAmount == '0') {
            _rawAmount = key;
          } else {
            _rawAmount += key;
          }
        }
      }
    });
  }

  bool _canSave() {
    final amount = double.tryParse(_rawAmount);
    return amount != null && amount > 0 && _selectedCategory != null;
  }

  Color _getColorForBucket(CategoryBucket b) {
    if (b == CategoryBucket.income) return Colors.green;
    if (b == CategoryBucket.expense) return Colors.redAccent;
    if (b == CategoryBucket.invest) return Colors.purpleAccent;
    if (b == CategoryBucket.goal) return Colors.orange;
    return Colors.blue;
  }

  String _getBucketShortLabel(CategoryBucket b) {
    final str = b.toString().split('.').last;
    return str[0].toUpperCase() + str.substring(1);
  }

  String _getBucketIcon(CategoryBucket b) {
    if (b == CategoryBucket.income) return '💰';
    if (b == CategoryBucket.expense) return '💸';
    if (b == CategoryBucket.invest) return '📈';
    if (b == CategoryBucket.liability) return '🏦';
    if (b == CategoryBucket.goal) return '🎯';
    return '🏷️';
  }

  void _showRecurrencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final onBg = theme.colorScheme.onSurface;
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Repeat Frequency",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onBg),
              ),
              const SizedBox(height: 16),
              ...RecurrenceFrequency.values.map((freq) {
                final name = freq.name[0].toUpperCase() + freq.name.substring(1);
                final isSelected = _recurrenceFreq == freq;
                return ListTile(
                  leading: const Icon(Icons.update),
                  title: Text(name),
                  onTap: () {
                    setState(() {
                      _recurrenceFreq = freq;
                      _isRecurring = true;
                      // Just let the note prompt appear via build method logic, no keyboard
                    });
                    Navigator.pop(ctx);
                  },
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showStylishHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final onBg = theme.colorScheme.onSurface;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E).withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: onBg.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Row(
                      children: [
                        // icon + title row
                      ],
                    ),
                    SizedBox(height: 24),
                    HelpCard(
                      icon: Icons.touch_app_rounded,
                      color: Colors.blueAccent,
                      title: "Standard Entry",
                      description:
                      "Enter amount, then tap a Group (square icons) to pick a category.",
                    ),
                    SizedBox(height: 16),
                    HelpCard(
                      icon: Icons.bolt_rounded,
                      color: Colors.amber,
                      title: "Lightning Save",
                      description:
                      "Tap any Favorite (round icons) to auto-select its group & category instantly.",
                    ),
                    SizedBox(height: 16),
                    HelpCard(
                      icon: Icons.repeat_rounded,
                      color: Colors.purpleAccent,
                      title: "Recurring",
                      description:
                      "Tap the loop icon to make this transaction repeat automatically.",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
