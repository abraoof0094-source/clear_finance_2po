import '../models/category.dart';

/// Default categories seeded for a new user.
final List<CategoryModel> defaultCategories = [
  // INCOME
  CategoryModel(
    id: 1,
    name: 'Main Income',
    icon: '💼',
    bucket: CategoryBucket.income,
    isDefault: true,
  ),
  CategoryModel(
    id: 2,
    name: 'Side Income',
    icon: '🧾',
    bucket: CategoryBucket.income,
    isDefault: true,
  ),
  CategoryModel(
    id: 3,
    name: 'Extra Income',
    icon: '🎁',
    bucket: CategoryBucket.income,
    isDefault: true,
  ),

  // ESSENTIALS
  CategoryModel(
    id: 10,
    name: 'Home & Rent',
    icon: '🏡',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 11,
    name: 'Utilities',
    icon: '⚡',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 12,
    name: 'Internet & Mobile',
    icon: '📶',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 13,
    name: 'Transport & EMIs',
    icon: '🚗',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 14,
    name: 'Insurance & Protection',
    icon: '🛡️',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 15,
    name: 'Education & Fees',
    icon: '🎓',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 16,
    name: 'Family Support',
    icon: '👨‍👩‍👧',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),
  CategoryModel(
    id: 17,
    name: 'Debt & Cards',
    icon: '💳',
    bucket: CategoryBucket.essentials,
    isDefault: true,
  ),

  // FUTURE YOU
  CategoryModel(
    id: 20,
    name: 'SIP & Mutual Funds',
    icon: '📈',
    bucket: CategoryBucket.futureYou,
    isDefault: true,
  ),
  CategoryModel(
    id: 21,
    name: 'Long-Term Savings',
    icon: '🏦',
    bucket: CategoryBucket.futureYou,
    isDefault: true,
  ),
  CategoryModel(
    id: 22,
    name: 'Retirement & Pension',
    icon: '🏛️',
    bucket: CategoryBucket.futureYou,
    isDefault: true,
  ),
  CategoryModel(
    id: 23,
    name: 'Gold & Assets',
    icon: '🪙',
    bucket: CategoryBucket.futureYou,
    isDefault: true,
  ),
  CategoryModel(
    id: 24,
    name: 'Goals & Big Plans',
    icon: '🎯',
    bucket: CategoryBucket.futureYou,
    isDefault: true,
  ),

  // LIFESTYLE & FUN
  CategoryModel(
    id: 30,
    name: 'Eating & Hangouts',
    icon: '🍽️',
    bucket: CategoryBucket.lifestyle,
    isDefault: true,
  ),
  CategoryModel(
    id: 31,
    name: 'Groceries & Home Food',
    icon: '🧺',
    bucket: CategoryBucket.lifestyle,
    isDefault: true,
  ),
  CategoryModel(
    id: 32,
    name: 'Fun & Entertainment',
    icon: '🎮',
    bucket: CategoryBucket.lifestyle,
    isDefault: true,
  ),
  CategoryModel(
    id: 33,
    name: 'Self-care & Style',
    icon: '💆',
    bucket: CategoryBucket.lifestyle,
    isDefault: true,
  ),
  CategoryModel(
    id: 34,
    name: 'Travel & Getaways',
    icon: '✈️',
    bucket: CategoryBucket.lifestyle,
    isDefault: true,
  ),
  CategoryModel(
    id: 35,
    name: 'Gifts & Celebrations',
    icon: '🎁',
    bucket: CategoryBucket.lifestyle,
    isDefault: true,
  ),
];
