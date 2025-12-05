import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/category.dart';

class EditCategorySheet extends StatefulWidget {
  final CategoryModel? category;
  final CategoryType initialType;

  const EditCategorySheet({super.key, this.category, required this.initialType});

  @override
  State<EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<EditCategorySheet> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _amountController;
  late bool _isFixed;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconController = TextEditingController(text: widget.category?.icon ?? '⚡');
    _amountController = TextEditingController(text: widget.category?.amount.toStringAsFixed(0) ?? '0');
    _isFixed = widget.category?.nature == CategoryNature.fixed;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomInset > 0 ? bottomInset + 20 : safeBottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? "Edit Item" : "New Item",
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Icon & Name Row
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                  child: TextFormField(
                    controller: _iconController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Name (e.g. Rent)',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Fixed vs Variable Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fixed Commitment?",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Use for Rent, EMI, SIPs",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isFixed,
                    activeColor: const Color(0xFF3B82F6),
                    onChanged: (val) {
                      setState(() {
                        _isFixed = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Amount Input (Only if Fixed)
            if (_isFixed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    prefixText: "₹ ",
                    prefixStyle: TextStyle(color: Colors.grey, fontSize: 18),
                    border: InputBorder.none,
                    hintText: "Monthly Amount",
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _deleteCategory,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Delete"),
                    ),
                  ),
                if (isEditing) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isEditing ? "Update" : "Create", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final double amount = _isFixed ? (double.tryParse(_amountController.text) ?? 0) : 0;

      final newCat = CategoryModel(
        id: widget.category?.id, // Keep ID if editing
        name: _nameController.text,
        icon: _iconController.text,
        type: widget.initialType,
        nature: _isFixed ? CategoryNature.fixed : CategoryNature.variable,
        amount: amount,
      );

      if (widget.category != null) {
        provider.updateCategory(newCat);
      } else {
        provider.addCategory(newCat);
      }
      Navigator.pop(context);
    }
  }

  void _deleteCategory() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    if (widget.category?.id != null) {
      provider.deleteCategory(widget.category!.id!);
      Navigator.pop(context);
    }
  }
}
