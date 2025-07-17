// lib/Cubit/internship_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/internship_repo.dart';

// --- States ---
abstract class InternshipState {}

class InternshipInitial extends InternshipState {}

class InternshipLoading extends InternshipState {}

class InternshipLoaded extends InternshipState {
  final List<Internship> internships;
  InternshipLoaded(this.internships);
}

class InternshipError extends InternshipState {
  final String message;
  final List<Internship>? lastLoadedInternships; // To preserve data on error
  InternshipError(this.message, {this.lastLoadedInternships});
}

class InternshipActionSuccess extends InternshipState {
  final String message;
  InternshipActionSuccess(this.message);
}

// --- Cubit ---
class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  List<Internship> _currentInternships =
      []; // Keep track of the last loaded list

  Future<void> fetchInternships() async {
    emit(InternshipLoading()); // Indicate loading
    try {
      _currentInternships = await _internshipRepository.fetchAllInternships();
      emit(InternshipLoaded(List.from(_currentInternships))); // Emit a copy
    } catch (e) {
      emit(InternshipError('Failed to fetch internships: ${e.toString()}'));
    }
  }

  Future<void> deleteInternship(int id) async {
    final List<Internship> internshipsBeforeAction = List.from(
      _currentInternships,
    ); // Save current state
    emit(InternshipLoading()); // Optional: Indicate action in progress

    try {
      final success = await _internshipRepository.deleteInternship(id);
      if (success) {
        emit(InternshipActionSuccess('Internship deleted successfully!'));
        // Re-fetch to update the list, or manually remove
        await fetchInternships(); // Re-fetch for simplicity
      } else {
        emit(
          InternshipError(
            'Failed to delete internship.',
            lastLoadedInternships:
                internshipsBeforeAction, // Restore previous data
          ),
        );
        await fetchInternships(); // Re-fetch to ensure sync if manual removal logic is complex
      }
    } catch (e) {
      emit(
        InternshipError(
          'Error deleting internship: ${e.toString()}',
          lastLoadedInternships:
              internshipsBeforeAction, // Restore previous data
        ),
      );
      await fetchInternships(); // Re-fetch
    }
  }

  // NEW METHOD: updateInternship
  Future<void> updateInternship(Internship internship) async {
    final List<Internship> internshipsBeforeAction = List.from(
      _currentInternships,
    ); // Save current state
    emit(InternshipLoading()); // Indicate action in progress

    try {
      final success = await _internshipRepository.updateInternship(internship);
      if (success) {
        emit(InternshipActionSuccess('Internship updated successfully!'));
        // Re-fetch to update the list
        await fetchInternships();
      } else {
        emit(
          InternshipError(
            'Failed to update internship.',
            lastLoadedInternships:
                internshipsBeforeAction, // Restore previous data
          ),
        );
        await fetchInternships();
      }
    } catch (e) {
      emit(
        InternshipError(
          'Error updating internship: ${e.toString()}',
          lastLoadedInternships:
              internshipsBeforeAction, // Restore previous data
        ),
      );
      await fetchInternships();
    }
  }
}
