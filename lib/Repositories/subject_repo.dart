import 'package:dio/dio.dart';
import 'package:pfa/Model/subject_model.dart';

class SubjectRepository {
  static const String subjectsPath = 'Gestionnaire/Sujets';
  final Dio _dio;

  SubjectRepository({required Dio dio}) : _dio = dio;
  //* Fetch All Subjects
  Future<List<Subject>> fetchSubjects() async {
    try {
      final response = await _dio.get('$subjectsPath/list_sujet.php');
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> subjectJsonList = response.data['data'];
        return subjectJsonList.map((json) => Subject.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch subjects: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch subjects.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching subjects: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching subjects: $e');
      rethrow;
    }
  }

  //* Add Subject
  Future<Subject> addSubject(Subject subject) async {
    try {
      final response = await _dio.post(
        '$subjectsPath/add_sujet.php',
        data: subject.toJson(), // Send the subject object as JSON body
      );

      // Check for successful response from the PHP script
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        // Parse the 'data' part of the response into a Subject object
        return Subject.fromJson(response.data['data']);
      } else {
        // If status is not 'success' or data is malformed
        throw Exception(
          'Failed to add subject: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      // Dio specific error handling (network issues, server errors)
      String errorMessage = 'Failed to add subject.';
      if (e.response != null) {
        // Server responded with an error status code
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        // Network error (e.g., no internet, server unreachable)
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error adding subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      // General unexpected errors
      print('General Error adding subject: $e');
      rethrow; // Re-throw to be caught by BLoC/Cubit
    }
  }

  //* Update Subject
  Future<Subject> updateSubject(Subject subject) async {
    try {
      if (subject.subjectID == null) {
        throw Exception('Subject ID is required for updating a subject.');
      }
      final response = await _dio.post(
        '$subjectsPath/edit_sujet.php',
        data: subject.toJson(),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return Subject.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to update subject: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update subject.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error updating subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error updating subject: $e');
      rethrow;
    }
  }

  //* Delete Subject
  Future<void> deleteSubject(int subjectID) async {
    try {
      final response = await _dio.post(
        '$subjectsPath/delete_sujet.php?sujetID=$subjectID',
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return;
      } else {
        throw Exception(
          'Failed to delete subject: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete subject.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error deleting subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error deleting subject: $e');
      rethrow;
    }
  }
}
