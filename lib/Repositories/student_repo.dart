import 'package:dio/dio.dart';
import 'package:pfa/Model/student_model.dart';

class StudentRepository {
  static const String studentsPath = 'Gestionnaire/Student';
  final Dio _dio;

  StudentRepository({required Dio dio}) : _dio = dio;

  //* Fetch All Students
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

  //* Add Student
  Future<String> addStudent(Student student) async {
    // Return type is now String
    try {
      final response = await _dio.post(
        '$studentsPath/add_student.php',
        data: student.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          // It now just returns the message from the backend.
          // It doesn't attempt to parse a full Student object from a 'data' field.
          return response.data['message'] ?? 'Student added successfully.';
        } else {
          // If server doesn't return data for add, but indicates success,
          // you might return the original student object or refetch.
          // For now, throwing to indicate missing data if expected.
          throw Exception(
            'Student added successfully, but no data returned from server.',
          );
        }
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

  //* Update Student
  Future<void> updateStudent(Student student) async {
    // Changed return type to Future<void>
    try {
      if (student.studentID == null) {
        throw Exception('Student ID is required for updating a student.');
      }
      final response = await _dio.post(
        '$studentsPath/update_student.php',
        data: student.toJson(),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        // Server confirmed success, but returned no 'data' field.
        // So, we don't try to parse it into a Student object.
        // We just return void to indicate success.
        return;
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

  //* Delete Student
  Future<void> deleteStudent(int studentID) async {
    try {
      final response = await _dio.post(
        '$studentsPath/delete_student.php',
        data: {'etudiantID': studentID},
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == 'success') {
        return;
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
