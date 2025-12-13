import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_provider.dart';
import '../../models/category_model.dart';
import '../../widgets/edit_category_sheet.dart';
import '../../utils/currency_format.dart'; // <--- Added Import

class CategoriesScreen extends StatefulWidget {
  final int initialIndex;

  const CategoriesScreen({super.key, this.initialIndex = 0});

  static Future<CategoryModel?> addCategoryForBucket(
      BuildContext context,
      CategoryBucket bucket,
      ) {
    return showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditCategorySheet(
        category: null,
        initialBucket: bucket,
      ),
    );
  }

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 4),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Categories',
          style: TextStyle(
            color: onBg,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: onBg),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onBg),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: const Color(0xFF3B82F6),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: onBg.withOpacity(0.5),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0),
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Invest'),
            Tab(text: 'Liability'),
            Tab(text: 'Goal'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(
            context,
            provider,
            CategoryBucket.expense,
            emptyText: "No expense categories yet.\nTap below to add one.",
          ),
          _buildCategoryList(
            context,
            provider,
            CategoryBucket.invest,
            emptyText: "No investment categories yet.\nTap below to add one.",
          ),
          _buildCategoryList(
            context,
            provider,
            CategoryBucket.liability,
            emptyText: "No liability categories yet.\nTap below to add one.",
          ),
          _buildCategoryList(
            context,
            provider,
            CategoryBucket.goal,
            emptyText: "No goal categories yet.\nTap below to add one.",
          ),
          _buildCategoryList(
            context,
            provider,
            CategoryBucket.income,
            emptyText: "No income categories yet.\nTap below to add one.",
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context,
      FinanceProvider provider,
      CategoryBucket bucket, {
        required String emptyText,
      }) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;

    // "surfaceContainerHighest" is new in Flutter 3.22+, adding fallback for older versions
    Color tileBg;
    try {
      tileBg = theme.colorScheme.surfaceContainerHighest;
    } catch (_) {
      tileBg = theme.colorScheme.surface.withOpacity(0.08); // Fallback
    }

    tileBg = tileBg.withOpacity(
      theme.brightness == Brightness.dark ? 0.5 : 1,
    );

    final categories =
    provider.categories.where((c) => c.bucket == bucket).toList();

    Widget buildAddNewTile() {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => _showEditSheet(context, null, bucket),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: onBg.withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "New Category",
                          style: TextStyle(
                            color: onBg,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
      );
    }

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconForBucket(bucket),
              size: 64,
              color: onBg.withOpacity(0.12),
            ),
            const SizedBox(height: 16),
            Text(
              emptyText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onBg.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            buildAddNewTile(),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return buildAddNewTile();
        }

        final cat = categories[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: onBg.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cat.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              cat.name,
              style: TextStyle(
                color: onBg,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _colorForBucket(bucket).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _labelForBucket(bucket),
                          style: TextStyle(
                            color: _colorForBucket(bucket),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (cat.isDefault) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: onBg.withOpacity(0.5),
                        ),
                      ],
                    ],
                  ),
                ),
                if (cat.isMandate && cat.monthlyMandate != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${CurrencyFormat.format(context, cat.monthlyMandate!)} / month',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: onBg.withOpacity(0.4),
              size: 20,
            ),
            onTap: () => _showEditSheet(context, cat, bucket),
          ),
        );
      },
    );
  }

  IconData _iconForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.expense:
        return Icons.receipt_long_outlined;
      case CategoryBucket.invest:
        return Icons.trending_up;
      case CategoryBucket.liability:
        return Icons.account_balance_outlined;
      case CategoryBucket.goal:
        return Icons.flag_outlined;
      case CategoryBucket.income:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _colorForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.expense:
        return const Color(0xFFEF4444);
      case CategoryBucket.invest:
        return const Color(0xFF10B981);
      case CategoryBucket.liability:
        return const Color(0xFF8B5CF6);
      case CategoryBucket.goal:
        return const Color(0xFFF59E0B);
      case CategoryBucket.income:
        return const Color(0xFF3B82F6);
    }
  }

  String _labelForBucket(CategoryBucket bucket) {
    switch (bucket) {
      case CategoryBucket.expense:
        return 'EXPENSE';
      case CategoryBucket.invest:
        return 'INVEST';
      case CategoryBucket.liability:
        return 'LIABILITY';
      case CategoryBucket.goal:
        return 'GOAL';
      case CategoryBucket.income:
        return 'INCOME';
    }
  }

  Future<CategoryModel?> _showEditSheet(
      BuildContext context,
      CategoryModel? category,
      CategoryBucket bucket,
      ) {
    return showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditCategorySheet(
        category: category,
        initialBucket: bucket,
      ),
    );
  }
}
