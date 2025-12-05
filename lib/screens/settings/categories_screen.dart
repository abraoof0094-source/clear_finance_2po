import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_provider.dart';
import '../../models/category.dart';
import '../../widgets/edit_category_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  /// Allows jumping to a specific tab (0: Essentials, 1: Future You, 2: Lifestyle, 3: Income)
  final int initialIndex;

  const CategoriesScreen({super.key, this.initialIndex = 0});

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
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 3),
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Essentials'),
            Tab(text: 'Future You'),
            Tab(text: 'Lifestyle'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(
            provider,
            CategoryBucket.essentials,
            emptyText: "No essential categories yet.",
          ),
          _buildCategoryList(
            provider,
            CategoryBucket.futureYou,
            emptyText: "No Future You categories yet.",
          ),
          _buildCategoryList(
            provider,
            CategoryBucket.lifestyle,
            emptyText: "No lifestyle categories yet.",
          ),
          _buildCategoryList(
            provider,
            CategoryBucket.income,
            emptyText: "No income categories yet.",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          final bucket = _bucketForTabIndex(_tabController.index);
          _showEditSheet(context, null, bucket);
        },
      ),
    );
  }

  CategoryBucket _bucketForTabIndex(int index) {
    switch (index) {
      case 0:
        return CategoryBucket.essentials;
      case 1:
        return CategoryBucket.futureYou;
      case 2:
        return CategoryBucket.lifestyle;
      case 3:
      default:
        return CategoryBucket.income;
    }
  }

  Widget _buildCategoryList(
      FinanceProvider provider,
      CategoryBucket bucket, {
        required String emptyText,
      }) {
    final categories =
    provider.categories.where((c) => c.bucket == bucket).toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];

        final isPlannedBucket = bucket == CategoryBucket.essentials ||
            bucket == CategoryBucket.futureYou;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              _subtitleForBucket(bucket, isPlannedBucket),
              style: TextStyle(
                color: isPlannedBucket
                    ? const Color(0xFF3B82F6)
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 18,
            ),
            onTap: () => _showEditSheet(context, cat, bucket),
          ),
        );
      },
    );
  }

  String _subtitleForBucket(
      CategoryBucket bucket,
      bool isPlannedBucket,
      ) {
    switch (bucket) {
      case CategoryBucket.essentials:
        return "Monthly essentials (protected)";
      case CategoryBucket.futureYou:
        return "Future-you money (investments & goals)";
      case CategoryBucket.lifestyle:
        return "Flexible / lifestyle spending";
      case CategoryBucket.income:
        return "Sources of income";
    }
  }

  void _showEditSheet(
      BuildContext context,
      CategoryModel? category,
      CategoryBucket bucket,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EditCategorySheet(category: category, initialBucket: bucket),
    );
  }
}
