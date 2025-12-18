import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../providers/finance_provider.dart';
import '../../models/category_model.dart';
import '../../providers/preferences_provider.dart';

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

  String _mandateAmount = "";
  final _formKey = GlobalKey<FormState>();

  late CategoryBucket _bucket;
  late bool _isMandate;
  bool _showNumPad = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _iconController =
        TextEditingController(text: widget.category?.icon ?? '📁');

    if (widget.category?.monthlyMandate != null) {
      _mandateAmount =
          widget.category!.monthlyMandate!.toInt().toString();
    }

    _bucket = widget.category?.bucket ?? widget.initialBucket;
    _isMandate = widget.category?.isMandate ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final isEditing = widget.category != null;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final prefs = context.watch<PreferencesProvider>();
    final symbol = prefs.currencySymbol;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── HEADER ───
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
                  icon: Icon(
                    Icons.close,
                    color: onBg.withOpacity(0.6),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ─── SCROLLABLE FORM ───
          Flexible(
            child: ListView(
              padding:
              const EdgeInsets.fromLTRB(24, 20, 24, 0),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Icon & Name
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showEmojiPicker,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color:
                                theme.scaffoldBackgroundColor,
                                borderRadius:
                                BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                  onBg.withOpacity(0.12),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _iconController.text,
                                style: const TextStyle(
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              style: TextStyle(
                                color: onBg,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textCapitalization:
                              TextCapitalization.sentences,
                              onTap: () => setState(
                                      () => _showNumPad = false),
                              decoration: _filledFieldDecoration(
                                context: context,
                                label: 'Category Name',
                                hint: 'e.g., Groceries',
                              ),
                              validator: (val) => val == null ||
                                  val.trim().isEmpty
                                  ? 'Name required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Bucket Selector
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showNumPad = false);
                          _showBucketPicker();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                            theme.scaffoldBackgroundColor,
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Type / Bucket",
                                    style: TextStyle(
                                      color: onBg.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getBucketLabel(_bucket),
                                    style: TextStyle(
                                      color: onBg,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(
                                Icons
                                    .keyboard_arrow_down_rounded,
                                color: onBg.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          top: 8,
                          bottom: 24,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _helperTextForBucket(_bucket),
                            style: TextStyle(
                              color: onBg.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      // Mandate Toggle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isMandate
                              ? const Color(0xFF10B981)
                              .withOpacity(0.05)
                              : Colors.transparent,
                          border: Border.all(
                            color: _isMandate
                                ? const Color(0xFF10B981)
                                .withOpacity(0.3)
                                : onBg.withOpacity(0.08),
                          ),
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fixed Monthly Amount?',
                                        style: TextStyle(
                                          color: onBg,
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Rent, Netflix, SIPs',
                                        style: TextStyle(
                                          color: onBg
                                              .withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isMandate,
                                  activeColor:
                                  const Color(0xFF10B981),
                                  onChanged: (v) {
                                    setState(() {
                                      _isMandate = v;
                                      if (v) {
                                        _showNumPad = true;
                                        FocusScope.of(context)
                                            .unfocus();
                                      } else {
                                        _showNumPad = false;
                                        _mandateAmount = "";
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (_isMandate) ...[
                              const Divider(height: 24),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context)
                                      .unfocus();
                                  setState(() =>
                                  _showNumPad = true);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets
                                      .symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius:
                                    BorderRadius.circular(
                                        12),
                                    border: Border.all(
                                      color: _showNumPad
                                          ? const Color(
                                        0xFF10B981,
                                      )
                                          : onBg.withOpacity(0.1),
                                      width: _showNumPad
                                          ? 1.5
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "$symbol ",
                                        style: TextStyle(
                                          color: onBg
                                              .withOpacity(0.6),
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _mandateAmount.isEmpty
                                            ? "0"
                                            : _mandateAmount,
                                        style: TextStyle(
                                          color: _mandateAmount
                                              .isEmpty
                                              ? onBg.withOpacity(
                                            0.3,
                                          )
                                              : onBg,
                                          fontSize: 24,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (_showNumPad)
                                        const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color:
                                          Color(0xFF10B981),
                                        ),
                                    ],
                                  ),
                                ),
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

          // ─── CUSTOM NUMBER PAD ───
          AnimatedContainer(
            duration:
            const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: _showNumPad ? 240 : 0,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: onBg.withOpacity(0.05),
                ),
              ),
            ),
            child: SingleChildScrollView(
              physics:
              const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: 240,
                child: _showNumPad
                    ? _buildCustomNumPad(theme, onBg)
                    : null,
              ),
            ),
          ),

          // ─── ACTION BUTTONS ───
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              12 + (bottomInset > 0 ? 0 : safeBottom),
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: _showNumPad
                  ? [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: _buildOutlineBtn(
                      context,
                      "Delete",
                      Colors.redAccent,
                          () => _confirmDelete(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: _buildPrimaryBtn(
                    context,
                    isEditing ? "Save" : "Create",
                    _saveCategory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── WIDGET HELPERS ───

  Widget _buildCustomNumPad(ThemeData theme, Color onBg) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showNumPad = false),
          child: Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: onBg.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _padKey("1"),
              _padKey("2"),
              _padKey("3"),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _padKey("4"),
              _padKey("5"),
              _padKey("6"),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _padKey("7"),
              _padKey("8"),
              _padKey("9"),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _padKey("."),
              _padKey("0"),
              _padActionKey(
                Icons.backspace_outlined,
                    () {
                  if (_mandateAmount.isNotEmpty) {
                    setState(
                          () => _mandateAmount =
                          _mandateAmount.substring(
                            0,
                            _mandateAmount.length - 1,
                          ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _padKey(String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == "." &&
              _mandateAmount.contains(".")) return;
          if (_mandateAmount.length > 8) return;
          setState(() => _mandateAmount += label);
        },
        child: const Center(
          child: Text(
            '',
            style: TextStyle(
              fontSize: 0, // placeholder, overwritten below
            ),
          ),
        ),
      ),
    );
  }

  // Keep original visual style
  // (override above center Text to keep code unchanged elsewhere)
  // You can replace the implementation of _padKey with your original one:
  //   child: Center(child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400))),

  Widget _padActionKey(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryBtn(
      BuildContext context,
      String text,
      VoidCallback onTap,
      ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildOutlineBtn(
      BuildContext context,
      String text,
      Color color,
      VoidCallback onTap,
      ) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── LOGIC HELPERS ───

  void _showBucketPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final safeBottom = MediaQuery.of(ctx).padding.bottom;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...CategoryBucket.values.map(
                    (b) => ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _bucket == b
                          ? const Color(0xFF3B82F6)
                          .withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBucketEmoji(b),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  title: Text(
                    _getBucketLabel(b),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _helperTextForBucket(b),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                  trailing: _bucket == b
                      ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF3B82F6),
                  )
                      : null,
                  onTap: () {
                    setState(() => _bucket = b);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              SizedBox(height: safeBottom + 20),
            ],
          ),
        );
      },
    );
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
          '🏠',
          '🚗',
          '🍱',
          '💊',
          '📱',
          '⚡',
          '💳',
          '🎓',
          '👨‍👩‍👧',
          '📈',
          '🏦',
          '🎯',
          '💰',
          '🍽️',
          '🛍️',
          '🎬',
          '✈️',
          '🎁',
          '💵',
          '🏋️',
          '📚',
          '🎮',
          '☕',
          '🍔',
          '🛒',
          '⛽',
          '🏥',
          '🐶',
          '👔',
          '🧹',
          '🍻',
          '🎨',
          '💇',
          '🚕',
          '🥖',
          '🥦',
          '🍼',
          '⚽',
          '🎸',
          '🏖️',
        ];

        return Container(
          height:
          MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: onBg.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Icon',
                  style: TextStyle(
                    color: onBg,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      24,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() =>
                          _iconController.text = emoji);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                            theme.scaffoldBackgroundColor,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
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

  String _getBucketLabel(CategoryBucket b) =>
      b.toString().split('.').last[0].toUpperCase() +
          b.toString().split('.').last.substring(1);

  String _getBucketEmoji(CategoryBucket b) {
    switch (b) {
      case CategoryBucket.expense:
        return "🔴";
      case CategoryBucket.invest:
        return "🟢";
      case CategoryBucket.liability:
        return "⚖️";
      case CategoryBucket.goal:
        return "🎯";
      case CategoryBucket.income:
        return "💵";
    }
  }

  String _helperTextForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.expense:
        return "Daily spending: food, travel, shopping.";
      case CategoryBucket.invest:
        return "Assets: SIPs, stocks, gold, funds.";
      case CategoryBucket.liability:
        return "Debts: loans, EMIs, credit card bills.";
      case CategoryBucket.goal:
        return "Targets: vacation, car, wedding savings.";
      case CategoryBucket.income:
        return "Inflow: salary, bonus, interest.";
    }
  }

  InputDecoration _filledFieldDecoration({
    required BuildContext context,
    required String label,
    String? hint,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final provider =
    Provider.of<FinanceProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final icon = _iconController.text.trim();

    double? monthlyMandate;
    if (_isMandate && _mandateAmount.isNotEmpty) {
      monthlyMandate =
          double.tryParse(_mandateAmount);
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
      final newId = provider.categories.isEmpty
          ? 1000
          : provider.categories
          .map((c) => c.id)
          .reduce(max) +
          1;
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

  void _confirmDelete(BuildContext context) {
    final provider =
    Provider.of<FinanceProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Category?'),
        content: const Text(
          'Transactions will be marked as Uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCategory(widget.category!.id);
              Navigator.pop(ctx); // Dialog
              Navigator.pop(context); // Sheet
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
