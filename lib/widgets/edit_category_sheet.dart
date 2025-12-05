import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../models/category.dart';

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

  final _formKey = GlobalKey<FormState>();
  late CategoryBucket _bucket;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconController = TextEditingController(text: widget.category?.icon ?? '⚡');
    _bucket = widget.category?.bucket ?? widget.initialBucket;
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
              isEditing ? "Edit category" : "New category",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Icon & Name Row
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextFormField(
                    controller: _iconController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bucket selector (instead of fixed/variable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CategoryBucket>(
                        value: _bucket,
                        dropdownColor: const Color(0xFF0F172A),
                        iconEnabledColor: Colors.white70,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: const [
                          DropdownMenuItem(
                            value: CategoryBucket.essentials,
                            child: Text('Essentials'),
                          ),
                          DropdownMenuItem(
                            value: CategoryBucket.futureYou,
                            child: Text('Future You'),
                          ),
                          DropdownMenuItem(
                            value: CategoryBucket.lifestyle,
                            child: Text('Lifestyle & Fun'),
                          ),
                          DropdownMenuItem(
                            value: CategoryBucket.income,
                            child: Text('Income'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _bucket = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              _helperTextForBucket(_bucket),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEditing ? "Update" : "Create",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _helperTextForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.essentials:
        return "Essentials are monthly must-do payments (home, utilities, insurance, etc.).";
      case CategoryBucket.futureYou:
        return "Future You covers savings, SIPs, pension, and long-term goals.";
      case CategoryBucket.lifestyle:
        return "Lifestyle & Fun is where your safe-to-spend money goes, guilt-free.";
      case CategoryBucket.income:
        return "Income categories describe where your money comes from.";
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final name = _nameController.text.trim();
      final icon = _iconController.text.trim().isEmpty ? '📁' : _iconController.text.trim();

      if (name.isEmpty) return;

      if (widget.category != null) {
        // Update existing
        final updated = widget.category!.copyWith(
          name: name,
          icon: icon,
          bucket: _bucket,
        );
        provider.updateCategory(updated);
      } else {
        // Create new
        final newId = _generateNewId(provider.categories);
        final newCat = CategoryModel(
          id: newId,
          name: name,
          icon: icon,
          bucket: _bucket,
          isDefault: false,
        );
        provider.addCategory(newCat);
      }

      Navigator.pop(context);
    }
  }

  void _deleteCategory() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    if (widget.category?.id != null) {
      provider.deleteCategory(widget.category!.id);
      Navigator.pop(context);
    }
  }

  int _generateNewId(List<CategoryModel> existing) {
    if (existing.isEmpty) return 1000;
    final maxId = existing.map((c) => c.id).fold<int>(0, (prev, e) => e > prev ? e : prev);
    return maxId + 1;
  }
}
