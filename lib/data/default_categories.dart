import '../models/category_model.dart';

final List<CategoryModel> defaultCategories = [
  // INCOME
  CategoryModel(
    id: 1,
    name: 'Salary',
    icon: '💵',
    bucket: CategoryBucket.income,
    isDefault: true,
  ),
  CategoryModel(
    id: 2,
    name: 'Bonus',
    icon: '💴',
    bucket: CategoryBucket.income,
    isDefault: true,
  ),

  // EXPENSE
  CategoryModel(
    id: 3,
    name: 'Rent',
    icon: '🏡',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 4,
    name: 'Helper / Maid',
    icon: '🙋🏻‍♂️',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 5,
    name: 'Utilities',
    icon: '⚡',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 6,
    name: 'Wifi / Phone',
    icon: '📶',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 7,
    name: 'Commute / Fuel',
    icon: '🚗',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 8,
    name: 'Insurance',
    icon: '🛡️',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 9,
    name: 'Education',
    icon: '🏫',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 10,
    name: 'Groceries',
    icon: '🧺',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 11,
    name: 'Health',
    icon: '💊',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),

  // EXPENSE – lifestyle (old lifestyle)
  CategoryModel(
    id: 16,
    name: 'Dine Out',
    icon: '🍽️',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 17,
    name: 'Fun',
    icon: '🎮',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 18,
    name: 'Travel',
    icon: '✈️',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 19,
    name: 'Gifts',
    icon: '🎁',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),
  CategoryModel(
    id: 20,
    name: 'Shopping',
    icon: '🛍️',
    bucket: CategoryBucket.expense,
    isDefault: true,
  ),

  // INVEST
  CategoryModel(
    id: 30,
    name: 'Mutual Fund SIP',
    icon: '📈',
    bucket: CategoryBucket.invest,
    isDefault: true,
  ),
  CategoryModel(
    id: 31,
    name: 'PPF',
    icon: '🏦',
    bucket: CategoryBucket.invest,
    isDefault: true,
  ),
  CategoryModel(
    id: 32,
    name: 'NPS',
    icon: '🏛️',
    bucket: CategoryBucket.invest,
    isDefault: true,
  ),
  CategoryModel(
    id: 33,
    name: 'Fixed Deposit',
    icon: '💰',
    bucket: CategoryBucket.invest,
    isDefault: true,
  ),
];
