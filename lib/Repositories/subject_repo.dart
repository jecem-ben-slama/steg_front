// lib/repositories/subject_repo.dart
import 'package:dio/dio.dart';
import '../Model/subject_model.dart'; // Adjust path as needed

class SubjectRepository {
  static const String _subjectsPath = 'Gestionnaire/Sujets';

  final Dio _dio;

  SubjectRepository({required Dio dio}) : _dio = dio;

  //* Fetches all subjects
  Future<List<Subject>> fetchSubjects() async {
    try {
      final response = await _dio.get('$_subjectsPath/list_sujet.php');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final List<dynamic> subjectJsonList = response.data['data'] ?? [];
          return subjectJsonList.map((json) => Subject.fromJson(json)).toList();
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

  //* Adds a new subject
  Future<Subject> addSubject(Subject subject) async {
    try {
      print('--- Subject Add Request ---');
      print('Request URL: ${_dio.options.baseUrl}$_subjectsPath/add_sujet.php');
      print('Request Data: ${subject.toJson()}');
      print('---------------------------');

      final response = await _dio.post(
        '$_subjectsPath/add_sujet.php',
        data: subject.toJson(), // Sends subject data as JSON
      );

      print('--- Subject Add Raw Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Data (raw): ${response.data}'); // THIS IS CRUCIAL
      print('Response Headers: ${response.headers}'); // Check Content-Type here
      print('---------------------------');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // PHP might send 200 or 201
        if (response.data != null && response.data['status'] == 'success') {
          if (response.data['data'] is Map<String, dynamic>) {
            final parsedSubject = Subject.fromJson(response.data['data']);
            print('Parsed Subject from response.data[data]: $parsedSubject');
            return parsedSubject; // Parse the full subject data
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
        print(
          'Dio Error Response Data: ${e.response?.data}',
        ); // Log server's error response
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

  //* Updates an existing subject
  Future<Subject> updateSubject(Subject subject) async {
    try {
      if (subject.subjectID == null) {
        throw Exception('Subject ID is required for updating a subject.');
      }
      final response = await _dio.post(
        // PHP uses POST for edit_sujet.php
        '$_subjectsPath/edit_sujet.php',
        data: subject.toJson(), // Sends subject data as JSON
      );

      if (response.statusCode == 200) {
        if (response.data != null &&
            (response.data['status'] == 'success' ||
                response.data['status'] == 'info')) {
          if (response.data['data'] is Map<String, dynamic>) {
            return Subject.fromJson(
              response.data['data'],
            ); // Parse the full subject data
          } else {
            // If backend returns success/info but no data (e.g., for "no changes made")
            // Reconstruct the subject from the input, assuming it was updated successfully.
            // This is a common pattern if the backend doesn't echo back the full object.
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

  //* Deletes a subject by ID
  Future<String> deleteSubject(int subjectID) async {
    try {
      final response = await _dio.delete(
        // PHP uses DELETE for delete_sujet.php
        '$_subjectsPath/delete_sujet.php?sujetID=$subjectID', // Pass ID as query parameter
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
