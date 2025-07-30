import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/scanned_subject_model.dart';
import 'package:pfa/Repositories/scanned_subject_repo.dart';

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
  final List<NewSubject> subjects;
  final String?
  message; // Message from a completed action (e.g., add/update/delete)
  const SubjectLoaded(this.subjects, {this.message});

  @override
  List<Object?> get props => [subjects, message];
}

// Represents a successful action (add, update, delete) with a specific message.
// This is useful for showing ephemeral UI feedback like Snackbars.
class SubjectActionSuccess extends SubjectState {
  final String message;
  final String actionType; // e.g., 'add', 'update', 'delete'
  const SubjectActionSuccess(this.message, this.actionType);

  @override
  List<Object?> get props => [message, actionType];
}

// Represents an action that completed with "info" status (e.g., no changes made on update).
class SubjectActionInfo extends SubjectState {
  final String message;
  final String actionType; // e.g., 'update'
  const SubjectActionInfo(this.message, this.actionType);

  @override
  List<Object?> get props => [message, actionType];
}

// Represents an error state, including a message and optionally the last known good data.
class SubjectError extends SubjectState {
  final String message;
  final List<NewSubject>?
  lastLoadedSubjects; // To keep the UI showing data on action error
  const SubjectError(this.message, {this.lastLoadedSubjects});

  @override
  List<Object?> get props => [message, lastLoadedSubjects];
}

// --- Cubit ---
class SubjectCubit extends Cubit<SubjectState> {
  final NewSubjectRepository _subjectRepository;

  SubjectCubit(this._subjectRepository) : super(SubjectInitial());

  // Helper to get current subjects for error/success states
  List<NewSubject>? _getCurrentSubjects() {
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
    final currentSubjects =
        _getCurrentSubjects(); // Capture for potential error fallback
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
  Future<void> addSubject(NewSubject subject) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final newSubject = await _subjectRepository.addSubject(subject);
      emit(
        SubjectActionSuccess(
          'Subject "${newSubject.title}" added successfully!',
          'add',
        ),
      ); // Use newSubject.title
      await _refetchAndEmitLoaded(
        message: 'Subject "${newSubject.title}" added successfully!',
      ); // Refetch and update main state
    } catch (e) {
      emit(
        SubjectError(
          'Error adding subject: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }

  /// Updates an existing subject and refreshes the list.
  Future<void> updateSubject(NewSubject subject) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final updatedSubject = await _subjectRepository.updateSubject(subject);
      // Check if actual changes were made based on the returned subject or a comparison
      final message =
          (updatedSubject.title == subject.title &&
              updatedSubject.description == subject.description &&
              updatedSubject.pdfFileUrl == subject.pdfFileUrl)
          ? 'Subject data is already up-to-date (no changes made).'
          : 'Subject "${updatedSubject.title}" updated successfully!';

      if (message.contains('no changes made')) {
        emit(
          SubjectActionInfo(message, 'update'),
        ); // Specific info state for UI listener
      } else {
        emit(
          SubjectActionSuccess(message, 'update'),
        ); // Specific success state for UI listener
      }
      await _refetchAndEmitLoaded(
        message: message,
      ); // Refetch and update main state
    } catch (e) {
      emit(
        SubjectError(
          'Error updating subject: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }

  /// Deletes a subject by ID and refreshes the list.
  Future<void> deleteSubject(int subjectID) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final message = await _subjectRepository.deleteSubject(subjectID);
      emit(
        SubjectActionSuccess(message, 'delete'),
      ); // Specific success state for UI listener
      await _refetchAndEmitLoaded(
        message: message,
      ); // Refetch and update main state
    } catch (e) {
      emit(
        SubjectError(
          'Error deleting subject: ${e.toString()}',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }
}
