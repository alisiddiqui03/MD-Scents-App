class AppConstants {
  const AppConstants._();

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String discountsCollection = 'discounts';

  // Discount constraints
  static const double minDiscountPercent = 5;
  static const double maxDiscountPercent = 20;

  // Storage paths (for future Firebase Storage integration)
  static const String productImagesPath = 'products/images';
  static const String receiptsPath = 'orders/receipts';
}

