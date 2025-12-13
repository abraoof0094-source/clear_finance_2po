import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../screens/settings/categories_screen.dart';

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
  CategoryBucket? _selectedBucket;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _rawAmount = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.date;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadCategory(tx.categoryName, tx.categoryBucket);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionToEdit != null;
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── MAIN FORM CARD ───
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8 + MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(isEditing, onBg),
                      const SizedBox(height: 16),

                      // 1. Bucket Selector (Wrapped, no scroll)
                      _BucketSelector(
                        selectedBucket: _selectedBucket,
                        allowedBuckets: widget.allowedBuckets,
                        onBucketSelected: (bucket) async {
                          setState(() {
                            _selectedBucket = bucket;
                            _selectedCategory = null;
                          });
                          await _pickCategory();
                        },
                      ),

                      const SizedBox(height: 20),

                      // 2. UNIFIED INPUT CARD (Category + Amount)
                      Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: onBg.withOpacity(0.05)),
                        ),
                        child: Column(
                          children: [
                            // Top Half: Category
                            _SelectedCategoryRow(
                              bucket: _selectedBucket,
                              selectedCategory: _selectedCategory,
                              onTap: _pickCategory,
                            ),

                            Divider(height: 1, color: onBg.withOpacity(0.08)),

                            // Bottom Half: Amount
                            _AmountDisplay(rawAmount: _rawAmount),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Date + Note Row
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _DateField(
                              date: _selectedDate,
                              onDateChanged: (d) => setState(() => _selectedDate = d),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: _NoteField(controller: _noteController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canSave() ? _saveTransaction : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Save Changes' : 'Add Transaction',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // ─── SLIMMER KEYPAD ───
            _SlimNumberPad(onKey: _onKeyPressed),
          ],
        ),
      ),
    );
  }

  // ... (Logic methods: _buildHeader, _onKeyPressed, _canSave, _preloadCategory, _pickCategory, _saveTransaction, _transactionTypeForBucket - remain same)

  Widget _buildHeader(bool isEditing, Color onBg) {
    return Row(
      children: [
        Text(
          isEditing ? 'Edit Transaction' : 'New Transaction',
          style: TextStyle(color: onBg, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.close, color: onBg.withOpacity(0.6)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'back') {
        if (_rawAmount.isNotEmpty) _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
      } else if (key == 'clear') {
        _rawAmount = '';
      } else if (key == '.') {
        if (!_rawAmount.contains('.')) _rawAmount = _rawAmount.isEmpty ? '0.' : '$_rawAmount.';
      } else {
        if (_rawAmount == '0') _rawAmount = key;
        else _rawAmount += key;
      }
    });
  }

  bool _canSave() {
    final amount = double.tryParse(_rawAmount);
    return amount != null && amount > 0 && _selectedBucket != null && _selectedCategory != null;
  }

  void _preloadCategory(String categoryName, CategoryBucket storedBucket) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final matches = provider.categories.where((c) => c.name.toLowerCase() == categoryName.toLowerCase());

    if (matches.isNotEmpty) {
      final cat = matches.first;
      setState(() {
        _selectedBucket = cat.bucket;
        _selectedCategory = cat;
      });
      return;
    }
    setState(() => _selectedBucket = storedBucket);
  }

  Future<void> _pickCategory() async {
    if (_selectedBucket == null) return;
    final selected = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryPickerSheet(bucket: _selectedBucket!),
    );
    if (selected != null) setState(() => _selectedCategory = selected);
  }

  void _saveTransaction() {
    final isEditing = widget.transactionToEdit != null;
    final amount = double.parse(_rawAmount);
    final bucket = _selectedBucket!;
    final type = _transactionTypeForBucket(bucket);

    final tx = TransactionModel(
      id: isEditing ? widget.transactionToEdit!.id : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      amount: amount,
      type: type,
      categoryId: _selectedCategory?.id,
      categoryName: _selectedCategory!.name,
      categoryIcon: _selectedCategory!.icon,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      categoryBucket: bucket,
    );

    widget.onSave(tx, isEditing: isEditing);
    if (mounted) Navigator.pop(context);
  }

  TransactionType _transactionTypeForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.income: return TransactionType.income;
      case CategoryBucket.invest: return TransactionType.investment;
      default: return TransactionType.expense;
    }
  }
}

// ───────── Bucket Selector (Wrapped Pills) ─────────
class _BucketSelector extends StatelessWidget {
  final CategoryBucket? selectedBucket;
  final void Function(CategoryBucket) onBucketSelected;
  final List<CategoryBucket> allowedBuckets;

  const _BucketSelector({required this.selectedBucket, required this.onBucketSelected, required this.allowedBuckets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final allOptions = [
      _BucketOption('Income', '💵', CategoryBucket.income),
      _BucketOption('Expense', '💳', CategoryBucket.expense),
      _BucketOption('Invest', '🟢', CategoryBucket.invest),
      _BucketOption('Liability', '⚖️', CategoryBucket.liability),
      _BucketOption('Goal', '🎯', CategoryBucket.goal),
    ];
    final options = allOptions.where((o) => allowedBuckets.contains(o.bucket)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Transaction Type', style: TextStyle(color: onBg.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: options.map((o) {
              final isSelected = selectedBucket == o.bucket;
              return GestureDetector(
                onTap: () => onBucketSelected(o.bucket),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.15) : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3B82F6) : onBg.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(o.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(o.label, style: TextStyle(color: isSelected ? onBg : onBg.withOpacity(0.7), fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
class _BucketOption {
  final String label;
  final String icon;
  final CategoryBucket bucket;
  _BucketOption(this.label, this.icon, this.bucket);
}

// ───────── Category Row (Part of Unified Card) ─────────
class _SelectedCategoryRow extends StatelessWidget {
  final CategoryBucket? bucket;
  final CategoryModel? selectedCategory;
  final VoidCallback onTap;

  const _SelectedCategoryRow({required this.bucket, required this.selectedCategory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final hasCategory = selectedCategory != null;

    return InkWell(
      onTap: bucket == null ? null : onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
              child: Icon(Icons.category_rounded, color: bucket == null ? onBg.withOpacity(0.4) : const Color(0xFF3B82F6), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category", style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    bucket == null ? 'Select type above' : (hasCategory ? '${selectedCategory!.icon} ${selectedCategory!.name}' : 'Tap to choose'),
                    style: TextStyle(color: bucket == null ? onBg.withOpacity(0.4) : onBg.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: onBg.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }
}

// ───────── Amount Display (Part of Unified Card) ─────────
class _AmountDisplay extends StatelessWidget {
  final String rawAmount;
  const _AmountDisplay({required this.rawAmount});

  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    final display = rawAmount.isEmpty ? '0' : rawAmount;
    final symbol = context.watch<PreferencesProvider>().currencySymbol;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(symbol, style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 28, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(display, style: TextStyle(color: onBg, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
        ],
      ),
    );
  }
}

// ───────── Date Field ─────────
class _DateField extends StatelessWidget {
  final DateTime date;
  final void Function(DateTime) onDateChanged;
  const _DateField({required this.date, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () async {
        final newDate = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (newDate != null) onDateChanged(newDate);
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, color: onBg.withOpacity(0.6), size: 16),
            const SizedBox(width: 8),
            Text(DateFormat('MMM d').format(date), style: TextStyle(color: onBg, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ───────── Note Field ─────────
class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        style: TextStyle(color: onBg, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Note...',
          hintStyle: TextStyle(color: onBg.withOpacity(0.4), fontSize: 14),
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
        ),
      ),
    );
  }
}

// ───────── Slim Keypad ─────────
class _SlimNumberPad extends StatelessWidget {
  final void Function(String) onKey;
  const _SlimNumberPad({required this.onKey});

  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 48, // Slimmer buttons (was 56 or 64)
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          return InkWell(
            onTap: () => onKey(key),
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: key == 'back'
                  ? Icon(Icons.backspace_rounded, color: onBg.withOpacity(0.7), size: 20)
                  : Text(key, style: TextStyle(color: onBg, fontSize: 22, fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }
}

// ───────── Category Picker Sheet (Unchanged) ─────────
class _CategoryPickerSheet extends StatelessWidget {
  final CategoryBucket bucket;
  const _CategoryPickerSheet({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final categories = provider.categories.where((c) => c.bucket == bucket).toList();
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: onBg.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Text('Choose Category', style: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              Padding(padding: const EdgeInsets.all(32), child: Text('No categories found', style: TextStyle(color: onBg.withOpacity(0.5))))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => Divider(height: 1, indent: 60, color: onBg.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return ListTile(
                      leading: Text(cat.icon, style: const TextStyle(fontSize: 22)),
                      title: Text(cat.name, style: TextStyle(color: onBg, fontSize: 15)),
                      onTap: () => Navigator.pop(context, cat),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () async {
                  final newCat = await CategoriesScreen.addCategoryForBucket(context, bucket);
                  if (newCat != null) Navigator.pop(context, newCat);
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text("Create New Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
