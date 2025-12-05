import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/forecast_item.dart';
import '../providers/finance_provider.dart';

class AddForecastItemDialog extends StatefulWidget {
  final ForecastItem? itemToEdit;

  const AddForecastItemDialog({super.key, this.itemToEdit});

  @override
  State<AddForecastItemDialog> createState() => _AddForecastItemDialogState();
}

class _AddForecastItemDialogState extends State<AddForecastItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController(); // Outstanding / Current Saved
  final _originalAmountController = TextEditingController(); // Original Loan
  final _rateController = TextEditingController();
  final _paymentController = TextEditingController(); // EMI / Repayment / Saving
  final _targetController = TextEditingController(); // Goal Target

  ForecastType _selectedType = ForecastType.debtMelting;
  String _selectedIcon = "🏠";
  Color _selectedColor = const Color(0xFFEF4444);

  // Toggle for "Has Interest/Growth"
  bool _hasInterestOrGrowth = false;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      _amountController.text = item.currentAmount.toStringAsFixed(0);
      _rateController.text = item.interestRate.toString();

      if (item.monthlyPayment > 0) {
        _paymentController.text = item.monthlyPayment.toStringAsFixed(0);
      }

      if (item.isLiability) {
        _originalAmountController.text = item.targetAmount.toStringAsFixed(0);
      } else {
        _targetController.text = item.targetAmount.toStringAsFixed(0);
      }

      _selectedType = item.type;
      _selectedIcon = item.icon;
      _selectedColor = Color(item.colorValue);

      // Logic for Toggle (Interest for Debt OR Growth for Asset)
      if (item.type == ForecastType.debtSimple || item.type == ForecastType.goalTarget) {
        _hasInterestOrGrowth = item.interestRate > 0;
      } else {
        _hasInterestOrGrowth = true; // Always true for Loans/Gold
      }
    } else {
      _hasInterestOrGrowth = false; // Default off for Personal/Goal
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLiability = _selectedType.index <= 2;
    final isEditMode = widget.itemToEdit != null;
    final isGoal = _selectedType == ForecastType.goalTarget;
    final isPersonalDebt = _selectedType == ForecastType.debtSimple;

    // --- DYNAMIC LABELS ---
    String paymentLabel = "Monthly EMI (₹)";
    if (isPersonalDebt) paymentLabel = "Monthly Repayment (₹)";
    if (isGoal) paymentLabel = "Monthly Saving (₹)";

    String rateLabel = "Interest Rate (%)";
    if (isGoal) rateLabel = "Expected Return (% p.a.)";

    // --- VISIBILITY LOGIC ---
    // Show Rate if: EMI/Gold (Always) OR Personal/Goal (Only if Toggle ON)
    bool showRate = _selectedType == ForecastType.debtMelting ||
        _selectedType == ForecastType.debtInterestOnly ||
        ((isPersonalDebt || isGoal) && _hasInterestOrGrowth);

    // Show Payment: Hide for Gold Loan
    bool showPayment = _selectedType != ForecastType.debtInterestOnly;

    // Required? Only for EMI Loan
    bool isPaymentRequired = _selectedType == ForecastType.debtMelting;

    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // KEYBOARD SCROLL WRAPPER
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 24 + MediaQuery.of(context).viewInsets.bottom
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isEditMode ? "Edit Strategy" : "Add Strategy", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),

                        // TYPE SELECTOR
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTypeChip("EMI Loan", ForecastType.debtMelting),
                              const SizedBox(width: 8),
                              _buildTypeChip("Gold/Interest Only", ForecastType.debtInterestOnly),
                              const SizedBox(width: 8),
                              _buildTypeChip("Personal Debt", ForecastType.debtSimple),
                              const SizedBox(width: 8),
                              _buildTypeChip("Goal / Asset", ForecastType.goalTarget),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // NAME & ICON
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 24))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecor("Name (e.g. Car Loan)"),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // AMOUNT FIELDS
                        if (isLiability) ...[
                          TextFormField(
                            controller: _originalAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecor("Original Loan Amount (₹)"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: _inputDecor("Outstanding Amount (₹)"),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: _inputDecor("Current Saved (₹)"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecor("Target Goal Amount (₹)"),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                        ],

                        const SizedBox(height: 16),

                        // TOGGLE: INTEREST or GROWTH
                        if (isPersonalDebt || isGoal) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  isGoal ? "Does this investment grow?" : "Does this loan have interest?",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)
                              ),
                              Switch(
                                value: _hasInterestOrGrowth,
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (val) => setState(() => _hasInterestOrGrowth = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // RATE & PAYMENT
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showRate)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _rateController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecor(rateLabel),
                                        validator: (v) => v!.isEmpty ? "Req" : null,
                                      ),
                                      if (isGoal)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4, left: 4),
                                          child: Text("Enter post-tax return", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (showPayment)
                              Expanded(
                                child: TextFormField(
                                  controller: _paymentController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecor(paymentLabel),
                                  validator: (v) {
                                    if (isPaymentRequired && (v == null || v.isEmpty)) return "Required";
                                    return null;
                                  },
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- ACTION BUTTONS ---

                        // DELETE BUTTON (Only in Edit Mode)
                        if (isEditMode) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E293B),
                                    title: const Text("Delete Strategy?", style: TextStyle(color: Colors.white)),
                                    content: const Text(
                                      "This will remove this item from your forecast. Action cannot be undone.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final provider = Provider.of<FinanceProvider>(context, listen: false);
                                          provider.deleteForecastItem(widget.itemToEdit!.id);
                                          Navigator.pop(ctx); // Close confirmation
                                          Navigator.pop(context); // Close edit dialog
                                        },
                                        child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text("Delete Strategy", style: TextStyle(color: Colors.redAccent)),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) _saveItem(context, isEditMode);
                            },
                            child: Text(isEditMode ? "Update Strategy" : "Add Strategy", style: const TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, ForecastType type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) {
        setState(() {
          _selectedType = type;
          if (type.index <= 2) { _selectedColor = const Color(0xFFEF4444); _selectedIcon = "🏠"; }
          else { _selectedColor = const Color(0xFF10B981); _selectedIcon = "🎯"; }

          // Default Toggles
          if (type == ForecastType.debtSimple || type == ForecastType.goalTarget) {
            _hasInterestOrGrowth = false; // Default OFF for Personal/Goal
            _rateController.clear();
          } else {
            _hasInterestOrGrowth = true;
          }
        });
      },
      backgroundColor: Colors.white10,
      selectedColor: const Color(0xFF3B82F6),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      filled: true,
      fillColor: Colors.black26,
    );
  }

  void _saveItem(BuildContext context, bool isEdit) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    double targetVal = 0;
    if (_selectedType.index <= 2) {
      targetVal = double.tryParse(_originalAmountController.text) ?? 0;
    } else {
      targetVal = double.tryParse(_targetController.text) ?? 0;
    }

    // Check visibility to determine if we save Rate/Payment
    final isGoal = _selectedType == ForecastType.goalTarget;
    final isPersonal = _selectedType == ForecastType.debtSimple;
    final showRate = _selectedType == ForecastType.debtMelting || _selectedType == ForecastType.debtInterestOnly || ((isPersonal || isGoal) && _hasInterestOrGrowth);

    final newItem = ForecastItem(
      id: isEdit ? widget.itemToEdit!.id : const Uuid().v4(),
      name: _nameController.text,
      icon: _selectedIcon,
      type: _selectedType,
      currentAmount: double.tryParse(_amountController.text) ?? 0,
      targetAmount: targetVal,
      interestRate: showRate ? (double.tryParse(_rateController.text) ?? 0) : 0,
      monthlyPayment: double.tryParse(_paymentController.text) ?? 0,
      colorValue: _selectedColor.value,
    );

    if (isEdit) {
      provider.deleteForecastItem(newItem.id);
      provider.addForecastItem(newItem);
    } else {
      provider.addForecastItem(newItem);
    }
    Navigator.pop(context);
  }
}
