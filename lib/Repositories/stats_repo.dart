// lib/repositories/stats_repository.dart
import 'package:dio/dio.dart';
import 'package:pfa/Model/Stats/internships_distribution.dart';
import 'package:pfa/Model/Stats/kpi_model.dart';

class StatsRepository {
  final Dio _dio; // Dio instance injected via constructor

  // Constructor: Takes a Dio instance
  StatsRepository({required Dio dio}) : _dio = dio;

  //* Fetch Key Performance Indicator (KPI) Data (No change here)
  Future<KpiData> getKpiData() async {
    try {
      final response = await _dio.get('/Stats/get_kpis.php');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return KpiData.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to fetch KPI data: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch KPI data.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching KPI data: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching KPI data: $e');
      rethrow;
    }
  }

  //* Fetch All Internship Distribution Data (Status, Type, Duration, Encadrant, Faculty, Subject)
  // Change the return type to Future<Data>
  Future<Data> getAllInternshipDistributions() async {
    try {
      final response = await _dio.get('/Stats/internship_distribution.php');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        // Parse the entire JSON response into your top-level InternshipDistribution model
        final InternshipDistribution internshipDistribution =
            InternshipDistribution.fromJson(response.data);

        // Return the 'data' part of that model
        if (internshipDistribution.data != null) {
          return internshipDistribution
              .data!; // Using ! because 'success' implies data
        } else {
          throw Exception(
            'Failed to parse internship distributions: Data field is null.',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch all internship distributions: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch all internship distributions.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching all internship distributions: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching all internship distributions: $e');
      rethrow;
    }
  }
}
