import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/internship_repo.dart';
import 'package:flutter/material.dart'; // Added for debugPrint

// --- Internship States ---
abstract class InternshipState {}

class InternshipInitial extends InternshipState {}

class InternshipLoading extends InternshipState {}

class InternshipLoaded extends InternshipState {
  final List<Internship> internships;
  InternshipLoaded(this.internships);
}

class InternshipError extends InternshipState {
  final String message;
  final List<Internship>?
  lastLoadedInternships; // Optional: to revert UI on error
  InternshipError(this.message, {this.lastLoadedInternships});
}

class InternshipActionSuccess extends InternshipState {
  final String message;
  InternshipActionSuccess(this.message);
}

// NEW: State for optimistic updates of a single item
class InternshipUpdatingSingle extends InternshipState {
  final int? updatingInternshipId;
  final List<Internship>
  currentInternships; // The list of internships *before* optimistic removal/change

  InternshipUpdatingSingle(this.updatingInternshipId, this.currentInternships);
}

// --- Internship Cubit ---
class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  List<Internship> _currentInternships = []; // Internal list to manage state
  String _currentStatusFilter = ''; // To keep track of the last status fetched

  //* Fetch all internships
  Future<void> fetchInternships() async {
    _currentStatusFilter = ''; // Clear filter if fetching all
    emit(InternshipLoading());
    try {
      _currentInternships = await _internshipRepository.fetchAllInternships();
      debugPrint(
        'Cubit: fetchInternships - Data fetched successfully. Count: ${_currentInternships.length}',
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint('Cubit: fetchInternships - InternshipLoaded state emitted.');
    } catch (e) {
      debugPrint('Error in fetchInternships: ${e.toString()}');
      emit(InternshipError('Failed to fetch internships: ${e.toString()}'));
    }
  }

  //* Fetch internships by status (e.g., for Chef - 'PENDING')
  Future<void> fetchInternshipsByStatus(String status) async {
    _currentStatusFilter = status; // Set the current filter
    emit(InternshipLoading());
    try {
      _currentInternships = await _internshipRepository
          .fetchInternshipsByStatus(status);
      debugPrint(
        'Cubit: fetchInternshipsByStatus - Data fetched successfully for status "$status". Count: ${_currentInternships.length}',
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: fetchInternshipsByStatus - InternshipLoaded state emitted.',
      );
    } catch (e) {
      debugPrint('Error in fetchInternshipsByStatus: ${e.toString()}');
      emit(
        InternshipError(
          'Failed to fetch internships with status "$status": ${e.toString()}',
        ),
      );
    }
  }

  //* Update an internship's status (with optimistic update)
  Future<void> updateInternshipStatus(
    int? internshipId,
    String newStatus,
  ) async {
    if (internshipId == null) {
      emit(InternshipError("Cannot update status: Internship ID is null."));
      return;
    }

    // Capture the state before any optimistic updates for potential revert
    final List<Internship> listBeforeOptimisticUpdate = List.from(
      _currentInternships,
    );

    final int index = _currentInternships.indexWhere(
      (i) => i.internshipID == internshipId,
    );
    Internship?
    originalInternship; // To hold the internship being updated for revert

    if (index != -1) {
      originalInternship =
          _currentInternships[index]; // Store original for revert if needed

      // 1. Emit a state indicating a specific item is updating (for granular UI feedback)
      emit(
        InternshipUpdatingSingle(internshipId, List.from(_currentInternships)),
      );

      // 2. Perform optimistic removal/update from the local list
      // If changing status means the item should no longer be in the *current filtered view*, remove it.
      _currentInternships.removeAt(index);

      // 3. Emit the updated (optimistic) list to refresh UI immediately
      debugPrint(
        'Cubit: updateInternshipStatus - Optimistically removed ID $internshipId. New local count: ${_currentInternships.length}',
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: updateInternshipStatus - Optimistic InternshipLoaded state emitted.',
      );
    } else {
      // If the internship is not found locally, proceed with backend call but no optimistic UI changes
      debugPrint(
        "Cubit: updateInternshipStatus - Internship with ID $internshipId not found in local list. Proceeding without optimistic update.",
      );
      // You could emit a loading state here if you want to indicate an operation is happening
      // emit(InternshipLoading()); // Or a more specific 'InternshipUpdatingSingle(null, ...)'
    }

    try {
      // 4. Call the backend API to update the status
      await _internshipRepository.updateInternshipStatus(
        internshipId,
        newStatus,
      );
      debugPrint(
        'Cubit: updateInternshipStatus - Backend update successful for ID $internshipId.',
      );

      // 5. If backend call is successful, re-fetch the internships based on the active filter.
      // This ensures the displayed list is consistent with the backend state.
      if (_currentStatusFilter.isNotEmpty) {
        debugPrint(
          'Cubit: updateInternshipStatus - Re-fetching by status: $_currentStatusFilter',
        );
        await fetchInternshipsByStatus(
          _currentStatusFilter,
        ); // Re-fetch with the same status filter
      } else {
        debugPrint(
          'Cubit: updateInternshipStatus - Re-fetching all internships.',
        );
        await fetchInternships(); // Re-fetch all if no specific filter was active
      }

      // 6. Emit a success message (optional, but good for user feedback)
      emit(InternshipActionSuccess('Internship status updated to $newStatus!'));
      debugPrint(
        'Cubit: updateInternshipStatus - Action success state emitted.',
      );
    } catch (e) {
      debugPrint('Error in updateInternshipStatus: ${e.toString()}');
      // On failure:
      // 1. Emit an error message to the UI
      emit(
        InternshipError(
          'Failed to update status for internship $internshipId: ${e.toString()}',
          lastLoadedInternships:
              listBeforeOptimisticUpdate, // Provide the list before the failed action
        ),
      );
      // 2. Revert the local list state to what it was before the optimistic update
      // This brings the optimistically removed item back into the list.
      if (originalInternship != null && index != -1) {
        // Only revert if we actually performed an optimistic removal
        _currentInternships = List.from(listBeforeOptimisticUpdate);
      }
      debugPrint(
        'Cubit: updateInternshipStatus - Error path: Reverted local list. Count: ${_currentInternships.length}',
      );
      emit(
        InternshipLoaded(List.from(_currentInternships)),
      ); // Re-emit the reverted list
      debugPrint(
        'Cubit: updateInternshipStatus - Error path: InternshipLoaded state emitted after revert.',
      );
    }
  }

  //* Add Internship
  Future<void> addInternship(Internship newInternship) async {
    emit(InternshipLoading()); // Indicate loading while adding
    try {
      await _internshipRepository.addInternship(
        newInternship,
      ); // Assuming you have this in your repo
      debugPrint('Cubit: addInternship - Backend add successful.');
      // After adding, re-fetch to get the new list from the backend (including generated ID)
      if (_currentStatusFilter.isNotEmpty) {
        await fetchInternshipsByStatus(_currentStatusFilter);
      } else {
        await fetchInternships();
      }
      emit(InternshipActionSuccess('Internship added successfully!'));
      debugPrint('Cubit: addInternship - Action success state emitted.');
    } catch (e) {
      debugPrint('Error in addInternship: ${e.toString()}');
      emit(
        InternshipError(
          'Failed to add internship: ${e.toString()}',
          lastLoadedInternships: _currentInternships,
        ),
      );
    }
  }

  //* Delete Internship (with optimistic update)
  Future<void> deleteInternship(int internshipId) async {
    final List<Internship> listBeforeOptimisticUpdate = List.from(
      _currentInternships,
    );
    final int index = _currentInternships.indexWhere(
      (i) => i.internshipID == internshipId,
    );

    if (index != -1) {
      // Optimistically remove from the local list
      _currentInternships.removeAt(index);
      emit(
        InternshipLoaded(List.from(_currentInternships)),
      ); // Emit the list with the item optimistically removed
      debugPrint(
        'Cubit: deleteInternship - Optimistically removed ID $internshipId.',
      );
    } else {
      // If not found locally, proceed with backend call but no optimistic update
      debugPrint(
        'Cubit: deleteInternship - Internship ID $internshipId not found locally for optimistic removal.',
      );
      // You might want to emit a loading state here if no optimistic update happened
      // emit(InternshipLoading());
    }

    try {
      await _internshipRepository.deleteInternship(
        internshipId,
      ); // Assuming you have this in your repo
      debugPrint(
        'Cubit: deleteInternship - Backend delete successful for ID $internshipId.',
      );
      // Re-fetch all internships (or based on filter) after deleting
      if (_currentStatusFilter.isNotEmpty) {
        debugPrint(
          'Cubit: deleteInternship - Re-fetching by status: $_currentStatusFilter',
        );
        await fetchInternshipsByStatus(_currentStatusFilter);
      } else {
        debugPrint('Cubit: deleteInternship - Re-fetching all internships.');
        await fetchInternships();
      }
      emit(InternshipActionSuccess('Internship deleted successfully!'));
      debugPrint('Cubit: deleteInternship - Action success state emitted.');
    } catch (e) {
      debugPrint('Error in deleteInternship: ${e.toString()}');
      // On failure, revert the local list to its state before the optimistic update
      _currentInternships = List.from(listBeforeOptimisticUpdate);
      emit(
        InternshipError(
          'Failed to delete internship: ${e.toString()}',
          lastLoadedInternships: _currentInternships,
        ),
      );
      emit(
        InternshipLoaded(List.from(_currentInternships)),
      ); // Re-emit the reverted list
      debugPrint(
        'Cubit: deleteInternship - Error path: Reverted local list. Count: ${_currentInternships.length}',
      );
      debugPrint(
        'Cubit: deleteInternship - Error path: InternshipLoaded state emitted after revert.',
      );
    }
  }

  //* Edit Internship (general update)
  Future<void> editInternship(Internship updatedInternship) async {
    emit(InternshipLoading()); // Indicate loading while editing
    try {
      await _internshipRepository.updateInternship(
        updatedInternship,
      ); // Assuming an update method in your repo
      debugPrint('Cubit: editInternship - Backend update successful.');
      // After editing, re-fetch all internships to ensure UI is consistent
      if (_currentStatusFilter.isNotEmpty) {
        await fetchInternshipsByStatus(_currentStatusFilter);
      } else {
        await fetchInternships();
      }
      emit(InternshipActionSuccess('Internship updated successfully!'));
      debugPrint('Cubit: editInternship - Action success state emitted.');
    } catch (e) {
      debugPrint('Error in editInternship: ${e.toString()}');
      emit(
        InternshipError(
          'Failed to update internship: ${e.toString()}',
          lastLoadedInternships: _currentInternships,
        ),
      );
    }
  }
}
