// lib/Cubit/internship_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/internship_repo.dart';

// --- Events for Internship Cubit ---
abstract class InternshipEvent {}

class FetchInternships extends InternshipEvent {}

class DeleteInternshipEvent extends InternshipEvent {
  final int internshipId;
  DeleteInternshipEvent(this.internshipId);
}

// --- States for Internship Cubit ---
abstract class InternshipState {}

class InternshipInitial extends InternshipState {}

class InternshipLoading extends InternshipState {}

class InternshipLoaded extends InternshipState {
  final List<Internship> internships;
  InternshipLoaded(this.internships);
}
class UpdateInternshipEvent extends InternshipEvent {
  final Internship internship;
  UpdateInternshipEvent(this.internship);
}

// MODIFIED: InternshipError state can now carry the last loaded internships
class InternshipError extends InternshipState {
  final String message;
  final List<Internship>? lastLoadedInternships; // <-- New field
  InternshipError(
    this.message, {
    this.lastLoadedInternships,
  }); // <-- New constructor parameter
}

class InternshipActionSuccess extends InternshipState {
  final String message;
  InternshipActionSuccess(this.message);
}

// --- Internship Cubit ---
class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  Future<void> fetchInternships() async {
    // Get currently loaded internships, if any, before emitting loading
    final List<Internship>? previouslyLoadedInternships =
        (state is InternshipLoaded)
        ? (state as InternshipLoaded).internships
        : (state is InternshipError &&
              (state as InternshipError).lastLoadedInternships != null)
        ? (state as InternshipError).lastLoadedInternships
        : null;

    emit(InternshipLoading()); // Emit loading state

    try {
      final internships = await _internshipRepository.fetchAllInternships();
      emit(InternshipLoaded(internships));
    } catch (e) {
      // If fetching fails, emit error. Pass previously loaded data if available.
      emit(
        InternshipError(
          'Failed to fetch internships: ${e.toString()}',
          lastLoadedInternships: previouslyLoadedInternships,
        ),
      );
    }
  }

  Future<void> deleteInternship(int internshipId) async {
    // Capture the current list of internships before starting the action
    final List<Internship>? currentInternshipsBeforeAction =
        (state is InternshipLoaded)
        ? (state as InternshipLoaded).internships
        : (state is InternshipError &&
              (state as InternshipError).lastLoadedInternships != null)
        ? (state as InternshipError)
              .lastLoadedInternships // Use last known if currently in error
        : null;

    try {
      // It's generally good to show loading, even briefly, for user feedback.
      // The dashboard's BlocBuilder will be updated to handle this gracefully.
      emit(InternshipLoading());

      final success = await _internshipRepository.deleteInternship(
        internshipId,
      );

      if (success) {
        emit(InternshipActionSuccess('Internship deleted successfully!'));
        await fetchInternships(); // Re-fetch to show updated list (without the deleted item)
      } else {
        // If the repository indicates failure (e.g., returns false)
        emit(
          InternshipError(
            'Failed to delete internship.',
            lastLoadedInternships:
                currentInternshipsBeforeAction, // Pass old data on failure
          ),
        );
        await fetchInternships(); // Re-fetch to potentially show the item still there
      }
    } catch (e) {
      // This catches any exceptions (e.g., network error, 404 from backend)
      emit(
        InternshipError(
          'Error deleting internship: ${e.toString()}',
          lastLoadedInternships:
              currentInternshipsBeforeAction, // Pass old data on error
        ),
      );
      await fetchInternships(); // Re-fetch to ensure table state is consistent after error
    }
  }

Future<void> updateInternship(Internship internship) async {
    final List<Internship>? currentInternshipsBeforeAction =
        (state is InternshipLoaded)
        ? (state as InternshipLoaded).internships
        : (state is InternshipError &&
              (state as InternshipError).lastLoadedInternships != null)
        ? (state as InternshipError).lastLoadedInternships
        : null;

    emit(InternshipLoading()); // Indicate loading

    try {
      final success = await _internshipRepository.updateInternship(
        internship,
      ); // Assuming this method exists in your repo

      if (success) {
        emit(InternshipActionSuccess('Internship updated successfully!'));
        await fetchInternships(); // Re-fetch to show updated list
      } else {
        emit(
          InternshipError(
            'Failed to update internship.',
            lastLoadedInternships: currentInternshipsBeforeAction,
          ),
        );
        await fetchInternships(); // Re-fetch to revert if update failed
      }
    } catch (e) {
      emit(
        InternshipError(
          'Error updating internship: ${e.toString()}',
          lastLoadedInternships: currentInternshipsBeforeAction,
        ),
      );
      await fetchInternships(); // Re-fetch to revert if update failed
    }
  }
}
