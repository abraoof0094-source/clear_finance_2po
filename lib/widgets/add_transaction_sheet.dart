import 'dart:ui';
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
    _selectedBucket = null;

    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _rawAmount = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.date;
      _selectedBucket = tx.categoryBucket;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectedCategory = _findCategoryFromTx(tx);
        if (mounted) setState(() {});
      });
    }
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
            // ─── 1. HEADER (Compacted) ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    isEditing ? 'Edit Transaction' : 'New Transaction',
                    style: TextStyle(color: onBg, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const Spacer(),
                  // HELP BUTTON ADDED HERE
                  IconButton(
                    icon: Icon(Icons.help_outline_rounded, color: onBg.withOpacity(0.5), size: 22),
                    onPressed: _showStylishHelpDialog,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: onBg.withOpacity(0.05),
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    tooltip: "How to use",
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: onBg.withOpacity(0.5), size: 22),
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

            // ─── 2. SCROLLABLE CONTENT ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // INPUTS SECTION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Amount Box
                          _GlassContainer(
                            height: 72,
                            radius: 20,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(symbol, style: TextStyle(color: onBg.withOpacity(0.6), fontSize: 24, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  Text(
                                    _rawAmount.isEmpty ? '0' : _rawAmount,
                                    style: TextStyle(color: onBg, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // RECTANGULAR INPUTS
                          Row(
                            children: [
                              // DATE RECTANGLE
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    final newDate = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (newDate != null) setState(() => _selectedDate = newDate);
                                  },
                                  child: _GlassContainer(
                                    height: 48,
                                    radius: 14,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 14, color: theme.colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            DateTime.now().difference(_selectedDate).inDays == 0 && _selectedDate.day == DateTime.now().day
                                                ? 'Today'
                                                : DateFormat('MMM d').format(_selectedDate),
                                            style: TextStyle(color: onBg, fontSize: 13, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // NOTE RECTANGLE
                              Expanded(
                                flex: 1,
                                child: _GlassContainer(
                                  height: 48,
                                  radius: 14,
                                  padding: EdgeInsets.zero,
                                  child: TextField(
                                    controller: _noteController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(color: onBg, fontSize: 13, fontWeight: FontWeight.w500),
                                    cursorColor: theme.colorScheme.primary,
                                    decoration: InputDecoration(
                                      hintText: 'Add note...',
                                      hintStyle: TextStyle(color: onBg.withOpacity(0.3), fontSize: 13),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Selected Category Chip
                    if (_selectedCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_selectedCategory!.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(_selectedCategory!.name, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(() { _selectedCategory = null; _selectedBucket = null; }),
                                child: Icon(Icons.cancel, color: theme.colorScheme.primary.withOpacity(0.5), size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ─── 3. GROUPS & FAVORITES ───
                    const SizedBox(height: 20),

                    if (_selectedCategory == null) ...[
                      _SectionDivider(title: "GROUPS"),

                      // Compacted Groups Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: widget.allowedBuckets.take(5).map((b) {
                            final isSelected = _selectedBucket == b;
                            Color activeColor = _getColorForBucket(b);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() { _selectedBucket = b; _openCategoryPickerForSnappyFlow(); });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 38, height: 32,
                                        decoration: BoxDecoration(
                                          color: isSelected ? activeColor.withOpacity(0.15) : theme.cardColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: isSelected ? activeColor : onBg.withOpacity(0.05),
                                              width: isSelected ? 1.5 : 1
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(_getBucketIcon(b), style: const TextStyle(fontSize: 16)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getBucketShortLabel(b),
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: isSelected ? activeColor : onBg.withOpacity(0.5),
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500
                                        ),
                                        maxLines: 1,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 4),
                      _SectionDivider(title: "FAVORITES"),

                      _FixedGridQuickAccess(
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

            // ─── 4. FIXED NUMPAD ───
            _SlimNumberPad(onKey: _onKeyPressed),

            // Save Button
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
                    ),
                    child: Text(isEditing ? "Update" : "Save", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // DIALOG RESTORED HERE
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
                  color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: onBg.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.lightbulb_outline_rounded, color: theme.colorScheme.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Text("Quick Tips", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBg)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _HelpCard(
                      icon: Icons.touch_app_rounded,
                      color: Colors.blueAccent,
                      title: "Standard Entry",
                      description: "Enter amount, then tap a Group (square icons) to pick a category.",
                    ),
                    const SizedBox(height: 16),
                    _HelpCard(
                      icon: Icons.bolt_rounded,
                      color: Colors.amber,
                      title: "Lightning Save",
                      description: "Tap any Favorite (round icons) to auto-select its group & category instantly.",
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("Awesome, got it!", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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

  // ... (Keep existing logic methods)
  void _quickSave(CategoryModel cat) {
    final amount = double.tryParse(_rawAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter amount first!"), duration: Duration(milliseconds: 600)));
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
      builder: (_) => _CategoryPickerSheet(bucket: _selectedBucket!),
    );
    if (selected != null) setState(() => _selectedCategory = selected);
  }

  void _saveManually() {
    final amount = double.tryParse(_rawAmount);
    if (_selectedCategory != null && amount != null) _finalizeSave(_selectedBucket!, _selectedCategory!, amount);
  }

  void _finalizeSave(CategoryBucket bucket, CategoryModel cat, double amount) {
    final isEditing = widget.transactionToEdit != null;
    TransactionType type = TransactionType.expense;
    if (bucket == CategoryBucket.income) type = TransactionType.income;
    if (bucket == CategoryBucket.invest) type = TransactionType.investment;

    final tx = TransactionModel(
      id: isEditing ? widget.transactionToEdit!.id : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      amount: amount,
      type: type,
      categoryId: cat.id,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      categoryBucket: bucket,
    );

    widget.onSave(tx, isEditing: isEditing);
    Navigator.pop(context);
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'back') {
        if (_rawAmount.isNotEmpty) _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
      } else if (key == 'clear') _rawAmount = '';
      else if (key == '.') { if (!_rawAmount.contains('.')) _rawAmount = _rawAmount.isEmpty ? '0.' : '$_rawAmount.'; }
      else { if (_rawAmount.length < 9) { if (_rawAmount == '0') _rawAmount = key; else _rawAmount += key; } }
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
}

// ───────── FAVORITES GRID (CIRCULAR GOLDEN) ─────────
class _FixedGridQuickAccess extends StatelessWidget {
  final Function(CategoryModel) onSelect;
  const _FixedGridQuickAccess({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    List<CategoryModel> list = provider.categories.where((c) => c.isPinned).toList();
    final displayList = list.take(8).toList();

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text("No favorites pinned", style: TextStyle(color: onBg.withOpacity(0.3), fontSize: 11))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final cat = displayList[index];
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // CIRCULAR GOLDEN ICON
                Container(
                  width: 44, height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle, // Circular shape
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4), // Golden border
                      width: 1.5,
                    ),
                  ),
                  child: Text(cat.icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    cat.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, color: onBg.withOpacity(0.7), fontWeight: FontWeight.w600, height: 1.1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ───────── HELP CARD WIDGET ─────────
class _HelpCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _HelpCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onBg.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: onBg)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: onBg.withOpacity(0.7), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────── GLASS CONTAINER ─────────
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const _GlassContainer({
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.4),
                width: 1.5
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ───────── COMPACT NUMPAD ─────────
class _SlimNumberPad extends StatelessWidget {
  final void Function(String) onKey;
  const _SlimNumberPad({required this.onKey});
  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(0, 4, 0, MediaQuery.of(context).padding.bottom + 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 46
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          return InkWell(
            onTap: () => onKey(key),
            borderRadius: BorderRadius.circular(24),
            child: Center(
                child: key == 'back'
                    ? Icon(Icons.backspace_outlined, color: onBg.withOpacity(0.5), size: 22)
                    : Text(key, style: TextStyle(color: onBg, fontSize: 24, fontWeight: FontWeight.w400))
            ),
          );
        },
      ),
    );
  }
}

// ───────── SECTION DIVIDER ─────────
class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});
  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Divider(color: onBg.withOpacity(0.08), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
                title,
                style: TextStyle(color: onBg.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)
            ),
          ),
          Expanded(child: Divider(color: onBg.withOpacity(0.08), thickness: 1)),
        ],
      ),
    );
  }
}

// (Keep _CategoryPickerSheet same, just ensure it uses correct bucket logic)
class _CategoryPickerSheet extends StatelessWidget {
  final CategoryBucket bucket;
  const _CategoryPickerSheet({required this.bucket});
  // ... (Same implementation as provided previously)
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final categories = provider.categories.where((c) => c.bucket == bucket).toList();
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: onBg.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Text('Select Category', style: TextStyle(color: onBg, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Text(cat.icon, style: const TextStyle(fontSize: 24)),
                    title: Text(cat.name, style: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  if (newCat != null && context.mounted) Navigator.pop(context, newCat);
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
