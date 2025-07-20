import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/student_model.dart';
import 'package:pfa/repositories/student_repo.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students;
  const StudentLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentActionSuccess extends StudentState {
  final String message;
  const StudentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository _studentRepository;

  StudentCubit(this._studentRepository) : super(StudentInitial());
  //* Fetch all students
  Future<void> fetchStudents() async {
    try {
      emit(StudentLoading());
      final students = await _studentRepository.fetchStudents();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError('Failed to load students: ${e.toString()}'));
    }
  }
//* Add a new student
  Future<void> addStudent(Student student) async {
    try {
      emit(StudentLoading()); // Or a more specific state like StudentAdding
      final newStudent = await _studentRepository.addStudent(student);
      // After adding, refetch the list to update the UI
      final updatedStudents = await _studentRepository.fetchStudents();
      emit(StudentLoaded(updatedStudents));
      emit(
        StudentActionSuccess('Student added successfully!'),
      ); // Send success message
    } catch (e) {
      emit(StudentError('Error adding student: ${e.toString()}'));
    }
  }
//* Update student
  Future<void> updateStudent(Student student) async {
    try {
      emit(StudentLoading()); // Or StudentUpdating
      final updatedStudent = await _studentRepository.updateStudent(student);
      // After updating, refetch the list to update the UI
      final students = await _studentRepository.fetchStudents();
      emit(StudentLoaded(students));
      emit(
        StudentActionSuccess('Student updated successfully!'),
      ); // Send success message
    } catch (e) {
      emit(StudentError('Error updating student: ${e.toString()}'));
    }
  }
///* Delete student
  Future<void> deleteStudent(int studentID) async {
    try {
      emit(StudentLoading());
      await _studentRepository.deleteStudent(studentID);
      final students = await _studentRepository.fetchStudents();
      emit(StudentLoaded(students));
      emit(StudentActionSuccess('Student deleted successfully!'));
    } catch (e) {
      emit(StudentError('Error deleting student: ${e.toString()}'));
    }
  }
}
