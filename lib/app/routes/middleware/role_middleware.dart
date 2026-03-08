import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';

/// Middleware that redirects based on the authenticated user's role.
class RoleMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();

    if (!auth.isLoggedIn) {
      return const RouteSettings(name: '/auth');
    }

    if (auth.isAdmin) {
      return const RouteSettings(name: '/admin');
    }

    return const RouteSettings(name: '/user');
  }
}

