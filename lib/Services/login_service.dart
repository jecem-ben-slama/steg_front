import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = 'http://localhost/backend';

  final Dio dio;
  LoginService()
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type':
                'application/json', 
          },
        ),
      ) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }


  //* Save token in SharedPreferences
  Future<void> setJwtToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('jwt_token', token);
    } catch (e) {
      debugPrint('ApiService Error saving JWT token: $e');
    }
  }
//* Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/Auth/login.php',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        if (response.data['token'] != null) {
          await setJwtToken(response.data['token']);
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
