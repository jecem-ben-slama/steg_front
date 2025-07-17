// lib/repositories/login_repo.dart
import 'package:dio/dio.dart';
import 'package:pfa/Model/Login/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../Services/login_service.dart';

class LoginRepository extends ChangeNotifier {
  final LoginService loginService;

  LoginRepository({required this.loginService});

  //* Login
  Future<LoginResponse> loginUser(String email, String password) async {
    try {
      // The loginService.login method now handles saving the token directly.
      final response = await loginService.login(email, password);
      if (response['status'] == 'success') {
        debugPrint('LoginRepo: Login successful. Calling notifyListeners().');
        // Notify listeners (GoRouter) that authentication status might have changed.
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
      // Notify listeners (GoRouter) that authentication status has changed (logged out).
      notifyListeners();
    } catch (e) {
      debugPrint('LoginRepository Error deleting token: $e');
    }
  }

  // Helper to parse the role from the JWT payload
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
      // JWT payloads are base64url encoded. Ensure correct decoding.
      String normalizedPayload = base64Url.normalize(payload);
      final String decodedPayload = utf8.decode(
        base64Url.decode(normalizedPayload),
      );
      // Assuming your JWT payload has a 'data' object with 'role' inside it.
      // Adjust 'data' and 'role' keys based on your actual JWT structure.
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
      // Assuming your JWT payload has a 'data' object with 'userID' inside it.
      // Adjust 'data' and 'userID' keys based on your actual JWT structure.
      final Map<String, dynamic> data = json.decode(decodedPayload)['data'];
      return data['userID'] as int?;
    } catch (e) {
      debugPrint('LoginRepository Error decoding JWT or getting user ID: $e');
      return null;
    }
  }
}
