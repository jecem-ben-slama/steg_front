import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart'; // For debugPrint
import 'package:pfa/Model/internship_model.dart';
// You might need to import EvaluationToValidate if you're consolidating
// ChefCentreRepository methods into this file, as discussed previously.
// import 'package:pfa/Model/evaluation_validation.dart';

class InternshipRepository {
  static const String gestionnairePath = '/Gestionnaire/Stage';
  static const String _chefCentrePath =
      '/ChefCentre'; // Added for Chef Centre specific paths
  final Dio _dio;

  InternshipRepository({required Dio dio}) : _dio = dio;

  //* Fetch all internships (General list, accessible by Gestionnaire)
  Future<List<Internship>> fetchAllInternships() async {
    try {
      final response = await _dio.get('$gestionnairePath/list_stage.php');
      debugPrint(
        'fetchAllInternships response: ${response.data}',
      ); // Added debug print

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
        data: internship.toJson(), // Send the internship object as JSON
      );
      debugPrint(
        'addInternship response: ${response.data}',
      ); // Added debug print

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
      debugPrint(
        'deleteInternship response: ${response.data}',
      ); // Added debug print

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
      debugPrint(
        'updateInternship response: ${response.data}',
      ); // Added debug print

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

  // OLD: fetchInternshipsByStatus - Replaced by fetchProposedInternshipsForChef() for Chef-specific use
  // If other parts of your app *do* need to filter by any status, you might keep
  // a general method, but for the Chef's dashboard, the dedicated one is cleaner.
  //
  // Future<List<Internship>> fetchInternshipsByStatus(String status) async {
  //   try {
  //     final response = await _dio.get(
  //       '$gestionnairePath/list_stage.php',
  //       queryParameters: {'statut': status},
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = response.data;
  //       if (responseData['status'] == 'success') {
  //         final List<dynamic> internshipJsonList = responseData['data'];
  //         return internshipJsonList
  //             .map((json) => Internship.fromJson(json))
  //             .toList();
  //       } else {
  //         throw Exception(
  //           'Failed to fetch internships: ${responseData['message']}',
  //         );
  //       }
  //     } else {
  //       debugPrint(
  //         'Failed to fetch internships by status $status: ${response.statusCode}: ${response.data}',
  //       );
  //       throw Exception('Failed to fetch internships by status');
  //     }
  //   } on DioException catch (e) {
  //     debugPrint('DioException fetching internships by status: ${e.message}');
  //     debugPrint('Error Response: ${e.response?.data}');
  //     throw Exception('Failed to fetch internships by status: ${e.message}');
  //   } catch (e) {
  //     debugPrint('Error fetching internships by status: $e');
  //     throw Exception('An unexpected error occurred: $e');
  //   }
  // }

  //*Fetch "Proposé" internships specifically for ChefCentre
  Future<List<Internship>> fetchProposedInternships() async {
    try {
      final response = await _dio.get(
        '$_chefCentrePath/list_stages_proposes.php',
      );
      debugPrint('fetchProposedInternshipsForChef response: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // The backend might return 'info' status if no proposed stages are found,
        // which is still a successful request from a communication standpoint.
        if (responseData['status'] == 'success' ||
            responseData['status'] == 'info') {
          final List<dynamic> internshipJsonList =
              responseData['data'] ?? []; // Ensure it's not null
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
        '$_chefCentrePath/update_internship_status.php', // Use the Chef Centre path
        data: {
          'stageID':
              internshipId, // Ensure this key matches backend expectation
          'statut': newStatus, // Ensure this key matches backend expectation
        },
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
          return Internship.fromJson(
            responseData['data'] ?? {},
          ); // Assuming updated data is in 'data' key
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

  // If you also want to include the Evaluation validation methods here,
  // ensure EvaluationToValidate model is imported and add them below:

  // //* Fetch All Evaluations Pending Validation for Chef Centre
  // Future<List<EvaluationToValidate>> getEvaluationsToValidate() async {
  //   try {
  //     final response = await _dio.get(
  //       '$_chefCentrePath/get_evaluations.php',
  //     );
  //     debugPrint('getEvaluationsToValidate response: ${response.data}');
  //
  //     if (response.statusCode == 200 &&
  //         response.data != null &&
  //         response.data['status'] == 'success') {
  //       final List<dynamic> evaluationJsonList = response.data['data'];
  //       return evaluationJsonList
  //           .map((json) => EvaluationToValidate.fromJson(json))
  //           .toList();
  //     } else {
  //       throw Exception(
  //         'Failed to fetch evaluations: ${response.data?['message'] ?? response.statusMessage}',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     String errorMessage = 'Failed to fetch evaluations.';
  //     if (e.response != null) {
  //       errorMessage =
  //           'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
  //     } else {
  //       errorMessage = 'Network error: ${e.message}';
  //     }
  //     debugPrint('Dio Error fetching evaluations for validation: $errorMessage');
  //     throw Exception(errorMessage);
  //   } catch (e) {
  //     debugPrint('General Error fetching evaluations for validation: $e');
  //     rethrow;
  //   }
  // }
  //
  // //* Validate or Reject an Evaluation
  // Future<Map<String, dynamic>> validateOrRejectEvaluation({
  //   required int evaluationID,
  //   required String actionType, // 'validate' or 'reject'
  // }) async {
  //   try {
  //     final Map<String, dynamic> data = {
  //       'evaluationID': evaluationID,
  //       'actionType': actionType,
  //     };
  //
  //     final response = await _dio.post(
  //       '$_chefCentrePath/validate_evaluation.php',
  //       data: data,
  //     );
  //     debugPrint('validateOrRejectEvaluation response: ${response.data}');
  //
  //     if (response.statusCode == 200 &&
  //         response.data != null &&
  //         response.data['status'] == 'success') {
  //       return response.data; // This will contain status and message
  //     } else {
  //       throw Exception(
  //         'Failed to $actionType evaluation: ${response.data?['message'] ?? response.statusMessage}',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     String errorMessage = 'Failed to $actionType evaluation.';
  //     if (e.response != null) {
  //       errorMessage =
  //           'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
  //     } else {
  //       errorMessage = 'Network error: ${e.message}';
  //     }
  //     debugPrint('Dio Error ${actionType}ing evaluation: $errorMessage');
  //     throw Exception(errorMessage);
  //   } catch (e) {
  //     debugPrint('General Error ${actionType}ing evaluation: $e');
  //     rethrow;
  //   }
  // }
}
