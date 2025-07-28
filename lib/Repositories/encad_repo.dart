// lib/Repositories/encadrant_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../Model/encadrant_model.dart'; // Import your Encadrant model

class EncadrantRepository1 {
  static const String _gestionnairePath =
      'Gestionnaire'; // Base path for Gestionnaire endpoints
  final Dio _dio;

  EncadrantRepository1({required Dio dio}) : _dio = dio;

  // Method to add a new Encadrant
  Future<Encadrant> addEncadrant(Encadrant encadrant) async {
    try {
      final response = await _dio.post(
        '$_gestionnairePath/add_encadrant.php', // Path to your add PHP script
        data: encadrant.toJson(),
      );
      debugPrint('addEncadrant response: ${response.data}');

      if (response.statusCode == 201 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return Encadrant.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to add encadrant: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add encadrant.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
        debugPrint('Dio response data for add error: ${e.response?.data}');
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error adding encadrant: $e');
      rethrow;
    }
  }

  // Method to get all Encadrants
  Future<List<Encadrant>> getAllEncadrants() async {
    try {
      final response = await _dio.get(
        '$_gestionnairePath/get_all_encadrants.php',
      ); // Path to your fetch all PHP script
      debugPrint('getAllEncadrants response: ${response.data}');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> encadrantJsonList = response.data['data'];
        return encadrantJsonList
            .map((json) => Encadrant.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch encadrants: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch encadrants.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
        debugPrint('Dio response data for fetch error: ${e.response?.data}');
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('General Error fetching encadrants: $e');
      rethrow;
    }
  }

  // You can add updateEncadrant and deleteEncadrant methods here later
  // based on new PHP scripts for those operations.
}
