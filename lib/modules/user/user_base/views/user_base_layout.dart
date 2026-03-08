import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_base_controller.dart';
import '../../home/views/user_home_view.dart';
import '../../cart/views/cart_view.dart';
import '../../discount/views/discount_view.dart';
import '../../profile/views/profile_view.dart';

class UserBaseLayout extends GetView<UserBaseController> {
  const UserBaseLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final index = controller.currentIndex.value;

        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [
              UserHomeView(),
              CartView(),
              DiscountView(),
              ProfileView(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: controller.onTabSelected,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_offer_outlined),
                label: 'Discount',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

