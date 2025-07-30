// lib/repositories/subject_repo.dart
import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../Model/subject_model.dart';

class SubjectRepository {
  static const String _subjectsPath = 'Gestionnaire/Sujets';

  final Dio _dio;

  SubjectRepository({required Dio dio}) : _dio = dio;

  // Fetch all subjects
  Future<List<Subject>> fetchSubjects() async {
    try {
      final response = await _dio.get('$_subjectsPath/list_sujet.php');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final List<dynamic> subjectJsonList = response.data['data'] ?? [];
          return subjectJsonList.map((json) => Subject.fromJson(json)).toList();
        } else {
          throw Exception(
            response.data['message'] ?? 'Failed to fetch subjects.',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch subjects: ${response.statusMessage ?? 'Unknown error'}',
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
      throw Exception('Unexpected error while fetching subjects.');
    }
  }

  // REMOVED: uploadPdfFile method is no longer needed as it's merged into addSubject and updateSubject.
  // The backend's add_sujet.php handles the PDF directly.

  // Add new subject
  Future<Subject> addSubject(
    Subject subject, {
    Uint8List? pdfBytes,
    String? pdfFilename,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'titre': subject.subjectName,
        'description':
            subject.description ?? '', // Ensure description is not null
      });

      if (pdfBytes != null && pdfFilename != null) {
        formData.files.add(
          MapEntry(
            'pdfFile', // This key must match the name of your file input in PHP ($_FILES['pdfFile'])
            MultipartFile.fromBytes(pdfBytes, filename: pdfFilename),
          ),
        );
      }

      print('--- Subject Add Request ---');
      print('URL: ${_dio.options.baseUrl}$_subjectsPath/add_sujet.php');
      print('FormData (fields): ${formData.fields}');
      print('FormData (files): ${formData.files.map((e) => e.key).toList()}');
      print('---------------------------');

      final response = await _dio.post(
        '$_subjectsPath/add_sujet.php',
        data: formData,
        // Dio automatically sets Content-Type for FormData
        // options: Options(headers: {"Content-Type": "multipart/form-data"}), // No longer explicitly needed
      );

      print('--- Subject Add Response ---');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      print('---------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['status'] == 'success') {
          final subjectData = data['data'];
          if (subjectData != null && subjectData is Map<String, dynamic>) {
            return Subject.fromJson(subjectData);
          } else {
            throw Exception('Invalid or missing "data" in response.');
          }
        } else {
          throw Exception(data?['message'] ?? 'Failed to add subject.');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error while adding subject.';
      if (e.response != null) {
        errorMessage =
            'Server error ${e.response?.statusCode}: ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error adding subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error adding subject: $e');
      throw Exception('Unexpected error while adding subject.');
    }
  }

  // Update existing subject
  Future<Subject> updateSubject(
    Subject subject, {
    Uint8List? pdfBytes,
    String? pdfFilename,
  }) async {
    try {
      if (subject.subjectID == null) {
        throw Exception('Subject ID is required for update.');
      }

      FormData formData = FormData.fromMap({
        'sujetID': subject.subjectID, // Include subject ID for update
        'titre': subject.subjectName,
        'description': subject.description ?? '',
      });

      if (pdfBytes != null && pdfFilename != null) {
        // If a new PDF is provided, upload it
        formData.files.add(
          MapEntry(
            'pdfFile', // This key must match the name of your file input in PHP ($_FILES['pdfFile'])
            MultipartFile.fromBytes(pdfBytes, filename: pdfFilename),
          ),
        );
      } else if (subject.pdfUrl != null && subject.pdfUrl!.isNotEmpty) {
        // If no new PDF is uploaded, but there was an existing one,
        // send its URL so the backend knows to keep it.
        // Your backend update_sujet.php should handle this to preserve the existing PDF.
        formData.fields.add(MapEntry('pdfUrl', subject.pdfUrl!));
      } else {
        // If no new PDF and no existing PDF, you might want to send a flag
        // or just omit the pdfUrl field, depending on your backend's logic for clearing a PDF.
        // For example, if 'pdfUrl' can be explicitly set to an empty string to remove it.
        formData.fields.add(
          MapEntry('pdfUrl', ''),
        ); // Explicitly send empty if no PDF
      }

      print('--- Subject Update Request ---');
      print('URL: ${_dio.options.baseUrl}$_subjectsPath/edit_sujet.php');
      print('FormData (fields): ${formData.fields}');
      print('FormData (files): ${formData.files.map((e) => e.key).toList()}');
      print('---------------------------');

      final response = await _dio.post(
        '$_subjectsPath/edit_sujet.php',
        data: formData,
        // Dio automatically sets Content-Type for FormData
        // options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      print('--- Subject Update Response ---');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      print('---------------------------');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null &&
            (data['status'] == 'success' || data['status'] == 'info')) {
          final subjectData = data['data'];
          if (subjectData != null && subjectData is Map<String, dynamic>) {
            return Subject.fromJson(subjectData);
          } else {
            return subject; // fallback to original subject if no updated data returned
          }
        } else {
          throw Exception(data?['message'] ?? 'Failed to update subject.');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error while updating subject.';
      if (e.response != null) {
        errorMessage =
            'Server error ${e.response?.statusCode}: ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error updating subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error updating subject: $e');
      throw Exception('Unexpected error while updating subject.');
    }
  }

  // Delete subject by ID
  Future<String> deleteSubject(int subjectID) async {
    try {
      final response = await _dio.delete(
        '$_subjectsPath/delete_sujet.php',
        queryParameters: {
          'sujetID': subjectID,
        }, // Use queryParameters for DELETE with ID
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data['status'] == 'success') {
          return response.data['message'] ?? 'Subject deleted successfully.';
        } else {
          throw Exception(
            'Failed to delete subject: ${response.data?['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to delete subject with status ${response.statusCode}.',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error while deleting subject.';
      if (e.response != null) {
        errorMessage =
            'Server error ${e.response?.statusCode}: ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Connection error: ${e.message}';
      }
      print('Dio Error deleting subject: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error deleting subject: $e');
      throw Exception('Unexpected error while deleting subject.');
    }
  }
}
