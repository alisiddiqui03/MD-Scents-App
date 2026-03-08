part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // Core
  static const ROOT = _Paths.ROOT;
  static const AUTH = _Paths.AUTH;

  // User flow
  static const USER_BASE = _Paths.USER_BASE;
  static const USER_HOME = _Paths.USER_HOME;
  static const USER_PRODUCT_DETAIL = _Paths.USER_PRODUCT_DETAIL;
  static const USER_CART = _Paths.USER_CART;
  static const USER_CHECKOUT = _Paths.USER_CHECKOUT;
  static const USER_DISCOUNT = _Paths.USER_DISCOUNT;
  static const USER_PROFILE = _Paths.USER_PROFILE;
  static const USER_ORDERS = _Paths.USER_ORDERS;
  static const USER_WISHLIST = _Paths.USER_WISHLIST;
  static const USER_ADDRESSES = _Paths.USER_ADDRESSES;
  static const USER_ALL_PRODUCTS = _Paths.USER_ALL_PRODUCTS;
  static const USER_ORDER_CONFIRM = _Paths.USER_ORDER_CONFIRM;

  // Admin flow
  static const ADMIN_BASE = _Paths.ADMIN_BASE;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const ADMIN_UPLOAD_PRODUCT = _Paths.ADMIN_UPLOAD_PRODUCT;
  static const ADMIN_INVENTORY = _Paths.ADMIN_INVENTORY;
  static const ADMIN_ORDERS = _Paths.ADMIN_ORDERS;
  static const ADMIN_SETTINGS = _Paths.ADMIN_SETTINGS;
}

abstract class _Paths {
  _Paths._();

  // Core
  static const ROOT = '/';
  static const AUTH = '/auth';

  // User flow
  static const USER_BASE = '/user';
  static const USER_HOME = '/user/home';
  static const USER_PRODUCT_DETAIL = '/user/product-detail';
  static const USER_CART = '/user/cart';
  static const USER_CHECKOUT = '/user/checkout';
  static const USER_DISCOUNT = '/user/discount';
  static const USER_PROFILE = '/user/profile';
  static const USER_ORDERS = '/user/orders';
  static const USER_WISHLIST = '/user/wishlist';
  static const USER_ADDRESSES = '/user/addresses';
  static const USER_ALL_PRODUCTS = '/user/all-products';
  static const USER_ORDER_CONFIRM = '/user/order-confirm';

  // Admin flow
  static const ADMIN_BASE = '/admin';
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const ADMIN_UPLOAD_PRODUCT = '/admin/upload-product';
  static const ADMIN_INVENTORY = '/admin/inventory';
  static const ADMIN_ORDERS = '/admin/orders';
  static const ADMIN_SETTINGS = '/admin/settings';
}

