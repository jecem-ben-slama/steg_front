// lib/repositories/internship_repo.dart
import 'package:dio/dio.dart';
import 'package:pfa/Model/internship_model.dart';

class InternshipRepository {
  // _gestionnairePath is relative to the Dio's baseUrl set in main.dart
  static const String gestionnairePath = '/Gestionnaire';
  final Dio _dio; // The Dio instance will be injected

  // Constructor now REQUIRES a Dio instance
  InternshipRepository({required Dio dio}) : _dio = dio;
  //* Fetch all internships
  Future<List<Internship>> fetchAllInternships() async {
    try {
      // Use the injected _dio instance.
      // The full URL will be: baseUrl/Gestionnaire/list_stages.php
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
          // If the backend returns a 'status: fail' or similar
          throw Exception(
            'Failed to delete internship: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        // Handle non-200 status codes (e.g., 404 Not Found, 400 Bad Request)
        throw Exception(
          'Failed to delete internship. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete internship.';
      if (e.response != null) {
        // Try to parse server-provided error message
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error deleting internship: $errorMessage');
      throw Exception(errorMessage); // Re-throw as a generic Exception
    } catch (e) {
      print('General Error deleting internship: $e');
      rethrow; // Re-throw any other unexpected errors
    }
  }
//* Edit an internship
Future<bool> updateInternship(Internship internship) async {
    try {
   
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay
      if (internship.internshipID == 999) {
        // Example: Simulate failure for a specific ID
        throw Exception('Simulated update failure for ID 999');
      }
      return true; // Assume success for now
    } catch (e) {
      print('Error in InternshipRepository.updateInternship: $e');
      throw Exception(
        'Failed to update internship: $e',
      ); // Re-throw for Cubit to catch
    }
  }
  // Your commented-out addStage method is fine, just ensure it uses _dio.post
  /*
  Future<void> addStage(...) async {
    try {
      final response = await _dio.post(
        '$_gestionnairePath/add_stage.php', // Example path
        data: {
          // Your data for adding a stage
        },
      );
      // Handle response
    } on DioException catch (e) {
      // Handle error
      rethrow;
    }
  }
  */
}
