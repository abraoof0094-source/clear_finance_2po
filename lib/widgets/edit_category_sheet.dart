import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../providers/finance_provider.dart';
import '../models/category_model.dart';

class EditCategorySheet extends StatefulWidget {
  final CategoryModel? category;
  final CategoryBucket initialBucket;

  const EditCategorySheet({
    super.key,
    this.category,
    required this.initialBucket,
  });

  @override
  State<EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<EditCategorySheet> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _mandateController;
  final _formKey = GlobalKey<FormState>();

  late CategoryBucket _bucket;
  late bool _isMandate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconController = TextEditingController(text: widget.category?.icon ?? '📁');
    _mandateController = TextEditingController(
      text: widget.category?.monthlyMandate?.toStringAsFixed(0) ?? '',
    );
    _bucket = widget.category?.bucket ?? widget.initialBucket;
    _isMandate = widget.category?.isMandate ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _mandateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final isEditing = widget.category != null;

    // Get keyboard height (viewInsets) and system nav bar height (viewPadding)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 1. Drag Handle & Header ───
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: onBg.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Text(
                  isEditing ? "Edit Category" : "New Category",
                  style: TextStyle(
                    color: onBg,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: onBg.withOpacity(0.6)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ─── 2. Scrollable Form ───
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon + Name Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _showEmojiPicker,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: onBg.withOpacity(0.12)),
                              ),
                              child: Center(
                                child: Text(
                                  _iconController.text.isEmpty ? '📁' : _iconController.text,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.w500),
                              textCapitalization: TextCapitalization.sentences,
                              decoration: _filledFieldDecoration(
                                context: context,
                                label: 'Category Name',
                                hint: 'e.g., Groceries',
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Bucket Dropdown (Styled as InputDecorator)
                      InputDecorator(
                        decoration: _filledFieldDecoration(
                          context: context,
                          label: 'Type / Bucket',
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CategoryBucket>(
                            value: _bucket,
                            isDense: true,
                            isExpanded: true,
                            dropdownColor: theme.cardColor,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: onBg.withOpacity(0.5)),
                            style: TextStyle(color: onBg, fontSize: 15, fontWeight: FontWeight.w500),
                            items: const [
                              DropdownMenuItem(value: CategoryBucket.expense, child: Text('🔴  Expense')),
                              DropdownMenuItem(value: CategoryBucket.invest, child: Text('🟢  Invest')),
                              DropdownMenuItem(value: CategoryBucket.liability, child: Text('⚖️  Liability')),
                              DropdownMenuItem(value: CategoryBucket.goal, child: Text('🎯  Goal')),
                              DropdownMenuItem(value: CategoryBucket.income, child: Text('💵  Income')),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _bucket = value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8, bottom: 24),
                        child: Text(
                          _helperTextForBucket(_bucket),
                          style: TextStyle(color: onBg.withOpacity(0.5), fontSize: 12),
                        ),
                      ),

                      // Mandate Toggle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: onBg.withOpacity(0.08)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Fixed Monthly Amount?', style: TextStyle(color: onBg, fontSize: 15, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text('For fixed bills like Rent, Netflix, SIPs', style: TextStyle(color: onBg.withOpacity(0.6), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isMandate,
                                  activeColor: const Color(0xFF3B82F6),
                                  onChanged: (v) {
                                    setState(() {
                                      _isMandate = v;
                                      if (!v) _mandateController.clear();
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (_isMandate) ...[
                              const Divider(height: 24),
                              TextFormField(
                                controller: _mandateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(color: onBg, fontSize: 16),
                                decoration: _filledFieldDecoration(
                                  context: context,
                                  label: 'Monthly Amount',
                                  hint: '0.00',
                                  prefix: '₹ ',
                                ),
                                validator: (val) {
                                  if (!_isMandate) return null;
                                  if (val == null || val.isEmpty) return 'Amount required';
                                  if (double.tryParse(val.replaceAll(',', '')) == null) return 'Invalid amount';
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── 3. Action Buttons (Sticky on Keyboard & Safe Area) ───
          Container(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + max(bottomInset, safeBottom)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: onBg.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Category',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  InputDecoration _filledFieldDecoration({
    required BuildContext context,
    required String label,
    String? hint,
    String? prefix,
  }) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: onBg.withOpacity(0.6), fontSize: 14),
      hintText: hint,
      hintStyle: TextStyle(color: onBg.withOpacity(0.3)),
      prefixText: prefix,
      prefixStyle: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
    );
  }

  String _helperTextForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.expense: return "Daily spending: food, travel, shopping.";
      case CategoryBucket.invest: return "Assets: SIPs, stocks, gold, funds.";
      case CategoryBucket.liability: return "Debts: loans, EMIs, credit card bills.";
      case CategoryBucket.goal: return "Targets: vacation, car, wedding savings.";
      case CategoryBucket.income: return "Inflow: salary, bonus, interest.";
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final onBg = theme.colorScheme.onSurface;

        final emojis = [
          '🏠', '🚗', '🍱', '💊', '📱', '⚡', '💳', '🎓', '👨‍👩‍👧', '📈',
          '🏦', '🎯', '💰', '🍽️', '🛍️', '🎬', '✈️', '🎁', '💵', '🏋️',
          '📚', '🎮', '☕', '🍔', '🛒', '⛽', '🏥', '🐶', '👔', '🧹'
        ];

        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: onBg.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text('Choose Icon', style: TextStyle(color: onBg, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _iconController.text = emoji);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Category?', style: TextStyle(color: onBg)),
        content: Text('Transactions will be kept but marked as Uncategorized.', style: TextStyle(color: onBg.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: onBg.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCategory();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final icon = _iconController.text.trim().isEmpty ? '📁' : _iconController.text.trim();

    double? monthlyMandate;
    if (_isMandate && _mandateController.text.isNotEmpty) {
      monthlyMandate = double.tryParse(_mandateController.text.replaceAll(',', ''));
    }

    if (widget.category != null) {
      final updated = widget.category!.copyWith(
        name: name,
        icon: icon,
        bucket: _bucket,
        isMandate: _isMandate,
        monthlyMandate: monthlyMandate,
      );
      provider.updateCategory(updated);
      Navigator.pop(context, updated);
    } else {
      // Safe ID Generation
      final newId = provider.categories.isEmpty
          ? 1000
          : provider.categories.map((c) => c.id).reduce(max) + 1;

      final newCat = CategoryModel(
        id: newId,
        name: name,
        icon: icon,
        bucket: _bucket,
        isDefault: false,
        isMandate: _isMandate,
        monthlyMandate: monthlyMandate,
      );
      provider.addCategory(newCat);
      Navigator.pop(context, newCat);
    }
  }

  void _deleteCategory() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    if (widget.category != null) {
      provider.deleteCategory(widget.category!.id);
      Navigator.pop(context);
    }
  }
}
