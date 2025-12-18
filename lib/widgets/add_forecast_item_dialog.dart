import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/forecast_item.dart';
import '../providers/finance_provider.dart';
import '../providers/preferences_provider.dart';

class AddForecastItemDialog extends StatefulWidget {
  final ForecastItem? itemToEdit;

  const AddForecastItemDialog({super.key, this.itemToEdit});

  @override
  State<AddForecastItemDialog> createState() => _AddForecastItemDialogState();
}

class _AddForecastItemDialogState extends State<AddForecastItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _originalAmountController = TextEditingController();
  final _rateController = TextEditingController();
  final _paymentController = TextEditingController();
  final _targetController = TextEditingController();
  final _billingDayController = TextEditingController();

  ForecastType _selectedType = ForecastType.emiAmortized;
  String _selectedIcon = "🏠";
  Color _selectedColor = const Color(0xFFEF4444);
  bool _hasInterestOrGrowth = false;
  bool _isEndOfMonth = false;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      _amountController.text = item.currentOutstanding.toStringAsFixed(0);
      _rateController.text = item.interestRate.toString();
      _billingDayController.text = item.billingDay.toString();

      if (item.monthlyEmiOrContribution > 0) {
        _paymentController.text =
            item.monthlyEmiOrContribution.toStringAsFixed(0);
      }

      if (item.isLiability) {
        _originalAmountController.text =
            item.targetAmount.toStringAsFixed(0);
      } else {
        _targetController.text = item.targetAmount.toStringAsFixed(0);
      }

      _selectedType = item.type;
      _selectedIcon = item.icon;
      _selectedColor = Color(item.colorValue);
      _hasInterestOrGrowth = item.interestRate > 0;
      _isEndOfMonth = item.isEndOfMonth;
    } else {
      _hasInterestOrGrowth = true;
      _billingDayController.text = '1';
      _isEndOfMonth = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _originalAmountController.dispose();
    _rateController.dispose();
    _paymentController.dispose();
    _targetController.dispose();
    _billingDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final isEditMode = widget.itemToEdit != null;

    final isLiability = _selectedType.index <= 2;
    final isGoal = _selectedType == ForecastType.goalTarget;
    final isPersonalDebt = _selectedType == ForecastType.debtSimple;
    final isInterestOnly = _selectedType == ForecastType.emiInterestOnly;
    final isAmortized = _selectedType == ForecastType.emiAmortized;

    final bool showInterestToggle = isPersonalDebt || isGoal;
    final bool showRate =
        _hasInterestOrGrowth || isAmortized || isInterestOnly;
    final bool showPayment = isAmortized;
    final bool showBillingDate = isAmortized ||
        isInterestOnly ||
        (isPersonalDebt && _hasInterestOrGrowth) ||
        (isGoal && _hasInterestOrGrowth);

    final prefs = context.watch<PreferencesProvider>();
    final symbol = prefs.currencySymbol;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: theme.cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: theme.cardColor,
                title: Text(
                  isEditMode ? 'Edit Plan' : 'Add Plan',
                  style: TextStyle(
                    color: onBg,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  if (isEditMode)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: _confirmDelete,
                    ),
                  IconButton(
                    icon: Icon(Icons.close, color: onBg.withOpacity(0.6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _TypeSelector(
                          selectedType: _selectedType,
                          onTypeSelected: (type) =>
                              setState(() => _updateType(type)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _pickIcon,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color:
                                  theme.scaffoldBackgroundColor,
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                    onBg.withOpacity(0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _selectedIcon,
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCompactTextField(
                                controller: _nameController,
                                label: "Plan Name",
                                hint: "e.g. Home Loan",
                                theme: theme,
                                onBg: onBg,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isLiability) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactTextField(
                                  controller:
                                  _originalAmountController,
                                  label: "Total Loan",
                                  prefix: symbol,
                                  isNumber: true,
                                  theme: theme,
                                  onBg: onBg,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCompactTextField(
                                  controller: _amountController,
                                  label: "Outstanding",
                                  prefix: symbol,
                                  isNumber: true,
                                  theme: theme,
                                  onBg: onBg,
                                  validator: (v) =>
                                  v!.isEmpty ? "Req" : null,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactTextField(
                                  controller: _amountController,
                                  label: "Saved So Far",
                                  prefix: symbol,
                                  isNumber: true,
                                  theme: theme,
                                  onBg: onBg,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCompactTextField(
                                  controller: _targetController,
                                  label: "Target Amount",
                                  prefix: symbol,
                                  isNumber: true,
                                  theme: theme,
                                  onBg: onBg,
                                  validator: (v) =>
                                  v!.isEmpty ? "Req" : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (showInterestToggle)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isGoal
                                        ? "Does this grow?"
                                        : "Has interest?",
                                    style: TextStyle(
                                      color: onBg
                                          .withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 24,
                                  child: Switch(
                                    value: _hasInterestOrGrowth,
                                    activeColor:
                                    const Color(0xFF3B82F6),
                                    onChanged: (val) =>
                                        setState(() =>
                                        _hasInterestOrGrowth =
                                            val),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isAmortized) ...[
                          _buildCompactTextField(
                            controller: _paymentController,
                            label: "Monthly EMI",
                            prefix: symbol,
                            isNumber: true,
                            theme: theme,
                            onBg: onBg,
                            validator: (v) =>
                            (v == null || v.isEmpty)
                                ? "Req"
                                : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (showRate || showBillingDate)
                          Row(
                            children: [
                              if (showRate)
                                Expanded(
                                  child: _buildCompactTextField(
                                    controller: _rateController,
                                    label: isGoal
                                        ? "Return %"
                                        : "Interest %",
                                    suffix: "%",
                                    isNumber: true,
                                    theme: theme,
                                    onBg: onBg,
                                    validator: (v) =>
                                    v!.isEmpty ? "Req" : null,
                                  ),
                                ),
                              if (showRate && showBillingDate)
                                const SizedBox(width: 12),
                              if (showBillingDate)
                                Expanded(
                                  child: _buildCompactTextField(
                                    controller:
                                    _billingDayController,
                                    label: _getBillingDateLabel(),
                                    hint: "Day (1-31)",
                                    isNumber: true,
                                    theme: theme,
                                    onBg: onBg,
                                    validator: (val) {
                                      if (val == null ||
                                          val.isEmpty) {
                                        return "Req";
                                      }
                                      final day =
                                      int.tryParse(val);
                                      if (day == null ||
                                          day < 1 ||
                                          day > 31) {
                                        return "1-31";
                                      }
                                      _isEndOfMonth =
                                      (day == 31);
                                      return null;
                                    },
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!
                                  .validate()) {
                                _saveItem(context, isEditMode);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF3B82F6),
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isEditMode
                                  ? 'Save Changes'
                                  : 'Add Plan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateType(ForecastType type) {
    _selectedType = type;
    if (type.index <= 2) {
      _selectedColor = const Color(0xFFEF4444);
      _selectedIcon = "🏠";
      _hasInterestOrGrowth = type != ForecastType.debtSimple;
    } else {
      _selectedColor = const Color(0xFF10B981);
      _selectedIcon = "🎯";
      _hasInterestOrGrowth = false;
    }
  }

  String _getBillingDateLabel() {
    if (_selectedType == ForecastType.emiAmortized) return "EMI Date";
    if (_selectedType == ForecastType.emiInterestOnly) return "Debit Date";
    if (_selectedType == ForecastType.debtSimple) return "Debit Date";
    if (_selectedType == ForecastType.goalTarget) return "Credit Date";
    return "Billing Date";
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefix,
    String? suffix,
    bool isNumber = false,
    String? Function(String?)? validator,
    required ThemeData theme,
    required Color onBg,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: TextStyle(
        color: onBg,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: onBg.withOpacity(0.6),
          fontSize: 13,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: onBg.withOpacity(0.4),
          fontSize: 13,
        ),
        prefixText: prefix != null ? "$prefix " : null,
        suffixText: suffix,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
      ),
    );
  }

  void _saveItem(BuildContext context, bool isEdit) {
    final provider =
    Provider.of<FinanceProvider>(context, listen: false);

    double targetVal;
    if (_selectedType.index <= 2) {
      targetVal =
          double.tryParse(_originalAmountController.text) ?? 0;
    } else {
      targetVal =
          double.tryParse(_targetController.text) ?? 0;
    }

    final bool showPayment =
        _selectedType == ForecastType.emiAmortized;
    final double payment = showPayment
        ? (double.tryParse(_paymentController.text) ?? 0)
        : 0;

    final bool hasInterest =
        _selectedType == ForecastType.emiAmortized ||
            _selectedType == ForecastType.emiInterestOnly ||
            _hasInterestOrGrowth;

    final existing = widget.itemToEdit;
    final int billingDay =
        int.tryParse(_billingDayController.text) ?? 1;

    final newItem = ForecastItem(
      isarId: isEdit ? existing!.isarId : Isar.autoIncrement,
      id: isEdit ? existing!.id : const Uuid().v4(),
      name: _nameController.text,
      icon: _selectedIcon,
      type: _selectedType,
      currentOutstanding:
      double.tryParse(_amountController.text) ?? 0,
      targetAmount: targetVal,
      interestRate:
      hasInterest ? (double.tryParse(_rateController.text) ?? 0) : 0,
      monthlyEmiOrContribution: payment,
      billingDay: billingDay,
      colorValue: _selectedColor.value,
      categoryId: existing?.categoryId,
      isEndOfMonth: _isEndOfMonth,
    );

    if (isEdit) {
      provider.updateForecastItem(newItem);
    } else {
      provider.addForecastItem(newItem);
    }

    Navigator.pop(context);
  }

  void _confirmDelete() {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("Delete plan?", style: TextStyle(color: onBg)),
        content: Text(
          "This will remove this plan from your forecast. This cannot be undone.",
          style: TextStyle(color: onBg.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: onBg.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              final provider =
              Provider.of<FinanceProvider>(context, listen: false);
              provider.deleteForecastItem(widget.itemToEdit!.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final onBg = theme.colorScheme.onSurface;
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;

        final icons = [
          "🏠",
          "🚗",
          "🎓",
          "💊",
          "💳",
          "🏖️",
          "💍",
          "💻",
          "📈",
          "👶",
          "🍔",
          "🚆",
          "🎁",
          "⚡",
          "💧",
          "📱",
          "🚜",
          "⚓",
          "✈️",
          "🚀",
        ];

        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Icon",
                style: TextStyle(
                  color: onBg,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: icons
                        .map(
                          (icon) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedIcon = icon);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                            theme.scaffoldBackgroundColor,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Text(
                            icon,
                            style: const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final ForecastType selectedType;
  final ValueChanged<ForecastType> onTypeSelected;

  const _TypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final options = [
      _TypeOption("EMI Loan", "💵", ForecastType.emiAmortized),
      _TypeOption("Interest-Only", "⏳", ForecastType.emiInterestOnly),
      _TypeOption("Personal Debt", "🤝", ForecastType.debtSimple),
      _TypeOption("Goal", "🎯", ForecastType.goalTarget),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
          const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Plan Type',
            style: TextStyle(
              color: onBg.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: options.map((o) {
            final isSelected = selectedType == o.type;
            return GestureDetector(
              onTap: () => onTypeSelected(o.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      .withOpacity(0.15)
                      : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : onBg.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(o.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      o.label,
                      style: TextStyle(
                        color: isSelected
                            ? onBg
                            : onBg.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: onBg.withOpacity(0.1)),
      ],
    );
  }
}

class _TypeOption {
  final String label;
  final String icon;
  final ForecastType type;
  _TypeOption(this.label, this.icon, this.type);
}
