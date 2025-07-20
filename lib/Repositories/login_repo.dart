import 'package:dio/dio.dart';
import 'package:pfa/Model/Login/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../Services/login_service.dart';

class LoginRepository extends ChangeNotifier {
  final LoginService loginService;
  late final _token;
  LoginRepository({required this.loginService});
  Future<void> setToken(String token) async {
    _token = token;
    // Optionally, persist the token using SharedPreferences if needed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    notifyListeners();
  }

  //* Login
  Future<LoginResponse> loginUser(String email, String password) async {
    try {
      final response = await loginService.login(email, password);
      if (response['status'] == 'success') {
        debugPrint('LoginRepo: Login successful. Calling notifyListeners().');
        notifyListeners();
      }
      return LoginResponse.fromJson(response);
    } on DioException catch (e) {
      debugPrint('LoginRepository DioError: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      debugPrint('LoginRepository General Error: $e');
      rethrow;
    }
  }

  //* Get Token
  Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token');
      if (token != null) {
        debugPrint(
          'LoginRepository: Token retrieved from SharedPreferences: ${token.length} chars.',
        );
      } else {
        debugPrint('LoginRepository: No token found in SharedPreferences.');
      }
      return token;
    } catch (e) {
      debugPrint('LoginRepository Error in getToken: $e');
      return null;
    }
  }

  //* Delete Token
  Future<void> deleteToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      debugPrint('LoginRepository: Token deleted. Calling notifyListeners().');
      notifyListeners();
    } catch (e) {
      debugPrint('LoginRepository Error deleting token: $e');
    }
  }

  Future<String?> getUserRoleFromToken() async {
    final String? token = await getToken();
    if (token == null) {
      debugPrint('LoginRepository: No token to get role from.');
      return null;
    }
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid JWT format for role extraction.');
        return null;
      }
      final String payload = parts[1];
      String normalizedPayload = base64Url.normalize(payload);
      final String decodedPayload = utf8.decode(
        base64Url.decode(normalizedPayload),
      );
      final Map<String, dynamic> data = json.decode(decodedPayload)['data'];
      final String? role = data['role'] as String?;
      debugPrint('LoginRepository: Decoded role: $role');
      return role;
    } catch (e) {
      debugPrint('LoginRepository Error decoding JWT or getting role: $e');
      return null;
    }
  }

  Future<int?> getUserIdFromToken() async {
    final String? token = await getToken();
    if (token == null) {
      return null;
    }
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid JWT format for user ID extraction.');
        return null;
      }
      final String payload = parts[1];
      String normalizedPayload = base64Url.normalize(payload);
      final String decodedPayload = utf8.decode(
        base64Url.decode(normalizedPayload),
      );
      final Map<String, dynamic> data = json.decode(decodedPayload)['data'];
      return data['userID'] as int?;
    } catch (e) {
      debugPrint('LoginRepository Error decoding JWT or getting user ID: $e');
      return null;
    }
  }
}
