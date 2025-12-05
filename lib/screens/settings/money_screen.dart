import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/category.dart';
import '../../widgets/edit_category_sheet.dart';

class MoneyScreen extends StatefulWidget {
  // Add this parameter to allow jumping to a specific tab
  final int initialIndex;

  const MoneyScreen({super.key, this.initialIndex = 0});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Use widget.initialIndex to set the starting tab
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Financial Structure',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Income'), // Index 0
            Tab(text: 'Invest'), // Index 1
            Tab(text: 'Expenses'), // Index 2
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(provider, CategoryType.income),
          _buildCategoryList(provider, CategoryType.investment),
          _buildCategoryList(provider, CategoryType.expense),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          CategoryType type = CategoryType.income;
          if (_tabController.index == 1) type = CategoryType.investment;
          if (_tabController.index == 2) type = CategoryType.expense;

          _showEditSheet(context, null, type);
        },
      ),
    );
  }

  Widget _buildCategoryList(FinanceProvider provider, CategoryType type) {
    final categories = provider.categories.where((c) => c.type == type).toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          "No items defined.",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isFixed = cat.nature == CategoryNature.fixed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 40, height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              isFixed ? "Fixed Commitment" : "Variable / Flexible",
              style: TextStyle(color: isFixed ? const Color(0xFF3B82F6) : Colors.grey, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFixed)
                  Text(
                    provider.currencyFormat.format(cat.amount),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  )
                else
                  const Text(
                    "~",
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
            onTap: () => _showEditSheet(context, cat, type),
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, CategoryModel? category, CategoryType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditCategorySheet(category: category, initialType: type),
    );
  }
}
