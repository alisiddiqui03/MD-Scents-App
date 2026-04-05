import 'package:get/get.dart';

import '../widgets/app_branded_loading.dart';
import 'middleware/role_middleware.dart';
import '../../modules/user/auth/bindings/auth_binding.dart';
import '../../modules/user/auth/views/auth_view.dart';
import '../../modules/user/user_base/bindings/user_base_binding.dart';
import '../../modules/user/user_base/views/user_base_layout.dart';
import '../../modules/user/home/bindings/user_home_binding.dart';
import '../../modules/user/home/views/user_home_view.dart';
import '../../modules/user/product_detail/bindings/product_detail_binding.dart';
import '../../modules/user/product_detail/views/product_detail_view.dart';
import '../../modules/user/cart/bindings/cart_binding.dart';
import '../../modules/user/cart/views/cart_view.dart';
import '../../modules/user/checkout/bindings/checkout_binding.dart';
import '../../modules/user/checkout/views/checkout_view.dart';
import '../../modules/user/discount/bindings/discount_binding.dart';
import '../../modules/user/discount/views/discount_view.dart';
import '../../modules/user/profile/bindings/profile_binding.dart';
import '../../modules/user/profile/views/profile_view.dart';

import '../../modules/user/orders/views/orders_view.dart' as user_orders;
import '../../modules/user/orders/bindings/user_orders_binding.dart';
import '../../modules/user/order_confirm/views/order_confirm_view.dart';
import '../../modules/user/refer_earn/bindings/refer_earn_binding.dart';
import '../../modules/user/refer_earn/views/refer_earn_view.dart';
import '../../modules/user/wallet/bindings/wallet_binding.dart';
import '../../modules/user/wallet/views/wallet_view.dart';
import '../../modules/user/wishlist/bindings/wishlist_binding.dart';
import '../../modules/user/wishlist/views/wishlist_view.dart';
import '../../modules/user/addresses/bindings/addresses_binding.dart';
import '../../modules/user/addresses/views/addresses_view.dart';
import '../../modules/user/all_products/bindings/all_products_binding.dart';
import '../../modules/user/all_products/views/all_products_view.dart';
import '../../modules/user/featured_products/bindings/featured_products_binding.dart';
import '../../modules/user/featured_products/views/featured_products_view.dart';

import '../../modules/admin/admin_base/bindings/admin_base_binding.dart';
import '../../modules/admin/admin_base/views/admin_base_layout.dart';
import '../../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../../modules/admin/upload_product/bindings/upload_product_binding.dart';
import '../../modules/admin/upload_product/views/upload_product_view.dart';
import '../../modules/admin/inventory/bindings/inventory_binding.dart';
import '../../modules/admin/inventory/views/inventory_view.dart';
import '../../modules/admin/orders/bindings/orders_binding.dart';
import '../../modules/admin/orders/views/orders_view.dart';
import '../../modules/admin/referrals/bindings/admin_referral_detail_binding.dart';
import '../../modules/admin/referrals/bindings/admin_referrals_binding.dart';
import '../../modules/admin/referrals/views/admin_referral_order_detail_view.dart';
import '../../modules/admin/referrals/views/admin_referrals_view.dart';
import '../../modules/admin/settings/bindings/admin_settings_binding.dart';
import '../../modules/admin/settings/views/admin_settings_view.dart';
import '../../modules/admin/ads_discount/bindings/admin_ads_discount_binding.dart';
import '../../modules/admin/ads_discount/views/admin_ads_discount_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ROOT;

  static final routes = <GetPage>[
    // Root route resolves to a concrete page via middleware.
    GetPage(
      name: _Paths.ROOT,
      page: () => const AppBrandedLoading(),
      middlewares: [RoleMiddleware()],
    ),

    // Auth
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),

    // User base + tabs
    GetPage(
      name: _Paths.USER_BASE,
      page: () => const UserBaseLayout(),
      binding: UserBaseBinding(),
    ),
    GetPage(
      name: _Paths.USER_HOME,
      page: () => const UserHomeView(),
      binding: UserHomeBinding(),
    ),
    GetPage(
      name: _Paths.USER_PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: _Paths.USER_CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: _Paths.USER_CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: _Paths.USER_DISCOUNT,
      page: () => const DiscountView(),
      binding: DiscountBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: _Paths.USER_ORDERS,
      page: () => const user_orders.OrdersView(),
      binding: UserOrdersBinding(),
    ),
    GetPage(
      name: _Paths.USER_WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: _Paths.USER_ADDRESSES,
      page: () => const AddressesView(),
      binding: AddressesBinding(),
    ),
    GetPage(
      name: _Paths.USER_ALL_PRODUCTS,
      page: () => const AllProductsView(),
      binding: AllProductsBinding(),
    ),
    GetPage(
      name: _Paths.USER_FEATURED_PRODUCTS,
      page: () => const FeaturedProductsView(),
      binding: FeaturedProductsBinding(),
    ),
    GetPage(
      name: _Paths.USER_ORDER_CONFIRM,
      page: () => const OrderConfirmView(),
    ),
    GetPage(
      name: _Paths.USER_REFER_EARN,
      page: () => const ReferEarnView(),
      binding: ReferEarnBinding(),
    ),
    GetPage(
      name: _Paths.USER_WALLET,
      page: () => const WalletView(),
      binding: WalletBinding(),
    ),

    // Admin base + tabs
    GetPage(
      name: _Paths.ADMIN_BASE,
      page: () => const AdminBaseLayout(),
      binding: AdminBaseBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_UPLOAD_PRODUCT,
      page: () => const UploadProductView(),
      binding: UploadProductBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_REFERRALS,
      page: () => const AdminReferralsView(),
      binding: AdminReferralsBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_REFERRAL_ORDER_DETAIL,
      page: () => const AdminReferralOrderDetailView(),
      binding: AdminReferralDetailBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_SETTINGS,
      page: () => const AdminSettingsView(),
      binding: AdminSettingsBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_ADS_DISCOUNT,
      page: () => const AdminAdsDiscountView(),
      binding: AdminAdsDiscountBinding(),
    ),
  ];
}
