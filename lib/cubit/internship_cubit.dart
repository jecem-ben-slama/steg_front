import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/internship_repo.dart';

abstract class InternshipState {}

class InternshipInitial extends InternshipState {}

class InternshipLoading extends InternshipState {}

class InternshipLoaded extends InternshipState {
  final List<Internship> internships;
  InternshipLoaded(this.internships);
}

class InternshipError extends InternshipState {
  final String message;
  final List<Internship>? lastLoadedInternships;
  InternshipError(this.message, {this.lastLoadedInternships});
}

class InternshipActionSuccess extends InternshipState {
  final String message;
  InternshipActionSuccess(this.message);
}

class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  List<Internship> _currentInternships = [];
  //* Fetch all internships
  Future<void> fetchInternships() async {
    emit(InternshipLoading());
    try {
      _currentInternships = await _internshipRepository.fetchAllInternships();
      emit(InternshipLoaded(List.from(_currentInternships)));
    } catch (e) {
      emit(InternshipError('Failed to fetch internships: ${e.toString()}'));
    }
  }

   //* Add an internship
  Future<void> addInternship(Internship internship) async {
    // Optimistic update: Add the internship to the local list first
    // This provides immediate UI feedback
    final List<Internship> optimisticList = List.from(_currentInternships);
    optimisticList.add(internship); // Temporarily add it

    // Emit the new list immediately
    emit(InternshipLoaded(optimisticList)); // Show the added item
    // You might also emit a "saving" or "processing" state here if the operation
    // takes a noticeable amount of time, but for brief operations, direct update is fine.

    try {
      // The addInternship in repo now returns the Internship object with the new ID
      final addedInternship = await _internshipRepository.addInternship(
        internship,
      );

      // After successful API call, if the addedInternship has a real ID,
      // you might want to replace the temporary one in the list.
      // For simplicity, we'll re-fetch the entire list for consistency.
      // However, a more performant way is to update the item by ID.
      // For now, let's keep `fetchInternships` for full synchronization.
      await fetchInternships(); // Refetch to update UI with new data (and actual ID)
      emit(
        InternshipActionSuccess('Internship added successfully!'),
      ); // Send success notification
    } catch (e) {
      // On failure, revert to the previous state (or fetch again)
      // Re-emit last loaded internships if add fails to prevent empty screen
      emit(
        InternshipError(
          'Error adding internship: ${e.toString()}',
          lastLoadedInternships: List.from(
            _currentInternships,
          ), // Revert to the state before optimistic update
        ),
      );
      // It's still a good idea to fetch again to ensure UI consistency
      // in case the error handling path is more complex or a partial add occurred.
      await fetchInternships();
    }
  }
  //* Delete an internship
  Future<void> deleteInternship(int id) async {
    final List<Internship> internshipsBeforeAction = List.from(
      _currentInternships,
    );
    emit(InternshipLoading());

    try {
      final success = await _internshipRepository.deleteInternship(id);
      if (success) {
        emit(InternshipActionSuccess('Internship deleted successfully!'));
        await fetchInternships();
      } else {
        emit(
          InternshipError(
            'Failed to delete internship.',
            lastLoadedInternships: internshipsBeforeAction,
          ),
        );
        await fetchInternships();
      }
    } catch (e) {
      emit(
        InternshipError(
          'Error deleting internship: ${e.toString()}',
          lastLoadedInternships: internshipsBeforeAction,
        ),
      );
      await fetchInternships();
    }
  }

  //* Update an internship
  Future<void> updateInternship(Internship internship) async {
    final List<Internship> internshipsBeforeAction = List.from(
      _currentInternships,
    );
    emit(InternshipLoading());

    try {
      final success = await _internshipRepository.updateInternship(internship);
      if (success) {
        emit(InternshipActionSuccess('Internship updated successfully!'));
        await fetchInternships();
      } else {
        emit(
          InternshipError(
            'Failed to update internship.',
            lastLoadedInternships: internshipsBeforeAction,
          ),
        );
        await fetchInternships();
      }
    } catch (e) {
      emit(
        InternshipError(
          'Error updating internship: ${e.toString()}',
          lastLoadedInternships: internshipsBeforeAction,
        ),
      );
      await fetchInternships();
    }
  }
}
