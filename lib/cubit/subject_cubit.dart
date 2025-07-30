import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../Model/subject_model.dart';
import '../Repositories/subject_repo.dart';

// --- States ---

abstract class SubjectState extends Equatable {
  const SubjectState();
  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  final String? message;
  const SubjectLoaded(this.subjects, {this.message});
  @override
  List<Object?> get props => [subjects, message];
}

class SubjectActionSuccess extends SubjectState {
  final String message;
  final String actionType;
  const SubjectActionSuccess(this.message, this.actionType);
  @override
  List<Object?> get props => [message, actionType];
}

class SubjectError extends SubjectState {
  final String message;
  final List<Subject>? lastLoadedSubjects;
  const SubjectError(this.message, {this.lastLoadedSubjects});
  @override
  List<Object?> get props => [message, lastLoadedSubjects];
}

// --- Cubit ---

class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository _subjectRepository;
  SubjectCubit(this._subjectRepository) : super(SubjectInitial());

  List<Subject>? _getCurrentSubjects() {
    if (state is SubjectLoaded) {
      return (state as SubjectLoaded).subjects;
    } else if (state is SubjectError) {
      return (state as SubjectError).lastLoadedSubjects;
    }
    return null;
  }

  Future<void> _refetchAndEmitLoaded({String? message}) async {
    try {
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects, message: message));
    } catch (e) {
      emit(SubjectError('Failed to refresh subject list: $e'));
    }
  }

  Future<void> fetchSubjects() async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
    } catch (e) {
      emit(
        SubjectError(
          'Failed to load subjects: $e',
          lastLoadedSubjects: currentSubjects,
        ),
      );
    }
  }

  // Modified: Now passes pdfBytes and pdfFilename directly to repository
  Future<void> addSubject(
    Subject subject, {
    Uint8List? pdfBytes,
    String? pdfFilename,
  }) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      // The pdfUrl will now be handled internally by the repository's addSubject
      // based on whether pdfBytes and pdfFilename are provided.
      // So, no need to create subjectToAdd with pdfUrl here.
      // Just pass the original subject and the file details.
      final newSubject = await _subjectRepository.addSubject(
        subject, // Pass the original subject
        pdfBytes: pdfBytes,
        pdfFilename: pdfFilename,
      );

      final message = 'Subject "${newSubject.subjectName}" added successfully!';
      emit(SubjectActionSuccess(message, 'add'));
      await _refetchAndEmitLoaded(message: message);
    } catch (e) {
      emit(
        SubjectError(
          'Error adding subject: $e',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      // It's generally good to refetch even on error to show the current state
      // unless you want to preserve the loading state after an error.
      await _refetchAndEmitLoaded();
    }
  }

  // Modified: Now passes pdfBytes and pdfFilename directly to repository
  Future<void> updateSubject(
    Subject subject, {
    Uint8List? pdfBytes,
    String? pdfFilename,
  }) async {
    final currentSubjects = _getCurrentSubjects();
    emit(SubjectLoading());
    try {
      // The pdfUrl will be managed by the repository's updateSubject method
      // based on pdfBytes, pdfFilename, or the existing subject.pdfUrl.
      // So, no need to create subjectToUpdate with pdfUrl here.
      await _subjectRepository.updateSubject(
        subject, // Pass the original subject
        pdfBytes: pdfBytes,
        pdfFilename: pdfFilename,
      );

      const message = 'Subject updated successfully!';
      emit(SubjectActionSuccess(message, 'update'));
      await _refetchAndEmitLoaded(message: message);
    } catch (e) {
      emit(
        SubjectError(
          'Error updating subject: $e',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded();
    }
  }

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
          'Error deleting subject: $e',
          lastLoadedSubjects: currentSubjects,
        ),
      );
      await _refetchAndEmitLoaded();
    }
  }
}
