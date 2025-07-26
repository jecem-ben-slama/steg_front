// lib/repositories/chef_centre_repository.dart
import 'package:dio/dio.dart';
import 'package:pfa/Model/evaluation_validation.dart';

class ChefCentreRepository {
  static const String _chefCentrePath =
      'ChefCentre'; // Base path for Chef Centre APIs
  final Dio _dio; // Dio instance injected via constructor

  // Constructor: Takes a Dio instance
  ChefCentreRepository({required Dio dio}) : _dio = dio;

  //* Fetch All Evaluations Pending Validation for Chef Centre
  Future<List<EvaluationToValidate>> getEvaluationsToValidate() async {
    try {
      final response = await _dio.get(
        '$_chefCentrePath/get_evaluations.php',
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> evaluationJsonList = response.data['data'];
        return evaluationJsonList
            .map((json) => EvaluationToValidate.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch evaluations: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch evaluations.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching evaluations for validation: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching evaluations for validation: $e');
      rethrow; // Re-throw any other unexpected errors
    }
  }

  //* Validate or Reject an Evaluation
  Future<Map<String, dynamic>> validateOrRejectEvaluation({
    required int evaluationID,
    required String actionType, // 'validate' or 'reject'
  }) async {
    try {
      final Map<String, dynamic> data = {
        'evaluationID': evaluationID,
        'actionType': actionType,
      };

     

      final response = await _dio.post(
        '$_chefCentrePath/validate_evaluation.php',
        data: data,
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return response.data; // This will contain status and message
      } else {
        throw Exception(
          'Failed to $actionType evaluation: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to $actionType evaluation.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error ${actionType}ing evaluation: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error ${actionType}ing evaluation: $e');
      rethrow;
    }
  }
}
