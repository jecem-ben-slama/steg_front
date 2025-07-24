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
  final String?
  message; // Added optional message for successful loads after actions
  const StudentLoaded(this.students, {this.message});

  @override
  List<Object?> get props => [students, message];
}

class StudentActionSuccess extends StudentState {
  final String message;
  final String
  actionType; // e.g., 'add', 'update', 'delete' for UI differentiation
  const StudentActionSuccess(this.message, this.actionType);

  @override
  List<Object?> get props => [message, actionType];
}

class StudentError extends StudentState {
  final String message;
  final List<Student>?
  lastLoadedStudents; // Added to keep previous data on error
  const StudentError(this.message, {this.lastLoadedStudents});

  @override
  List<Object?> get props => [message, lastLoadedStudents];
}

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository _studentRepository;

  StudentCubit(this._studentRepository) : super(StudentInitial());

  // Helper to get current students for error/success states
  List<Student>? _getCurrentStudents() {
    if (state is StudentLoaded) {
      return (state as StudentLoaded).students;
    } else if (state is StudentError) {
      return (state as StudentError).lastLoadedStudents;
    }
    return null;
  }

  // Helper to refetch students and emit StudentLoaded state, optionally with a message
  Future<void> _refetchAndEmitLoaded({String? message}) async {
    try {
      final students = await _studentRepository.fetchStudents();
      emit(StudentLoaded(students, message: message));
    } catch (e) {
      // If refetching fails, emit an error that doesn't clear the previous list
      emit(
        StudentError(
          'Failed to refresh student list after action: ${e.toString()}',
          lastLoadedStudents: _getCurrentStudents(),
        ),
      );
    }
  }

  //* Fetch all students
  Future<void> fetchStudents() async {
    final currentStudents =
        _getCurrentStudents(); // Capture current state for potential error fallback
    emit(StudentLoading());
    try {
      final students = await _studentRepository.fetchStudents();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(
        StudentError(
          'Failed to load students: ${e.toString()}',
          lastLoadedStudents: currentStudents,
        ),
      );
    }
  }

  //* Add a new student
  Future<void> addStudent(Student student) async {
    final currentStudents = _getCurrentStudents();
    emit(StudentLoading()); // Indicate loading for the action
    try {
      // The repository's addStudent returns a String message, not a Student object.
      await _studentRepository.addStudent(student); // Perform the add
      final message = 'Student added successfully!';
      emit(StudentActionSuccess(message, 'add')); // Emit action success state
      await _refetchAndEmitLoaded(
        message: message,
      ); // Refetch and update main list
    } catch (e) {
      emit(
        StudentError(
          'Error adding student: ${e.toString()}',
          lastLoadedStudents: currentStudents,
        ),
      );
      await _refetchAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }

  //* Update student
  Future<void> updateStudent(Student student) async {
    final currentStudents = _getCurrentStudents();
    emit(StudentLoading()); // Indicate loading for the action
    try {
      await _studentRepository.updateStudent(student); // Perform the update

      final message = 'Student updated successfully!';
      emit(
        StudentActionSuccess(
          message,
          'update',
        ), // Emit action success state FIRST
      );

      // Now, refetch and update the main list.
      // This will cause a new StudentLoaded state, which will update the list.
      // The message from StudentActionSuccess should have been processed by the UI.
      await _refetchAndEmitLoaded(); // No need to pass message here, as it's already handled by StudentActionSuccess
    } catch (e) {
      emit(
        StudentError(
          'Error updating student: ${e.toString()}',
          lastLoadedStudents: currentStudents,
        ),
      );
      await _refetchAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }

  //* Delete student
  Future<void> deleteStudent(int studentID) async {
    final currentStudents = _getCurrentStudents();
    emit(StudentLoading()); // Indicate loading for the action
    try {
      await _studentRepository.deleteStudent(
        studentID,
      ); // Call the repository to perform deletion

      final message = 'Student deleted successfully!';
      emit(
        StudentActionSuccess(message, 'delete'), // Emit action success state
      );
      await _refetchAndEmitLoaded(
        message: message,
      ); // Refetch and update main list
    } catch (e) {
      emit(
        StudentError(
          'Error deleting student: ${e.toString()}',
          lastLoadedStudents: currentStudents,
        ),
      );
      await _refetchAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }
}
