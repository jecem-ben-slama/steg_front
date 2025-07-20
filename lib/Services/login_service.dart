import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class LoginService {
  final Dio dio;

  LoginService({required this.dio});


  //* Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/Auth/login.php', 
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        if (response.data['token'] != null) {
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
