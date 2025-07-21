import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/student_model.dart';
import 'package:pfa/repositories/student_repo.dart'; // Make sure this path is correct

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
      emit(StudentLoading()); // Indicate loading
      await _studentRepository.addStudent(student); // Perform the add
      final updatedStudents = await _studentRepository
          .fetchStudents(); // Refetch
      emit(StudentLoaded(updatedStudents)); // Emit loaded state with new data
      // No StudentActionSuccess here, the UI will show SnackBar after the call completes successfully.
    } catch (e) {
      emit(StudentError('Error adding student: ${e.toString()}'));
    }
  }

  //* Update student
  Future<void> updateStudent(Student student) async {
    try {
      emit(StudentLoading()); // Indicate loading
      await _studentRepository.updateStudent(student); // Perform the update
      final students = await _studentRepository.fetchStudents(); // Refetch
      emit(StudentLoaded(students)); // Emit loaded state with new data
      // No StudentActionSuccess here
    } catch (e) {
      emit(StudentError('Error updating student: ${e.toString()}'));
    }
  }

  //* Delete student
  Future<void> deleteStudent(int studentID) async {
    try {
      emit(StudentLoading());
      await _studentRepository.deleteStudent(studentID);
      final students = await _studentRepository.fetchStudents(); // Refetch
      emit(StudentLoaded(students)); // Emit loaded state with new data
      // No StudentActionSuccess here
    } catch (e) {
      emit(StudentError('Error deleting student: ${e.toString()}'));
    }
  }
}
