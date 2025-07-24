import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../Model/subject_model.dart'; // Adjust path as needed
import '../Repositories/subject_repo.dart'; // Adjust path as needed

// --- States ---
abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

// Represents the state when subjects are successfully loaded.
// Can carry an optional message from a previous action.
class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  final String?
  message; // Message from a completed action (e.g., add/update/delete)
  const SubjectLoaded(this.subjects, {this.message});

  @override
  List<Object?> get props => [subjects, message];
}

// Represents a successful action (add, update, delete) with a specific message.
// This is useful for showing ephemeral UI feedback like Snackbars or in-popup messages.
class SubjectActionSuccess extends SubjectState {
  final String message;
  final String actionType; // e.g., 'add', 'update', 'delete'
  const SubjectActionSuccess(this.message, this.actionType);

  @override
  List<Object?> get props => [message, actionType];
}

// SubjectActionInfo state is removed as per your request to simplify update messages.
// If you ever need it back, uncomment this and the related logic.
/*
class SubjectActionInfo extends SubjectState {
  final String message;
  final String actionType; // e.g., 'update'
  const SubjectActionInfo(this.message, this.actionType);

  @override
  List<Object?> get props => [message, actionType];
}
*/

// Represents an error state, including a message and optionally the last known good data.
class SubjectError extends SubjectState {
  final String message;
  final List<Subject>?
  lastLoadedSubjects; // To keep the UI showing data on action error
  const SubjectError(this.message, {this.lastLoadedSubjects});

  @override
  List<Object?> get props => [message, lastLoadedSubjects];
}

// --- Cubit ---
class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository _subjectRepository;

  SubjectCubit(this._subjectRepository) : super(SubjectInitial());

  // Helper to get current subjects for error/success states
  List<Subject>? _getCurrentSubjects() {
    if (state is SubjectLoaded) {
      return (state as SubjectLoaded).subjects;
    } else if (state is SubjectError) {
      return (state as SubjectError).lastLoadedSubjects;
    }
    return null;
  }

  // Refetches subjects and updates the UI.
  // This is called after any CUD operation to refresh the list.
  Future<void> _refetchAndEmitLoaded({String? message}) async {
    try {
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects, message: message));
    } catch (e) {
      emit(
        SubjectError(
          'Failed to refresh subject list after action: ${e.toString()}',
        ),
      );
    }
  }

  /// Fetches all subjects and updates the state.
  Future<void> fetchSubjects() async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
    } catch (e) {
      emit(
        SubjectError(
          'Failed to load subjects: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
    }
  }

  /// Adds a new subject and refreshes the list.
  Future<void> addSubject(Subject subject) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final newSubject = await _subjectRepository.addSubject(subject);
      final message = 'Subject "${newSubject.subjectName}" added successfully!';
      emit(SubjectActionSuccess(message, 'add'));
      await _refetchAndEmitLoaded(message: message);
    } catch (e) {
      emit(
        SubjectError(
          'Error adding subject: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded();
    }
  }

  /// Updates an existing subject and refreshes the list.
  Future<void> updateSubject(Subject subject) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      // The repository will return the updated subject or the original if no changes were made.
      // We are now simplifying the Cubit's message to always be "updated successfully"
      // if the repository call itself didn't throw an error.
      await _subjectRepository.updateSubject(
        subject,
      ); // No need to capture return value if not comparing
      final message =
          'Subject updated successfully!'; // Generic success message
      emit(SubjectActionSuccess(message, 'update'));
      await _refetchAndEmitLoaded(message: message);
    } catch (e) {
      emit(
        SubjectError(
          'Error updating subject: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded();
    }
  }

  /// Deletes a subject by ID and refreshes the list.
  Future<void> deleteSubject(int subjectID) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final message = await _subjectRepository.deleteSubject(subjectID);
      emit(SubjectActionSuccess(message, 'delete'));
      await _refetchAndEmitLoaded(message: message);
    } catch (e) {
      emit(
        SubjectError(
          'Error deleting subject: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded();
    }
  }
}
