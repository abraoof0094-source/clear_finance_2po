import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/finance_provider.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart' as cat;

class AddTransactionDialog extends StatefulWidget {
  // 1. Add parameter to accept transaction for editing
  final model.Transaction? transactionToEdit;

  const AddTransactionDialog({super.key, this.transactionToEdit});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Default: Lifestyle (I want)
  cat.CategoryBucket _selectedBucket = cat.CategoryBucket.lifestyle;
  cat.CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 2. PRE-FILL DATA IF EDITING
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;

      // Set Amount (remove decimals if integer)
      _amountController.text = (tx.amount % 1 == 0)
          ? tx.amount.toInt().toString()
          : tx.amount.toString();

      // Set Note
      _noteController.text = tx.note ?? '';

      // Set Date
      _selectedDate = tx.date;

      // Set Bucket
      // If categoryBucket was saved, use it. Otherwise, try to map from type.
      if (tx.categoryBucket != null) {
        _selectedBucket = tx.categoryBucket!;
      } else {
        // Fallback mapping if legacy data didn't have bucket
        // (You can adjust this fallback logic if needed)
        if (tx.type == model.TransactionType.income) {
          _selectedBucket = cat.CategoryBucket.income;
        } else if (tx.type == model.TransactionType.investment) {
          _selectedBucket = cat.CategoryBucket.futureYou;
        } else {
          _selectedBucket = cat.CategoryBucket.lifestyle;
        }
      }

      // Set Category
      // We try to match the category name/icon with existing categories in provider
      // This is done in addPostFrameCallback to ensure context/provider is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<FinanceProvider>(context, listen: false);
        try {
          final existingCat = provider.categories.firstWhere(
                (c) => c.name == tx.categoryName && c.bucket == _selectedBucket,
            orElse: () => cat.CategoryModel(
              id: 0, // Dummy ID for display
              name: tx.categoryName,
              icon: tx.categoryIcon,
              bucket: _selectedBucket,
            ),
          );
          setState(() {
            _selectedCategory = existingCat;
          });
        } catch (e) {
          // Fallback
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    return amount > 0 && _selectedCategory != null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    final categories = provider.categories
        .where((c) => c.bucket == _selectedBucket)
        .toList();

    // Only auto-select first category if we are ADDING (not editing) and selection is null
    if (widget.transactionToEdit == null && _selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    final bucketLabel = _bucketSummaryLabel(_selectedBucket);
    final isEditing = widget.transactionToEdit != null;

    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // OPTIONAL: Add Title "Edit Transaction" if needed,
              // but your original design didn't have a title, so keeping it clean.

              // --- BUCKET TABS ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBucketTab(
                        'I earn',
                        '💰',
                        cat.CategoryBucket.income,
                      ),
                    ),
                    Expanded(
                      child: _buildBucketTab(
                        'I want',
                        '🎉',
                        cat.CategoryBucket.lifestyle,
                      ),
                    ),
                    Expanded(
                      child: _buildBucketTab(
                        'I need',
                        '🧾',
                        cat.CategoryBucket.essentials,
                      ),
                    ),
                    Expanded(
                      child: _buildBucketTab(
                        'My goal',
                        '🚀',
                        cat.CategoryBucket.futureYou,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // --- AMOUNT LEFT | DATE + NOTE RIGHT ---
              Row(
                children: [
                  // LEFT: Amount
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 80,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    '₹',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      // Only autofocus if Adding new transaction
                                      autofocus: !isEditing,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // RIGHT: Date (top) + Note (bottom)
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 80,
                      child: Column(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) {
                                  setState(() => _selectedDate = d);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020617),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('MMM dd')
                                          .format(_selectedDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: 'Add a note',
                                hintStyle:
                                TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF020617),
                                contentPadding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // --- CATEGORY CHIPS ---
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...categories.map(
                          (catItem) => _buildCategoryChip(
                        icon: catItem.icon,
                        label: catItem.name,
                        isSelected: _selectedCategory?.name == catItem.name, // Match by name just in case ID differs
                        onTap: () =>
                            setState(() => _selectedCategory = catItem),
                      ),
                    ),
                    _buildCategoryChip(
                      icon: '+',
                      label: 'Add',
                      isSelected: false,
                      onTap: () => _showAddCategoryDialog(context, provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSave
                        ? _primaryColorForBucket(_selectedBucket)
                        : _primaryColorForBucket(_selectedBucket)
                        .withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _canSave
                      ? () {
                    final amount =
                        double.tryParse(_amountController.text
                            .trim()) ??
                            0;
                    if (amount <= 0) return;
                    if (_selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select a category"),
                        ),
                      );
                      return;
                    }

                    final model.TransactionType typeEnum =
                    _transactionTypeForBucket(_selectedBucket);

                    final tx = model.Transaction(
                      // Keep ID if editing, else generate new
                      id: isEditing
                          ? widget.transactionToEdit!.id
                          : DateTime.now().millisecondsSinceEpoch,
                      amount: amount,
                      type: typeEnum,
                      categoryName: _selectedCategory!.name,
                      categoryIcon: _selectedCategory!.icon,
                      date: _selectedDate,
                      note: _noteController.text.trim().isEmpty
                          ? null
                          : _noteController.text.trim(),
                      categoryBucket: _selectedCategory!.bucket,
                    );

                    // 4. SAVE OR UPDATE LOGIC
                    if (isEditing) {
                      provider.updateTransaction(tx);
                    } else {
                      provider.addTransaction(tx);
                    }

                    Navigator.pop(context);
                  }
                      : null,
                  child: Text(
                    isEditing ? "Save Changes" : "Save Transaction",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bucketLabel,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS (Unchanged) ---

  Widget _buildBucketTab(
      String label, String emoji, cat.CategoryBucket bucket) {
    final isSelected = _selectedBucket == bucket;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBucket = bucket;
          _selectedCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[500],
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.black26,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? Border.all(color: Colors.white) : null,
          ),
          child: Row(
            children: [
              Text(icon),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _primaryColorForBucket(cat.CategoryBucket bucket) {
    switch (bucket) {
      case cat.CategoryBucket.income:
        return Colors.greenAccent.shade400;
      case cat.CategoryBucket.futureYou:
        return Colors.blueAccent;
      case cat.CategoryBucket.essentials:
        return Colors.redAccent;
      case cat.CategoryBucket.lifestyle:
        return Colors.purpleAccent;
    }
  }

  model.TransactionType _transactionTypeForBucket(
      cat.CategoryBucket bucket) {
    switch (bucket) {
      case cat.CategoryBucket.income:
        return model.TransactionType.income;
      case cat.CategoryBucket.futureYou:
        return model.TransactionType.investment;
      case cat.CategoryBucket.essentials:
      case cat.CategoryBucket.lifestyle:
        return model.TransactionType.expense;
    }
  }

  String _bucketSummaryLabel(cat.CategoryBucket bucket) {
    switch (bucket) {
      case cat.CategoryBucket.essentials:
        return "This will count as Essentials spending.";
      case cat.CategoryBucket.futureYou:
        return "This will increase your Future You bucket.";
      case cat.CategoryBucket.lifestyle:
        return "This will use your Lifestyle money.";
      case cat.CategoryBucket.income:
        return "This will add to your Income total.";
    }
  }

  void _showAddCategoryDialog(
      BuildContext context, FinanceProvider provider) {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '🧾');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF020617),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'New category',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Emoji / icon',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final icon = iconController.text.trim().isEmpty
                    ? '🔹'
                    : iconController.text.trim();
                if (name.isEmpty) return;

                final newCategory = cat.CategoryModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: name,
                  icon: icon,
                  bucket: _selectedBucket,
                );

                provider.addCategory(newCategory);
                setState(() {
                  _selectedCategory = newCategory;
                });

                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
