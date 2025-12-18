import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For lerpDouble

import '../../providers/finance_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../models/category_model.dart';
import '../../widgets/edit_category_sheet.dart';
import '../../utils/currency_format.dart';

// ─── CONFIGURATION ───
class BucketConfig {
  final String label;
  final Color color;
  final IconData icon;

  const BucketConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

final Map<CategoryBucket, BucketConfig> _bucketConfigs = {
  CategoryBucket.expense: const BucketConfig(
      label: 'EXPENSE', color: Color(0xFFEF4444), icon: Icons.receipt_long_outlined),
  CategoryBucket.invest: const BucketConfig(
      label: 'INVEST', color: Color(0xFF10B981), icon: Icons.trending_up),
  CategoryBucket.liability: const BucketConfig(
      label: 'LIABILITY', color: Color(0xFF8B5CF6), icon: Icons.account_balance_outlined),
  CategoryBucket.goal: const BucketConfig(
      label: 'GOAL', color: Color(0xFFF59E0B), icon: Icons.flag_outlined),
  CategoryBucket.income: const BucketConfig(
      label: 'INCOME', color: Color(0xFF3B82F6), icon: Icons.account_balance_wallet_outlined),
};

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<CategoryBucket> _currentBucketOrder = [];

  Map<CategoryBucket, List<CategoryModel>> _categoriesByBucket = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();
      if (query != _searchQuery) {
        setState(() => _searchQuery = query);
        if (query.isNotEmpty) _autoSwitchTabForSearch(query);
      }
    });
  }

  void _autoSwitchTabForSearch(String query) {
    if (_currentBucketOrder.isEmpty) return;

    final currentIndex = _tabController.index;
    if (currentIndex >= _currentBucketOrder.length) return;

    final currentBucket = _currentBucketOrder[currentIndex];
    final currentHasResults = _categoriesByBucket[currentBucket]?.any((c) => c.name.toLowerCase().contains(query)) ?? false;

    if (currentHasResults) return;

    for (int i = 0; i < _currentBucketOrder.length; i++) {
      final bucket = _currentBucketOrder[i];
      final hasMatch = _categoriesByBucket[bucket]?.any((c) => c.name.toLowerCase().contains(query)) ?? false;

      if (hasMatch) {
        _tabController.animateTo(i);
        return;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final financeProvider = Provider.of<FinanceProvider>(context);
    final prefsProvider = Provider.of<PreferencesProvider>(context);

    _currentBucketOrder = prefsProvider.bucketOrder;

    if (_tabController.length != _currentBucketOrder.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: _currentBucketOrder.length,
        vsync: this,
        initialIndex: widget.initialIndex.clamp(0, _currentBucketOrder.length - 1),
      );
    }

    _updateCache(financeProvider);
  }

  void _updateCache(FinanceProvider provider) {
    _categoriesByBucket = {
      for (var bucket in CategoryBucket.values)
        bucket: provider.categories.where((c) => c.bucket == bucket).toList()
          ..sort((a, b) {
            // 1. Pinned Items (Highest Priority) 📌
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;

            // 2. Mandates (Fixed Costs) ✅
            if (a.isMandate != b.isMandate) return a.isMandate ? -1 : 1;

            // 3. User's Manual Sort Order 🔢
            if (a.sortOrder != b.sortOrder) return a.sortOrder.compareTo(b.sortOrder);

            // 4. Alphabetical Fallback 🔤
            return a.name.compareTo(b.name);
          }),
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showTabReorderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _TabReorderSheet(
          currentOrder: _currentBucketOrder,
          onSave: (newOrder) {
            Provider.of<PreferencesProvider>(context, listen: false).setBucketOrder(newOrder);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How it works"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(Icons.drag_indicator_rounded, "Reorder List", "Long press any category to drag & sort."),
              const SizedBox(height: 16),
              _buildHelpItem(Icons.tune_rounded, "Reorder Tabs", "Tap the Tune icon (top right) to change tab order."),
              const SizedBox(height: 16),
              _buildHelpItem(Icons.push_pin, "Quick Access", "Pin up to 8 categories for fast access."),
              const SizedBox(height: 16),
              _buildHelpItem(Icons.verified, "Mandates", "Monthly fixed costs (like Rent) are grouped at the top."),
              const SizedBox(height: 16),
              _buildHelpItem(Icons.search, "Smart Search", "Type to find categories across all tabs instantly."),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it"))
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            ],
          ),
        )
      ],
    );
  }

  void _onReorder(FinanceProvider provider, CategoryBucket bucket, int oldIndex, int newIndex) {
    if (_searchQuery.isNotEmpty) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final items = _categoriesByBucket[bucket]!;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    for (int i = 0; i < items.length; i++) {
      final updated = items[i].copyWith(sortOrder: i);
      provider.updateCategory(updated);
    }
  }

  void _togglePin(FinanceProvider provider, CategoryModel cat) {
    if (!cat.isPinned) {
      final totalPinned = provider.categories.where((c) => c.isPinned).length;
      if (totalPinned >= 8) {
        _showPremiumSnackBar(
          message: "You can only pin up to 8 categories.",
          icon: Icons.warning_amber_rounded,
          isError: true,
        );
        return;
      }
    }

    final updatedCat = cat.copyWith(isPinned: !cat.isPinned);
    provider.updateCategory(updatedCat);

    _showPremiumSnackBar(
      message: updatedCat.isPinned ? "Pinned to Quick Access" : "Removed from Quick Access",
      icon: updatedCat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
      isError: false,
    );
  }

  void _showPremiumSnackBar({required String message, required IconData icon, bool isError = false}) {
    final theme = Theme.of(context);
    final bgColor = isError ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer;
    final txtColor = isError ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: txtColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: txtColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Categories',
          style: TextStyle(color: onBg, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: onBg),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onBg),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: onBg.withOpacity(0.6)),
            tooltip: "Help",
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: onBg),
            tooltip: "Reorder Tabs",
            onPressed: _showTabReorderSheet,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48 + 50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: onBg, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      hintStyle: TextStyle(color: onBg.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, size: 20, color: onBg.withOpacity(0.5)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorColor: const Color(0xFF3B82F6),
                labelColor: const Color(0xFF3B82F6),
                unselectedLabelColor: onBg.withOpacity(0.5),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: _currentBucketOrder.map((bucket) {
                  final config = _bucketConfigs[bucket]!;
                  final title = config.label[0] + config.label.substring(1).toLowerCase();
                  return Tab(text: title);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _currentBucketOrder.map((bucket) {
          return _buildCategoryList(context, bucket);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoryBucket bucket) {
    final provider = Provider.of<FinanceProvider>(context);
    final config = _bucketConfigs[bucket]!;

    var sortedCats = _categoriesByBucket[bucket] ?? [];

    if (_searchQuery.isNotEmpty) {
      sortedCats = sortedCats
          .where((c) => c.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (sortedCats.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text(
                'No matches in ${config.label}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
        );
      }
      return _buildEmptyState(context, config);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: sortedCats.length + 1,
      buildDefaultDragHandles: _searchQuery.isEmpty,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex == sortedCats.length || newIndex > sortedCats.length) return;
        _onReorder(provider, bucket, oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeOutCubic.transform(animation.value);
            final double elevation = lerpDouble(1, 10, animValue)!;
            final double scale = lerpDouble(1, 1.02, animValue)!;

            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.6),
                        width: 1.5
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        if (index == sortedCats.length) {
          if (_searchQuery.isNotEmpty) return const SizedBox.shrink(key: ValueKey('empty_add'));
          return Container(
            key: const ValueKey('add_button'),
            margin: const EdgeInsets.only(top: 12),
            child: _buildAddNewButton(context, bucket),
          );
        }

        final cat = sortedCats[index];
        return Container(
          key: ValueKey(cat.id),
          margin: const EdgeInsets.only(bottom: 12),
          child: CategoryListTile(
            category: cat,
            onPin: () => _togglePin(provider, cat),
            onEdit: () => _showEditSheet(context, cat, bucket),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, BucketConfig config) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, size: 64, color: onBg.withOpacity(0.12)),
          const SizedBox(height: 16),
          Text(
            "No ${config.label.toLowerCase()} categories yet.\nTap below to add one.",
            textAlign: TextAlign.center,
            style: TextStyle(color: onBg.withOpacity(0.6), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildAddNewButton(context, _bucketConfigs.keys.firstWhere((k) => _bucketConfigs[k] == config)),
        ],
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context, CategoryBucket bucket) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showEditSheet(context, null, bucket),
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Color(0xFF3B82F6), size: 18),
            const SizedBox(width: 6),
            Text(
              "New Category",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSheet(BuildContext context, CategoryModel? category, CategoryBucket bucket) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditCategorySheet(category: category, initialBucket: bucket),
    );
  }
}

// ─── TAB REORDER SHEET ───
class _TabReorderSheet extends StatefulWidget {
  final List<CategoryBucket> currentOrder;
  final ValueChanged<List<CategoryBucket>> onSave;

  const _TabReorderSheet({required this.currentOrder, required this.onSave});

  @override
  State<_TabReorderSheet> createState() => _TabReorderSheetState();
}

class _TabReorderSheetState extends State<_TabReorderSheet> {
  late List<CategoryBucket> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.currentOrder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  "Reorder Tabs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onBg),
                ),
                const SizedBox(height: 4),
                Text(
                  "Drag to rearrange the order of your home tabs.",
                  style: TextStyle(fontSize: 13, color: onBg.withOpacity(0.5)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final bucket = _items[index];
                final config = _bucketConfigs[bucket]!;

                return Container(
                  key: ValueKey(bucket),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: onBg.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(config.icon, color: config.color, size: 22),
                    ),
                    title: Text(
                      config.label,
                      style: TextStyle(fontWeight: FontWeight.w600, color: onBg, fontSize: 15),
                    ),
                    trailing: Icon(Icons.drag_handle_rounded, color: onBg.withOpacity(0.3)),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => widget.onSave(_items),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text("Save Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CategoryListTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onPin;
  final VoidCallback onEdit;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onPin,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final tileBg = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)
        : theme.colorScheme.surfaceContainerHighest;

    final bool showSubtitle = category.isMandate && category.monthlyMandate != null;

    return Container(
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onBg.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.drag_indicator_rounded, color: onBg.withOpacity(0.1), size: 18),

          const SizedBox(width: 8),

          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(category.icon, style: const TextStyle(fontSize: 20)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: onBg,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (category.isMandate) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, size: 12, color: onBg.withOpacity(0.5)),
                    ],
                  ],
                ),

                if (showSubtitle) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      // ✨ LIGHTER STYLE: No fill, just a thin border
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row( // Added Row to include a tiny icon
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.repeat_rounded, size: 10, color: const Color(0xFF10B981)), // Tiny recurring icon
                        const SizedBox(width: 4),
                        Text(
                          '${CurrencyFormat.formatCompact(context, category.monthlyMandate!)} / mo',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: category.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: category.isPinned ? Colors.redAccent : onBg.withOpacity(0.2),
                onTap: onPin,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.edit_rounded,
                color: onBg.withOpacity(0.4),
                onTap: onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
