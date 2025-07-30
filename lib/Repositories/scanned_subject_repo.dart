import 'package:dio/dio.dart';
import 'package:pfa/Model/scanned_subject_model.dart';

class NewSubjectRepository {
  // Use the Dio instance from DioClient
  final Dio _dio; // Declare as final, initialized via constructor

  // Base path for subject-related PHP scripts
  // This should match the directory where your PHP subject files are located (e.g., backend/Gestionnaire/Subjects/)
  static const String _subjectsPath = 'Gestionnaire/Subjects';

  // Constructor for dependency injection of Dio
  NewSubjectRepository({required Dio dio}) : _dio = dio;

  //* Fetches a list of all subjects from the backend.
  /// Returns a [List<Subject>] on success.
  /// Throws an [Exception] if the fetch operation fails.
  Future<List<NewSubject>> fetchSubjects() async {
    try {
      // Corrected endpoint name to match 'get_subjects.php'
      final response = await _dio.get('$_subjectsPath/get_subjects.php');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final List<dynamic> subjectJsonList = response.data['data'] ?? [];
          return subjectJsonList.map((json) => NewSubject.fromJson(json)).toList();
        } else {
          // Backend returned 200 OK, but status is not 'success' (e.g., 'error' with a message)
          throw Exception(
            response.data['message'] ??
                'Failed to fetch subjects with unknown status.',
          );
        }
      } else {
        // HTTP status code is not 200 or response.data is null
        throw Exception(
          'Failed to fetch subjects: ${response.statusMessage ?? 'Unknown server response'}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network or server error while fetching subjects.';
      if (e.response != null) {
        errorMessage =
            'Server error (${e.response!.statusCode}): ${e.response!.data['message'] ?? e.response!.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error fetching subjects: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching subjects: $e');
      throw Exception('An unexpected error occurred while fetching subjects.');
    }
  }

  //* Adds a new subject to the backend.
  /// Returns the newly created [Subject] object on success (with its ID).
  /// Throws an [Exception] if the add operation fails.
  Future<NewSubject> addSubject(NewSubject subject) async {
    try {
      // Endpoint for adding a subject
      final response = await _dio.post(
        '$_subjectsPath/add_subject.php', // Matches 'add_subject.php'
        data: subject.toJson(), // Sends subject data as JSON
      );

      // PHP might send 200 OK or 201 Created for successful addition
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data != null && response.data['status'] == 'success') {
          if (response.data['data'] is Map<String, dynamic>) {
            return NewSubject.fromJson(
              response.data['data'],
            ); // Parse the full subject data
          } else {
            throw Exception(
              'Failed to add subject: Missing or invalid "data" field in response.',
            );
          }
        } else {
          throw Exception(
            'Failed to add subject: ${response.data?['message'] ?? 'Unknown server error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to add subject with status code: ${response.statusCode}. Message: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add subject due to a network error.';
      if (e.response != null) {
        errorMessage =
            'Server responded with status ${e.response?.statusCode}: ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error adding subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error adding subject: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //* Updates an existing subject on the backend.
  /// Returns the updated [Subject] object on success.
  /// Throws an [Exception] if the update operation fails.
  Future<NewSubject> updateSubject(NewSubject subject) async {
    try {
      if (subject.subjectID == null) {
        throw Exception('Subject ID is required for updating a subject.');
      }
      // Endpoint for updating a subject
      final response = await _dio.post(
        // PHP uses POST for 'update_subject.php'
        '$_subjectsPath/update_subject.php', // Matches 'update_subject.php'
        data: subject.toJson(), // Sends subject data as JSON
      );

      if (response.statusCode == 200) {
        // Backend can return 'success' or 'info' (e.g., if no changes were made)
        if (response.data != null &&
            (response.data['status'] == 'success' ||
                response.data['status'] == 'info')) {
          // If the backend returns the updated data, parse it.
          // Otherwise, assume the input subject is the updated one.
          if (response.data['data'] is Map<String, dynamic>) {
            return NewSubject.fromJson(response.data['data']);
          } else {
            // If backend doesn't return data, return the original subject as it was successfully processed
            return subject;
          }
        } else {
          throw Exception(
            'Failed to update subject: ${response.data?['message'] ?? 'Unknown server error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to update subject with status code: ${response.statusCode}. Message: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update subject due to a network error.';
      if (e.response != null) {
        errorMessage =
            'Server responded with status ${e.response?.statusCode}: ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error updating subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error updating subject: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //* Deletes a subject from the backend by ID.
  /// Returns a [String] message indicating success.
  /// Throws an [Exception] if the delete operation fails.
  Future<String> deleteSubject(int subjectID) async {
    try {
      // Endpoint for deleting a subject. Using DELETE method with ID in query param.
      final response = await _dio.post(
        // Changed to POST to match PHP file
        '$_subjectsPath/delete_subject.php', // Matches 'delete_subject.php'
        data: {'SubjectID': subjectID}, // Send ID in body for POST
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data['status'] == 'success') {
          return response.data['message'] ?? 'Subject deleted successfully.';
        } else {
          throw Exception(
            'Failed to delete subject: ${response.data?['message'] ?? 'Unknown server error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to delete subject with status code: ${response.statusCode}. Message: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete subject due to a network error.';
      if (e.response != null) {
        errorMessage =
            'Server responded with status ${e.response?.statusCode}: ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error deleting subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error deleting subject: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
