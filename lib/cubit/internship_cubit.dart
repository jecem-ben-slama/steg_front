import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/internship_repo.dart';

// States for Internship Cubit
abstract class InternshipState {}

class InternshipInitial extends InternshipState {}

class InternshipLoading extends InternshipState {}

class InternshipLoaded extends InternshipState {
  final List<Internship> internships;
  InternshipLoaded(this.internships);
}

class InternshipError extends InternshipState {
  final String message;
  InternshipError(this.message);
}

// Internship Cubit
class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  Future<void> fetchInternships() async {
    emit(InternshipLoading());
    try {
      final internships = await _internshipRepository.fetchAllInternships();
      emit(InternshipLoaded(internships));
    } catch (e) {
      emit(InternshipError('Failed to fetch internships: ${e.toString()}'));
    }
  }
}
