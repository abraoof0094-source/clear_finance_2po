import 'transaction.dart';

class SubCategory {
  final String name;
  final String icon;
  final String description;

  SubCategory({
    required this.name,
    required this.icon,
    required this.description,
  });
}

class Category {
  final int id;
  final String name;
  final String icon;
  final TransactionType type;
  final List<SubCategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.subcategories,
  });
}
