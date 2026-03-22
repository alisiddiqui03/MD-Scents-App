import 'package:get/get.dart';

import '../controllers/featured_products_controller.dart';

class FeaturedProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeaturedProductsController>(() => FeaturedProductsController());
  }
}
