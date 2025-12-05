import 'dart:convert';

enum CategoryBucket {
  income,
  essentials,
  futureYou,
  lifestyle,
}

CategoryBucket categoryBucketFromString(String? value) {
  switch (value) {
    case 'income':
      return CategoryBucket.income;
    case 'essentials':
      return CategoryBucket.essentials;
    case 'futureYou':
      return CategoryBucket.futureYou;
    case 'lifestyle':
      return CategoryBucket.lifestyle;
    default:
      return CategoryBucket.lifestyle;
  }
}

String categoryBucketToString(CategoryBucket bucket) {
  switch (bucket) {
    case CategoryBucket.income:
      return 'income';
    case CategoryBucket.essentials:
      return 'essentials';
    case CategoryBucket.futureYou:
      return 'futureYou';
    case CategoryBucket.lifestyle:
      return 'lifestyle';
  }
}

/// Category model used in the app.
/// Previously known as CategoryModel; keeping that class name for compatibility.
class CategoryModel {
  final int id;
  final String name;
  /// Emoji or short icon text, e.g. "🏡"
  final String icon;
  /// Essentials / Future You / Lifestyle / Income
  final CategoryBucket bucket;
  /// Whether this came from the app's default seed
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.bucket,
    this.isDefault = false,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    CategoryBucket? bucket,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      bucket: bucket ?? this.bucket,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'bucket': categoryBucketToString(bucket),
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '📁',
      bucket: categoryBucketFromString(json['bucket'] as String?),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  // If somewhere you stored as String, these helpers can be used:
  String toJsonString() => json.encode(toJson());

  factory CategoryModel.fromJsonString(String source) =>
      CategoryModel.fromJson(json.decode(source) as Map<String, dynamic>);
}
