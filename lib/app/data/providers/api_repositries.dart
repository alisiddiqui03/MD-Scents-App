import 'package:dio/dio.dart';
import 'package:md_scents_app/app/core/constant/http_constants.dart';
import 'package:md_scents_app/app/core/services/api_services.dart';
import 'package:md_scents_app/app/data/models/auth_model.dart';
import 'package:md_scents_app/app/data/models/get_profile_model.dart';
import 'package:md_scents_app/app/data/models/rewards_model.dart';

class ApiRepositories {
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(response.data);
    } else {
      throw Exception(response.data['message'] ?? "Login failed");
    }
  }

  Future<GetProfile> getCustomerProfile() async {
    try {
      final response = await ApiService.get(ApiEndpoints.customerProfile);

      if (response.statusCode == 200) {
        return GetProfile.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? "Failed to load profile");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Network error");
    }
  }

  Future<Reward> getrewards() async {
    try {
      final response = await ApiService.get(ApiEndpoints.rewards);

      if (response.statusCode == 200) {
        return Reward.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? "Failed to load profile");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Network error");
    }
  }
}
