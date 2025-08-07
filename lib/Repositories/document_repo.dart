// lib/Repositories/document_repo.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart'; // Import for base64Encode

class DocumentRepository {
  final Dio _dio;

  DocumentRepository({required Dio dio}) : _dio = dio;

  Future<void> savePdfDocumentToBackend({
    required int stageId,
    required Uint8List pdfBytes,
    required String pdfType,
    required String
    filename, // 'filename' is not directly used in PHP, but useful for naming the file locally before sending.
  }) async {
    const String apiUrl = 'Gestionnaire/save_pdf.php';

    try {
      // Encode the PDF bytes to a Base64 string
      String pdfBase64 = base64Encode(pdfBytes);

      // Create a JSON payload
      Map<String, dynamic> requestBody = {
        'stageID': stageId,
        'pdfBase64': pdfBase64,
        'pdfType': pdfType,
        // The 'filename' parameter from Flutter isn't directly used by the PHP
        // script for saving the file name, as PHP uses type, stageID, and uniqid().
        // However, it can be passed if your PHP logic were to change.
        // For now, it's not strictly necessary in the JSON payload for your current PHP.
      };

      final response = await _dio.post(
        apiUrl,
        data: jsonEncode(requestBody), // Send the JSON payload
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Specify JSON content type
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // PHP returns 201 (Created) for success
        // Check PHP's 'status' field in the JSON response
        if (response.data is Map && response.data['status'] == 'success') {
          debugPrint('PDF saved successfully to backend.');
          debugPrint('Backend Response: ${response.data}');
        } else {
          // Backend returned 200/201, but indicated an error or unexpected format
          throw Exception(
            'Backend reported an error: ${response.data['message'] ?? 'Unknown error in response'}',
          );
        }
      } else {
        // Handle non-200/201 HTTP status codes
        String errorMessage =
            'Server returned status code: ${response.statusCode}';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMessage += ' - ${response.data['message']}';
        } else if (response.data != null) {
          errorMessage += ' - ${response.data.toString()}';
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Network or server error while saving PDF: ';
      if (e.response != null) {
        debugPrint('Dio Error response data: ${e.response!.data}');
        debugPrint('Dio Error response status: ${e.response!.statusCode}');
        if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage += e.response!.data['message']; // <--- THIS LINE!
        } else {
          errorMessage += e.response!.data.toString();
        }
      } else {
        errorMessage += e.message ?? 'Unknown Dio error';
      }
      debugPrint('Dio Error: $e'); // Log the full DioException for more details
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint(
        'An unexpected error occurred in savePdfDocumentToBackend: $e',
      );
      throw Exception('An unexpected error occurred while saving PDF: $e');
    }
  }

  //*Fetch Documents
  Future<String> fetchDocumentUrl({
    required int stageId,
    required String pdfType,
  }) async {
    // This endpoint should return the URL of the saved PDF for a given stageID and pdfType
    // You might need to create a new PHP script for this, e.g., 'get_document_url.php'
    const String apiUrl = 'Gestionnaire/get_document_url.php';

    try {
      final response = await _dio.get(
        apiUrl,
        queryParameters: {'stageID': stageId, 'pdfType': pdfType},
      );

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['status'] == 'success') {
          final String? url = response.data['url'];
          if (url != null && url.isNotEmpty) {
            debugPrint('Document URL fetched successfully: $url');
            return url;
          } else {
            throw Exception(
              'URL not found in backend response for stageID: $stageId, type: $pdfType',
            );
          }
        } else {
          throw Exception(
            'Backend reported an error fetching URL: ${response.data['message'] ?? 'Unknown error in response'}',
          );
        }
      } else {
        String errorMessage =
            'Server returned status code: ${response.statusCode}';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMessage += ' - ${response.data['message']}';
        } else if (response.data != null) {
          errorMessage += ' - ${response.data.toString()}';
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage =
          'Network or server error while fetching document URL: ';
      if (e.response != null) {
        debugPrint('Dio Error response data: ${e.response!.data}');
        debugPrint('Dio Error response status: ${e.response!.statusCode}');
        if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage += e.response!.data['message'];
        } else {
          errorMessage += e.response!.data.toString();
        }
      } else {
        errorMessage += e.message ?? 'Unknown Dio error';
      }
      debugPrint('Dio Error: $e');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('An unexpected error occurred in fetchDocumentUrl: $e');
      throw Exception(
        'An unexpected error occurred while fetching document URL: $e',
      );
    }
  }
}
