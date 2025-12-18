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

class _AddTransactionSheetState extends State<AddTransactionSheet>
    with TickerProviderStateMixin {
  String _rawAmount = '';
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  CategoryBucket? _selectedBucket;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool _isRecurring = false;
  bool _isNamingRecurring = false;
  RecurrenceFrequency _recurrenceFreq = RecurrenceFrequency.monthly;
  int? _existingRuleId;
  RecurringPattern? _softMatchedPattern;

  late AnimationController _amountController;
  late Animation<double> _amountScale;

  @override
  void initState() {
    super.initState();
    _amountController =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _amountScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _amountController, curve: Curves.elasticOut),
    );

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
    _amountController.dispose();
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
        _softMatchedPattern = rule;
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
      final match =
      patterns.firstWhere((p) => (p.amount - tx.amount).abs() < 0.1);
      if (mounted) {
        setState(() {
          _isRecurring = true;
          _recurrenceFreq = match.frequency;
          _existingRuleId = match.id;
          _softMatchedPattern = match;
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

  Future<void> _trySoftMatchForCurrentSelection() async {
    if (_selectedCategory == null) return;
    final amount = double.tryParse(_rawAmount);
    if (amount == null || amount <= 0) return;

    final isar = DatabaseService().syncDb;
    final patterns = await isar.recurringPatterns
        .filter()
        .isActiveEqualTo(true)
        .categoryIdEqualTo(_selectedCategory!.id)
        .findAll();

    if (patterns.isEmpty) {
      if (mounted) setState(() => _softMatchedPattern = null);
      return;
    }

    RecurringPattern? match;
    try {
      match = patterns.firstWhere((p) => (p.amount - amount).abs() < 1.0);
    } catch (_) {
      match = null;
    }

    if (!mounted) return;
    setState(() {
      _softMatchedPattern = match;
      if (match != null) {
        _isRecurring = true;
        _recurrenceFreq = match.frequency;
        _existingRuleId = match.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final isEditing = widget.transactionToEdit != null;
    final symbol = context.watch<PreferencesProvider>().currencySymbol;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
              child: Row(
                children: [
                  Row(
                    children: [
                      Text(
                        isEditing ? 'Edit' : 'Add',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Transaction',
                        style: TextStyle(
                          color: onBg.withOpacity(0.7),
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: onBg.withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: () => _showHelpDialog(theme, onBg),
                    style: IconButton.styleFrom(
                      backgroundColor: onBg.withOpacity(0.05),
                      fixedSize: const Size(40, 40),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: onBg.withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: onBg.withOpacity(0.05),
                      fixedSize: const Size(40, 40),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: onBg.withOpacity(0.08),
            ),

            // CATEGORY ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SizedBox(
                height: 74,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: widget.allowedBuckets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final bucket = widget.allowedBuckets[index];
                    return _buildPremiumBucketButton(theme, onBg, bucket);
                  },
                ),
              ),
            ),

            // META ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: _buildCleanMetaRow(theme, onBg),
            ),

            // AMOUNT DISPLAY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ScaleTransition(
                scale: _amountScale,
                child: _buildCompactAmountDisplay(theme, onBg, symbol),
              ),
            ),

            // QUICK ACCESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: _buildCleanQuickAccess(theme, onBg),
            ),

            // NUMPAD
            Expanded(
              child: SlimNumberPad(onKey: _onKeyPressed),
            ),

            // ACTION BUTTON
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
                child: _buildPremiumActionButton(theme, isEditing),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBucketButton(
      ThemeData theme, Color onBg, CategoryBucket bucket) {
    final isSelected = _selectedBucket == bucket;
    final color = _getColorForBucket(bucket);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedBucket = bucket);
        _openCategoryPickerForSnappyFlow();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 68,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : onBg.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : onBg.withOpacity(0.08),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 280),
                scale: isSelected ? 1.15 : 1.0,
                child: Text(
                  _getBucketIcon(bucket),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getBucketShortLabel(bucket),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : onBg.withOpacity(0.65),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanMetaRow(ThemeData theme, Color onBg) {
    return Row(
      children: [
        // Date picker
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (newDate != null) {
                setState(() => _selectedDate = newDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              decoration: BoxDecoration(
                color: onBg.withOpacity(0.035),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: onBg.withOpacity(0.08), width: 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: onBg.withOpacity(0.85),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Recurring toggle
        GestureDetector(
          onTap: () {
            if (_isRecurring) {
              setState(() => _isRecurring = false);
            } else {
              setState(() => _isNamingRecurring = true);
              _showRecurrencePicker();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: _isRecurring
                  ? Colors.blueAccent.withOpacity(0.12)
                  : onBg.withOpacity(0.035),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRecurring
                    ? Colors.blueAccent.withOpacity(0.35)
                    : onBg.withOpacity(0.08),
                width: _isRecurring ? 1.4 : 1.2,
              ),
              boxShadow: _isRecurring
                  ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.repeat_rounded,
                    size: 16,
                    color: _isRecurring
                        ? Colors.blueAccent
                        : onBg.withOpacity(0.55)),
                const SizedBox(height: 2),
                Text(
                  _recurrenceFreq.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _isRecurring
                        ? Colors.blueAccent
                        : onBg.withOpacity(0.55),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Note field
        Expanded(
          flex: 2,
          child: TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            maxLines: 1,
            style: TextStyle(
              color: onBg,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            cursorColor: Theme.of(context).colorScheme.primary,
            cursorWidth: 2,
            decoration: InputDecoration(
              hintText:
              _isNamingRecurring ? 'Name this transaction' : 'Add note...',
              hintStyle: TextStyle(
                color: onBg.withOpacity(0.42),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: onBg.withOpacity(0.08), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isNamingRecurring
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : onBg.withOpacity(0.08),
                  width: _isNamingRecurring ? 2 : 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    width: 1.5),
              ),
              filled: true,
              fillColor: _isNamingRecurring
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : onBg.withOpacity(0.025),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactAmountDisplay(
      ThemeData theme, Color onBg, String symbol) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.12),
                theme.colorScheme.primary.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    color: onBg.withOpacity(0.65),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _rawAmount.isEmpty ? '0' : _rawAmount,
                  style: TextStyle(
                    color: onBg,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanQuickAccess(ThemeData theme, Color onBg) {
    final provider = Provider.of<FinanceProvider>(context);
    final list = provider.categories.where((c) => c.isPinned).toList();
    final displayList = list.take(6).toList();

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            "No favorites pinned",
            style: TextStyle(
              color: onBg.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: onBg.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(2, (row) {
          final rowItems = displayList.skip(row * 3).take(3).toList();
          if (rowItems.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              if (row == 1)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: onBg.withOpacity(0.06),
                ),
              SizedBox(
                height: 70,
                child: Row(
                  children: List.generate(3, (col) {
                    CategoryModel? cat;
                    if (col < rowItems.length) cat = rowItems[col];

                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: col < 2
                                ? BorderSide(
                              color: onBg.withOpacity(0.05),
                              width: 0.8,
                            )
                                : BorderSide.none,
                          ),
                        ),
                        child: cat == null
                            ? const SizedBox.shrink()
                            : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _quickSave(cat!),
                            borderRadius: BorderRadius.zero,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat.icon,
                                    style: const TextStyle(
                                      fontSize: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Text(
                                      cat.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: onBg.withOpacity(0.85),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPremiumActionButton(ThemeData theme, bool isEditing) {
    final amount = double.tryParse(_rawAmount);
    final canSave = amount != null && amount > 0 && _selectedCategory != null;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSave
              ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canSave ? _saveManually : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: canSave
                    ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.4),
                    theme.colorScheme.primary.withOpacity(0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  isEditing ? 'Update Transaction' : 'Save Transaction',
                  style: TextStyle(
                    color: canSave ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(ThemeData theme, Color onBg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quick Guide',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: onBg,
            letterSpacing: -0.3,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              '📁 Category',
              'Select Income, Expense, Invest, Liability, or Goal bucket.',
              theme,
              onBg,
            ),
            _buildHelpItem(
              '🔢 Amount',
              'Use keypad to enter transaction amount. You can use decimals.',
              theme,
              onBg,
            ),
            _buildHelpItem(
              '📅 Date & Repeat',
              'Set transaction date and mark as recurring if needed.',
              theme,
              onBg,
            ),
            _buildHelpItem(
              '💬 Note',
              'Optional: Add details to remember what this transaction was for.',
              theme,
              onBg,
            ),
            _buildHelpItem(
              '⚡ Quick Save',
              'Tap any pinned category below to instantly save and create more.',
              theme,
              onBg,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Got it',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
      String title, String subtitle, ThemeData theme, Color onBg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: onBg,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: onBg.withOpacity(0.65),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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

    // 1) NEW OR UPDATED RECURRING RULE → "Created subscription..."
    if (_isRecurring && _softMatchedPattern == null) {
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
        ..nextDueDate =
        finance.calculateNextDate(_selectedDate, _recurrenceFreq)
        ..isActive = true
        ..autoLog = true;

      await finance.addRecurringPattern(pattern);
      finalRecurringRuleId = pattern.id;

      finance.setRecurringMatchMessage(
        'Created subscription: ${pattern.name} (₹${pattern.amount.toStringAsFixed(0)}/mo)',
      );

      finance.addSystemNotification(
        title: 'Subscription created',
        message:
        '${pattern.name} (₹${pattern.amount.toStringAsFixed(0)}/mo) was added.',
      );
    }

    // 2) SOFT MATCH TO EXISTING RULE → "Matched subscription..."
    else if (_isRecurring && _softMatchedPattern != null) {
      final pattern = _softMatchedPattern!;
      finalRecurringRuleId = pattern.id;

      finance.setRecurringMatchMessage(
        'Matched subscription: ${pattern.name} (₹${pattern.amount.toStringAsFixed(0)}/mo)',
      );

      finance.addSystemNotification(
        title: 'Subscription matched',
        message:
        '${pattern.name} (₹${pattern.amount.toStringAsFixed(0)}/mo) matched this transaction.',
      );
    }

    // 3) Recurring turned off for an existing rule
    else if (!_isRecurring && _existingRuleId != null) {
      await finance.deleteRecurringPattern(_existingRuleId!);
      finalRecurringRuleId = null;
      finance.setRecurringMatchMessage(null);
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

    setState(() {
      _isNamingRecurring = false;
    });

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
          content: Text("Enter amount first! 💰"),
          duration: Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
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
      setState(() {
        _selectedCategory = selected;
      });
      await _trySoftMatchForCurrentSelection();
    }
  }

  void _showRecurrencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final onBg = theme.colorScheme.onSurface;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.95),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Repeat Every",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: onBg,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...RecurrenceFrequency.values.map((freq) {
                    final name =
                        freq.name[0].toUpperCase() + freq.name.substring(1);
                    final isSelected = _recurrenceFreq == freq;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : onBg.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : onBg.withOpacity(0.08),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Icon(Icons.repeat_rounded,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : onBg.withOpacity(0.6)),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : onBg,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _recurrenceFreq = freq;
                            _isRecurring = true;
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
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

    if (_rawAmount.isNotEmpty && _rawAmount.length == 1) {
      _amountController.forward(from: 0.0);
    }

    if (_selectedCategory != null) {
      _trySoftMatchForCurrentSelection();
    }
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
}
