import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../data/categories.dart';

class AddTransactionDialog extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionDialog({super.key, this.transaction});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TransactionType _type;
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  String _displayValue = '0';
  String _expression = '';
  double? _pendingSum;
  String? _lastOperator;
  bool _showKeypad = false;
  bool _showCategorySelection = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _selectedMainCategory = widget.transaction!.mainCategory;
      _selectedSubCategory = widget.transaction!.subCategory;
      _displayValue = widget.transaction!.amount.toString();
    } else {
      _type = TransactionType.expense;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yy, EEE');
    final timeFormat = DateFormat('hh:mm a');

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.transaction != null
                ? 'Edit ${_type.name.toUpperCase()}'
                : 'Add ${_type.name.toUpperCase()}',
          ),
        ),
        body: Column(
          children: [
            // Type Selection Tabs
            Row(
              children: [
                Expanded(
                  child: _buildTypeTab('INCOME', TransactionType.income, Colors.green),
                ),
                Expanded(
                  child: _buildTypeTab('EXPENSE', TransactionType.expense, Colors.red),
                ),
                Expanded(
                  child: _buildTypeTab('INVEST', TransactionType.investment, Colors.blue),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time
                    _buildInfoRow('Date', '${dateFormat.format(now)} • ${timeFormat.format(now)}'),
                    const SizedBox(height: 24),
                    // Amount
                    _buildClickableField(
                      'Amount',
                      '₹ ${_expression.isEmpty ? _displayValue : '$_expression$_displayValue'}',
                      () {
                        setState(() {
                          _showKeypad = !_showKeypad;
                          _showCategorySelection = false;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Category
                    _buildClickableField(
                      'Category',
                      _selectedSubCategory != null
                          ? '$_selectedMainCategory / $_selectedSubCategory'
                          : 'Select Category',
                      () {
                        setState(() {
                          _showCategorySelection = !_showCategorySelection;
                          _showKeypad = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Category Selection
            if (_showCategorySelection) _buildCategorySelector(),
            // Keypad
            if (_showKeypad) _buildKeypad(),
            // Save Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canSave() ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTypeColor(),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, TransactionType type, Color color) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () {
        setState(() {
          _type = type;
          _selectedMainCategory = null;
          _selectedSubCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.black,
          border: Border(bottom: BorderSide(color: color, width: 2)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
        Divider(color: _getTypeColor()),
      ],
    );
  }

  Widget _buildClickableField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          Divider(color: _getTypeColor()),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = allCategories.where((c) => c.type == _type).toList();
    final subCategories = _selectedMainCategory != null
        ? categories
            .firstWhere((c) => c.name == _selectedMainCategory)
            .subcategories
        : <SubCategory>[];

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          // Main Categories
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedMainCategory == category.name;
                return ListTile(
                  selected: isSelected,
                  leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(category.name, style: const TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    setState(() {
                      _selectedMainCategory = category.name;
                      _selectedSubCategory = null;
                    });
                  },
                );
              },
            ),
          ),
          // Subcategories
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: subCategories.isEmpty
                  ? const Center(child: Text('Select a category'))
                  : ListView.builder(
                      itemCount: subCategories.length,
                      itemBuilder: (context, index) {
                        final sub = subCategories[index];
                        return ListTile(
                          leading: Text(sub.icon, style: const TextStyle(fontSize: 20)),
                          title: Text(sub.name, style: const TextStyle(fontSize: 14)),
                          subtitle: Text(sub.description, style: const TextStyle(fontSize: 11)),
                          onTap: () {
                            setState(() {
                              _selectedSubCategory = sub.name;
                              _showCategorySelection = false;
                            });
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildKeypadButton('1'),
              _buildKeypadButton('2'),
              _buildKeypadButton('3'),
              _buildKeypadButton('⌫', onTap: _handleBackspace),
            ],
          ),
          Row(
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
              _buildKeypadButton('-', onTap: () => _handleOperator('-')),
            ],
          ),
          Row(
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
              _buildKeypadButton('+', onTap: () => _handleOperator('+')),
            ],
          ),
          Row(
            children: [
              _buildKeypadButton('00'),
              _buildKeypadButton('0'),
              _buildKeypadButton('.', onTap: _handleDecimal),
              _buildKeypadButton('Done', onTap: _handleDone, color: _getTypeColor()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String label, {VoidCallback? onTap, Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onTap ?? () => _handleNumber(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  void _handleNumber(String num) {
    setState(() {
      if (_displayValue == '0') {
        _displayValue = num;
      } else {
        _displayValue += num;
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_displayValue.length > 1) {
        _displayValue = _displayValue.substring(0, _displayValue.length - 1);
      } else {
        _displayValue = '0';
      }
    });
  }

  void _handleDecimal() {
    if (!_displayValue.contains('.')) {
      setState(() {
        _displayValue += '.';
      });
    }
  }

  void _handleOperator(String op) {
    setState(() {
      final current = double.tryParse(_displayValue) ?? 0;
      if (_pendingSum == null) {
        _pendingSum = current;
      } else if (_lastOperator != null) {
        _pendingSum = _lastOperator == '+' ? _pendingSum! + current : _pendingSum! - current;
      }
      _lastOperator = op;
      _expression = '$_expression$_displayValue $op ';
      _displayValue = '0';
    });
  }

  void _handleDone() {
    setState(() {
      final current = double.tryParse(_displayValue) ?? 0;
      if (_pendingSum != null && _lastOperator != null) {
        _displayValue = (_lastOperator == '+' ? _pendingSum! + current : _pendingSum! - current).toString();
      }
      _pendingSum = null;
      _lastOperator = null;
      _expression = '';
      _showKeypad = false;
    });
  }

  Color _getTypeColor() {
    switch (_type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.investment:
        return Colors.blue;
      case TransactionType.expense:
        return Colors.red;
    }
  }

  bool _canSave() {
    final amount = double.tryParse(_displayValue);
    return _selectedMainCategory != null &&
        _selectedSubCategory != null &&
        amount != null &&
        amount > 0;
  }

  void _save() async {
    final amount = double.parse(_displayValue);
    final now = DateTime.now();
    final transaction = Transaction(
      id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      mainCategory: _selectedMainCategory!,
      subCategory: _selectedSubCategory!,
      amount: amount,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: DateFormat('hh:mm a').format(now),
    );

    final provider = context.read<FinanceProvider>();
    if (widget.transaction != null) {
      await provider.updateTransaction(transaction);
    } else {
      await provider.addTransaction(transaction);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction ${widget.transaction != null ? 'updated' : 'added'} successfully')),
      );
    }
  }
}
