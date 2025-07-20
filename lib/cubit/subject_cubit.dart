import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/subject_model.dart';
import 'package:pfa/repositories/subject_repo.dart';

abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  const SubjectLoaded(this.subjects);

  @override
  List<Object?> get props => [subjects];
}

class SubjectActionSuccess extends SubjectState {
  final String message;
  const SubjectActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SubjectError extends SubjectState {
  final String message;
  const SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository _subjectRepository;

  SubjectCubit(this._subjectRepository) : super(SubjectInitial());

  Future<void> fetchSubjects() async {
    try {
      emit(SubjectLoading());
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
    } catch (e) {
      emit(SubjectError('Failed to load subjects: ${e.toString()}'));
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      emit(SubjectLoading());
      final newSubject = await _subjectRepository.addSubject(subject);
      final updatedSubjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(updatedSubjects));
      emit(SubjectActionSuccess('Subject added successfully!'));
    } catch (e) {
      emit(SubjectError('Error adding subject: ${e.toString()}'));
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      emit(SubjectLoading()); // Or SubjectUpdating
      final updatedSubject = await _subjectRepository.updateSubject(subject);
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
      emit(SubjectActionSuccess('Subject updated successfully!'));
    } catch (e) {
      emit(SubjectError('Error updating subject: ${e.toString()}'));
    }
  }

  Future<void> deleteSubject(int subjectID) async {
    try {
      emit(SubjectLoading());
      await _subjectRepository.deleteSubject(subjectID);
      final subjects = await _subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
      emit(SubjectActionSuccess('Subject deleted successfully!'));
    } catch (e) {
      emit(SubjectError('Error deleting subject: ${e.toString()}'));
    }
  }
}
