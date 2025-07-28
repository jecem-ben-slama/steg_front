// lib/Repositories/internship_repo.dart
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart'; // For debugPrint
import 'package:pfa/Model/attestation_model.dart'; // Import the updated AttestationData model
import 'package:pfa/Model/internship_model.dart'; // Assuming you have this model

class InternshipRepository {
  static const String gestionnairePath = '/Gestionnaire/Stage';
  static const String _chefCentrePath = '/ChefCentre';
  final Dio _dio;

  InternshipRepository({required Dio dio}) : _dio = dio;

  //* Fetch all internships (General list, accessible by Gestionnaire)
  Future<List<Internship>> fetchAllInternships() async {
    try {
      final response = await _dio.get('$gestionnairePath/list_stage.php');
      debugPrint('fetchAllInternships response: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          final List<dynamic> internshipJsonList = responseData['data'];
          return internshipJsonList
              .map((json) => Internship.fromJson(json))
              .toList();
        } else {
          throw Exception(
            'Failed to fetch internships: ${responseData['message'] ?? 'Unknown error.'}',
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
      debugPrint('Dio Error fetching internships: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error fetching internships: $e');
      rethrow;
    }
  }

  //* Add an internship
  Future<Internship> addInternship(Internship internship) async {
    try {
      final response = await _dio.post(
        '$gestionnairePath/add_stage.php',
        data: internship.toJson(),
      );
      debugPrint('addInternship response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          final int? newStageId = int.tryParse(
            responseData['stageID']?.toString() ?? '',
          );
          if (newStageId != null) {
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
        debugPrint('Dio response data for add error: ${e.response?.data}');
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      debugPrint('Dio Error adding internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error adding internship: $e');
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
      debugPrint('deleteInternship response: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          return true;
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
      debugPrint('Dio Error deleting internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error deleting internship: $e');
      rethrow;
    }
  }

  //* Edit an internship (general update)
  Future<bool> updateInternship(Internship internship) async {
    try {
      final response = await _dio.put(
        '$gestionnairePath/edit_stage.php',
        data: internship.toJson(),
      );
      debugPrint('updateInternship response: ${response.data}');

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
        debugPrint('Dio response data for update error: ${e.response?.data}');
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      debugPrint('Dio Error updating internship: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error updating internship: $e');
      rethrow;
    }
  }

  //*Fetch "Proposé" internships specifically for ChefCentre
  Future<List<Internship>> fetchProposedInternships() async {
    try {
      final response = await _dio.get(
        '$_chefCentrePath/list_stages_proposes.php',
      );
      debugPrint('fetchProposedInternshipsForChef response: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' ||
            responseData['status'] == 'info') {
          final List<dynamic> internshipJsonList = responseData['data'] ?? [];
          return internshipJsonList
              .map((json) => Internship.fromJson(json))
              .toList();
        } else {
          throw Exception(
            'Failed to fetch proposed internships: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch proposed internships. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException fetching proposed internships: ${e.message}');
      debugPrint('Error Response: ${e.response?.data}');
      String errorMessage =
          'Failed to fetch proposed internships: ${e.message}';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error fetching proposed internships: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //* Update an internship's status, used by chefCentre
  Future<Internship> updateInternshipStatus(
    int? internshipId,
    String newStatus,
  ) async {
    if (internshipId == null) {
      throw ArgumentError('internshipId cannot be null for status update.');
    }
    try {
      final response = await _dio.put(
        '$_chefCentrePath/update_internship_status.php',
        data: {'stageID': internshipId, 'statut': newStatus},
      );
      debugPrint(
        'updateInternshipStatus response for ID $internshipId to $newStatus: ${response.data}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          debugPrint(
            'Internship status updated successfully: ${responseData['message']}',
          );
          return Internship.fromJson(responseData['data'] ?? {});
        } else {
          throw Exception(
            'Failed to update internship status: ${responseData['message'] ?? 'Unknown error.'}',
          );
        }
      } else {
        debugPrint(
          'Failed to update internship status ${response.statusCode}: ${response.data}',
        );
        throw Exception('Failed to update internship status');
      }
    } on DioException catch (e) {
      debugPrint('DioException updating internship status: ${e.message}');
      debugPrint('Error Response: ${e.response?.data}');
      String errorMessage = 'Failed to update internship status: ${e.message}';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error updating internship status: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //* Fetch internships that are Terminated and Evaluated (for attestation list)
  Future<List<Internship>> fetchTerminatedAndEvaluatedInternships() async {
    try {
      final response = await _dio.get(
        'Gestionnaire/get_validated_internships.php',
      );
      debugPrint(
        'fetchTerminatedAndEvaluatedInternships response: ${response.data}',
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> internshipsJson = response.data['data'];
        return internshipsJson
            .map((json) => Internship.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch terminated and evaluated internships: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  //* Fetch a single attestation data (for Gestionnaire to view existing)
  Future<AttestationData> getAttestationData(int stageID) async {
    try {
      final response = await _dio.post(
        'Gestionnaire/get_attestation_data.php',
        data: {'stageID': stageID},
      );
      debugPrint(
        'getAttestationData (Gestionnaire) response: ${response.data}',
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        // The PHP get_attestation_data.php returns the data nested under 'data' key
        return AttestationData.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to fetch attestation data (Gestionnaire): ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

}
