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
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.4),
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
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 52,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final isBackspace = key == 'back';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onKey(key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: isBackspace
                      ? Colors.redAccent.withOpacity(0.08)
                      : onBg.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isBackspace
                        ? Colors.redAccent.withOpacity(0.2)
                        : onBg.withOpacity(0.08),
                  ),
                ),
                child: Center(
                  child: isBackspace
                      ? Icon(
                    Icons.backspace_outlined,
                    color: Colors.redAccent,
                    size: 24,
                  )
                      : Text(
                    key,
                    style: TextStyle(
                      color: onBg,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
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
          Expanded(
            child: Divider(
              color: onBg.withOpacity(0.08),
              thickness: 1,
            ),
          ),
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
          Expanded(
            child: Divider(
              color: onBg.withOpacity(0.08),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ultra-compact 2x3 quick access grid with smooth separators.
/// Up to 6 pinned categories, instant-save on tap.
class FixedGridQuickAccess extends StatelessWidget {
  final Function(CategoryModel) onSelect;
  const FixedGridQuickAccess({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    final list = provider.categories.where((c) => c.isPinned).toList();
    final displayList = list.take(6).toList();

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "No favorites pinned",
            style: TextStyle(
              color: onBg.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: onBg.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(2, (row) {
          final rowItems = displayList.skip(row * 3).take(3).toList();
          if (rowItems.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              if (row == 1)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: onBg.withOpacity(0.06),
                ),
              SizedBox(
                height: 56,
                child: Row(
                  children: List.generate(3, (col) {
                    CategoryModel? cat;
                    if (col < rowItems.length) cat = rowItems[col];

                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: col < 2
                                ? BorderSide(
                              color: onBg.withOpacity(0.05),
                              width: 0.8,
                            )
                                : BorderSide.none,
                          ),
                        ),
                        child: cat == null
                            ? const SizedBox.shrink()
                            : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onSelect(cat!),
                            borderRadius: BorderRadius.zero,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: theme.brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          .withOpacity(0.08)
                                          : Colors.white
                                          .withOpacity(0.95),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.amber
                                            .withOpacity(0.55),
                                        width: 1.4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.04),
                                          blurRadius: 4,
                                          offset:
                                          const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      cat.icon,
                                      style: const TextStyle(
                                        fontSize: 21,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color:
                                      onBg.withOpacity(0.75),
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        }),
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
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: onBg.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
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
    final visiblePinnedIds = allPinned.take(6).map((c) => c.id).toSet();

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
            const SizedBox(height: 16),
            Text(
              'Select Category',
              style: TextStyle(
                color: onBg,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    "All categories in this group are already pinned to your favorites!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: onBg.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, cat),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              cat.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  color: onBg,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: onBg.withOpacity(0.4),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newCat =
                    await CategoriesScreen.addCategoryForBucket(
                      context,
                      bucket,
                    );
                    if (newCat != null && context.mounted) {
                      Navigator.pop(context, newCat);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Create New Category"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    foregroundColor:
                    Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
