// lib/utils/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // Correct import

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'jwt_token',
    ); // THIS IS WHERE IT RETRIEVES THE SAVED TOKEN

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('Adding Authorization header to ${options.path}');
    } else {
      debugPrint('No JWT token found for request to ${options.path}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    // You can optionally print response data here for debugging:
    // debugPrint('Response data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      debugPrint('401 Unauthorized: Token might be invalid or expired.');
      // TODO: Implement robust logout/token refresh logic here.
      // A common pattern is to use a global event bus or NavigatorKey to
      // trigger a logout and redirection to the login screen, e.g.:
      // if (navigatorKey.currentContext != null) {
      //   Provider.of<LoginRepository>(navigatorKey.currentContext!, listen: false).deleteToken();
      //   navigatorKey.currentContext!.go('/login');
      // }
    }
    super.onError(err, handler);
  }
}
