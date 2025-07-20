import 'package:dio/dio.dart';
import 'package:pfa/Model/internship_model.dart';

class InternshipRepository {
  static const String gestionnairePath = '/Gestionnaire/Stage';
  final Dio _dio;

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
//* Add an internship
  Future<Internship> addInternship(Internship internship) async {
    try {
      // The backend screenshot (image_0b9f03.png) shows a POST request to add_stage.php
      final response = await _dio.post(
        '$gestionnairePath/add_stage.php',
        data: internship.toJson(), // Send the internship object as JSON
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          
 final int? newStageId = int.tryParse(
            responseData['stageID']?.toString() ?? '',
          );
          if (newStageId != null) {
            // Create a new Internship instance with the returned ID
            // and the original data, as other fields are not returned by the backend.
            return internship.copyWith(internshipID: newStageId);
          } else {
            throw Exception(
              'Failed to add internship: Returned stageID is missing or invalid.',
            );
          }
        } else {
          throw Exception(
            'Failed to add internship: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to add internship. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add internship.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
        print('Dio response data for add error: ${e.response?.data}');
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error adding internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error adding internship: $e');
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
        '$gestionnairePath/edit_stage.php',
        data: internship.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' ||
            responseData['status'] == 'info') {
          return true;
        } else {
          throw Exception(
            'Failed to update internship: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to update internship. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update internship.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
        print('Dio response data for update error: ${e.response?.data}');
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error updating internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error updating internship: $e');
      rethrow;
    }
  }
}
