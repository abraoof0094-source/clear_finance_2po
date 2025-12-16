import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../screens/settings/categories_screen.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const GlassContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SlimNumberPad extends StatelessWidget {
  final void Function(String) onKey;
  const SlimNumberPad({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(0, 4, 0, MediaQuery.of(context).padding.bottom + 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 46,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          return InkWell(
            onTap: () => onKey(key),
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: key == 'back'
                  ? Icon(Icons.backspace_outlined, color: onBg.withOpacity(0.5), size: 22)
                  : Text(key, style: TextStyle(color: onBg, fontSize: 24, fontWeight: FontWeight.w400)),
            ),
          );
        },
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  final String title;
  const SectionDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Divider(color: onBg.withOpacity(0.08), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                color: onBg.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Divider(color: onBg.withOpacity(0.08), thickness: 1)),
        ],
      ),
    );
  }
}

class FixedGridQuickAccess extends StatelessWidget {
  final Function(CategoryModel) onSelect;
  const FixedGridQuickAccess({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final list = provider.categories.where((c) => c.isPinned).toList();
    final displayList = list.take(8).toList();

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No favorites pinned",
            style: TextStyle(color: onBg.withOpacity(0.3), fontSize: 11),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final cat = displayList[index];
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
                  ),
                  child: Text(cat.icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    cat.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: onBg.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HelpCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const HelpCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onBg.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: onBg)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: onBg.withOpacity(0.7), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPickerSheet extends StatelessWidget {
  final CategoryBucket bucket;
  const CategoryPickerSheet({super.key, required this.bucket});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final allPinned = provider.categories.where((c) => c.isPinned).toList();
    final visiblePinnedIds = allPinned.take(8).map((c) => c.id).toSet();

    final categories = provider.categories.where((c) {
      return c.bucket == bucket && !visiblePinnedIds.contains(c.id);
    }).toList();

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const SizedBox(height: 12),
            Text('Select Category', style: TextStyle(color: onBg, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    "All categories in this group are already pinned to your favorites!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: onBg.withOpacity(0.4), fontSize: 14),
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Text(cat.icon, style: const TextStyle(fontSize: 24)),
                    title: Text(cat.name, style: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.w600)),
                    onTap: () => Navigator.pop(context, cat),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () async {
                  final newCat = await CategoriesScreen.addCategoryForBucket(context, bucket);
                  if (newCat != null && context.mounted) Navigator.pop(context, newCat);
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text("Create New Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
