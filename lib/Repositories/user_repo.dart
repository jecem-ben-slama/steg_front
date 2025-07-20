import 'package:dio/dio.dart';
import 'package:pfa/Model/user_model.dart';

class UserRepository {
  static const String usersPath = '/User';
  final Dio _dio;

  UserRepository({required Dio dio}) : _dio = dio;

  //* Fetch All Users (if no role is specified)
  Future<List<User>> fetchAllUsers() async {
    return _fetchUsers('$usersPath/list_users.php');
  }

  //* Fetch Users by Role
  Future<List<User>> fetchUsersByRole(String role) async {
    return _fetchUsers('$usersPath/list_users.php?roles=$role');
  }

  Future<List<User>> _fetchUsers(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          final List<dynamic> userJsonList = responseData['data'];
          return userJsonList.map((json) => User.fromJson(json)).toList();
        } else {
          throw Exception(
            'Failed to fetch users: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to load users. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch users.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching users: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching users: $e');
      rethrow;
    }
  }

  //* Add a new User
  Future<User> addUser(User user) async {
    try {
      if (user.password == null || user.password!.isEmpty) {
        throw Exception('Password is required for new user creation.');
      }
      final response = await _dio.post(
        '$usersPath/add_user.php',
        data: user.toJson(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception(
            'Failed to add user: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to add user. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add user.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error adding user: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error adding user: $e');
      rethrow;
    }
  }

  //* Update an existing User
  Future<User> updateUser(User user) async {
    try {
      if (user.userID == null) {
        throw Exception('User ID is required for updating a user.');
      }
      final response = await _dio.post(
        '$usersPath/edit_user.php',
        data: user.toJson(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception(
            'Failed to update user: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to update user. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update user.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error updating user: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error updating user: $e');
      rethrow;
    }
  }

  //* Delete a User
  Future<void> deleteUser(int userID) async {
    try {
      final response = await _dio.post(
        '$usersPath/delete_user.php',
        data: {'userID': userID},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] != 'success') {
          throw Exception(
            'Failed to delete user: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to delete user. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete user.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error deleting user: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error deleting user: $e');
      rethrow;
    }
  }
}
