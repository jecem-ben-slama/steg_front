// lib/Services/login_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // For saving token

class LoginService {
  // Remove the static baseUrl here, it's handled by the Dio instance passed in.
  final Dio dio;

  // Accept a Dio instance in the constructor
  LoginService({required this.dio});

  // No longer a separate setJwtToken method, it's done within login

  //* Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/Auth/login.php', // Path is relative to the Dio's baseUrl
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        if (response.data['token'] != null) {
          // Save the JWT token directly in SharedPreferences here
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', response.data['token']);
          debugPrint('LoginService: JWT token saved to SharedPreferences.');
        }
      }

      return response.data;
    } on DioException catch (e) {
      debugPrint('Login DioError: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Login General Error: $e');
      rethrow;
    }
  }
}
