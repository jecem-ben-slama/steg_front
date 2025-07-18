// lib/repositories/internship_repo.dart
import 'package:dio/dio.dart';
import 'package:pfa/Model/internship_model.dart';

class InternshipRepository {
  static const String gestionnairePath =
      '/Gestionnaire'; // This path is for GET/DELETE
  // Correct path for your update script, assuming it's directly under 'api/'
  final Dio _dio; // The Dio instance will be injected

  InternshipRepository({required Dio dio}) : _dio = dio;

  //* Fetch all internships
  Future<List<Internship>> fetchAllInternships() async {
    try {
      final response = await _dio.get('$gestionnairePath/list_stage.php');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          final List<dynamic> internshipJsonList = responseData['data'];
          return internshipJsonList
              .map((json) => Internship.fromJson(json))
              .toList();
        } else {
          throw Exception(
            'Failed to fetch internships: ${responseData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load internships. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch internships.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching internships: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching internships: $e');
      rethrow;
    }
  }

  //* Delete an internship
  Future<bool> deleteInternship(int internshipId) async {
    try {
      final response = await _dio.delete(
        '$gestionnairePath/delete_stage.php',
        queryParameters: {'stageID': internshipId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          return true; // Deletion was successful
        } else {
          throw Exception(
            'Failed to delete internship: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to delete internship. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete internship.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error deleting internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error deleting internship: $e');
      rethrow;
    }
  }

  //* Edit an internship
  Future<bool> updateInternship(Internship internship) async {
    try {
      final response = await _dio.put(
        '$gestionnairePath/edit_stage.php', // Use the dedicated path for update
        data: internship.toJson(), // Convert the Internship object to JSON
        // Dio automatically sets Content-Type: application/json if data is a Map
        // Ensure your Dio interceptor (if any) or base options handle Authorization header.
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' ||
            responseData['status'] == 'info') {
          // 'info' for no changes made
          return true; // Update was successful or no changes needed
        } else {
          // If the backend returns a 'status: error' or similar
          throw Exception(
            'Failed to update internship: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        // Handle non-200 status codes (e.g., 404 Not Found, 400 Bad Request)
        throw Exception(
          'Failed to update internship. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update internship.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
        print(
          'Dio response data for update error: ${e.response?.data}',
        ); // More detailed error
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error updating internship: $errorMessage');
      throw Exception(errorMessage); // Re-throw as a generic Exception
    } catch (e) {
      print('General Error updating internship: $e');
      rethrow; // Re-throw any other unexpected errors
    }
  }
}
