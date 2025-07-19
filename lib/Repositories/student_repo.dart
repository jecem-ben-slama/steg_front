// lib/repositories/student_repo.dart
import 'package:dio/dio.dart';
import 'package:pfa/Model/student_model.dart'; // Adjust path if needed

class StudentRepository {
  static const String studentsPath = 'Gestionnaire/Student';
  final Dio _dio;

  StudentRepository({required Dio dio}) : _dio = dio;

  Future<List<Student>> fetchStudents() async {
    try {
      final response = await _dio.get('$studentsPath/list_students.php');
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        final List<dynamic> studentJsonList = response.data['data'];
        return studentJsonList.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch students: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch students.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error fetching students: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error fetching students: $e');
      rethrow;
    }
  }

  Future<Student> addStudent(Student student) async {
    try {
      final response = await _dio.post(
        '$studentsPath/add_student.php',
        data: student.toJson(),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        // Assuming your add_student.php returns the new student object under 'data' key
        return Student.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to add student: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add student.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error adding student: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error adding student: $e');
      rethrow;
    }
  }

  Future<Student> updateStudent(Student student) async {
    try {
      if (student.studentID == null) {
        throw Exception('Student ID is required for updating a student.');
      }
      final response = await _dio.post(
        // Assuming POST for updates, adjust if using PUT
        '$studentsPath/edit_student.php',
        data: student.toJson(),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        // Assuming your edit_student.php returns the updated student object under 'data' key
        return Student.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to update student: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update student.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error updating student: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error updating student: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(int studentID) async {
    try {
      final response = await _dio.post(
        // Assuming POST for deletes, adjust if using DELETE
        '$studentsPath/delete_student.php',
        data: {'studentID': studentID}, // Pass the ID in the request body
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return; // Successfully deleted, no data expected back
      } else {
        throw Exception(
          'Failed to delete student: ${response.data?['message'] ?? response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete student.';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Dio Error deleting student: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('General Error deleting student: $e');
      rethrow;
    }
  }
}
