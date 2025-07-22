import 'package:dio/dio.dart';
import 'package:pfa/Model/finished_internship_model.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Model/note_model.dart'; // Import the NoteModel

class EncadrantRepository {
  static const String _encadrantPath =
      'Encadrant'; // Base path for Encadrant APIs
  final Dio _dio; // Dio instance injected via constructor

  // Constructor: Takes a Dio instance (typically from AuthService)
  EncadrantRepository({required Dio dio}) : _dio = dio;

  //* Fetch All Assigned Internships for Encadrant
  Future<List<Internship>> getAssignedInternships() async {
    try {
      final response = await _dio.get(
        '$_encadrantPath/get_encadrant_internships.php',
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> internshipJsonList = response.data['data'];
        return internshipJsonList
            .map((json) => Internship.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch internships: ${response.data?['message'] ?? response.statusMessage}',
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
      rethrow; // Re-throw any other unexpected errors
    }
  }

  //* Fetch Internship Notes (NEW METHOD)
  Future<List<Note>> getInternshipNotes(int stageID) async {
    try {
      final response = await _dio.get(
        '$_encadrantPath/get_internship_notes.php',
        queryParameters: {
          'stageID': stageID,
        }, // Pass stageID as a query parameter
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> notesJsonList = response.data['data'];
        return notesJsonList.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch notes: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch notes.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching notes: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching notes: $e');
      rethrow;
    }
  }

  //* Add Internship Note
  Future<int> addInternshipNote(int stageID, String contenuNote) async {
    try {
      final response = await _dio.post(
        '$_encadrantPath/add_internship_note.php',
        data: {'stageID': stageID, 'contenuNote': contenuNote},
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        // Assuming your add_internship_note.php returns 'noteID' upon success
        return response.data['noteID'] as int;
      } else {
        throw Exception(
          'Failed to add note: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add note.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error adding note: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error adding note: $e');
      rethrow;
    }
  }

 
 //** Fetch Finished Internships
  Future<List<FinishedInternship>> getFinishedInternships() async {
    try {
      final response = await _dio.get(
        '$_encadrantPath/get_finished_internships.php',
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> internshipJsonList = response.data['data'];
        return internshipJsonList
            .map((json) => FinishedInternship.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch finished internships: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch finished internships.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching finished internships: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching finished internships: $e');
      rethrow;
    }
  }

  //** Evaluate Internship 
  Future<Map<String, dynamic>> evaluateInternship({
    required int stageID,
    required String actionType,
    double? note,
    String? commentaires,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'stageID': stageID,
        'actionType': actionType,
      };

      if (note != null) {
        data['note'] = note;
      }
      // Send empty string for comments if null, as per PHP backend
      data['commentaires'] = commentaires ?? '';

      final response = await _dio.post(
        '$_encadrantPath/evaluate_internship.php', // Renamed from validate_internship.php
        data: data,
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return response.data; // This will contain evaluationID, status, message
      } else {
        throw Exception(
          'Failed to evaluate internship: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to evaluate internship.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error evaluating internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error evaluating internship: $e');
      rethrow;
    }
  }
 
 
  }
