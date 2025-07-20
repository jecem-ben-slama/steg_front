import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/internship_repo.dart';
import 'package:flutter/material.dart'; // Added for debugPrint

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

// *** NEW: InternshipUpdatingSingle state ***
class InternshipUpdatingSingle extends InternshipState {
  final int? updatingInternshipId;
  final List<Internship>
  currentInternships; // The list of internships *before* optimistic removal

  InternshipUpdatingSingle(this.updatingInternshipId, this.currentInternships);
}
// **************************************************************************

class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  List<Internship> _currentInternships = []; // Internal list to manage state
  String _currentStatusFilter =
      ''; // NEW: To keep track of the last status fetched

  //* Fetch all internships (for Gestionnaire, etc.)
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

  //* NEW: Fetch internships by status (for Chef - 'PENDING')
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

  //* NEW: Update an internship's status specifically
  Future<void> updateInternshipStatus(
    int? internshipId,
    String newStatus,
  ) async {
    if (internshipId == null) {
      emit(InternshipError("Cannot update status: Internship ID is null."));
      return;
    }

    // Capture the state before any optimistic updates
    // This is useful for reverting on error, or simply to ensure _currentInternships is not null
    final List<Internship> listBeforeOptimisticUpdate = List.from(
      _currentInternships,
    );

    // Find the internship in the current list
    final int index = _currentInternships.indexWhere(
      (i) => i.internshipID == internshipId,
    );
    Internship?
    originalInternship; // To hold the internship being updated for revert

    if (index != -1) {
      originalInternship = _currentInternships[index];

      // 1. Emit a state indicating a specific item is updating (for granular UI feedback)
      emit(
        InternshipUpdatingSingle(internshipId, List.from(_currentInternships)),
      );

      // 2. Perform optimistic removal from the local list
      // This is appropriate if changing status means the item should no longer be in the *current filtered view*.
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
      // If the internship is not found locally, emit an error and return.
      // This can happen if the list wasn't fully loaded or the ID is invalid.
      emit(
        InternshipError(
          "Internship with ID $internshipId not found in the current list. Cannot perform optimistic update.",
          lastLoadedInternships: listBeforeOptimisticUpdate,
        ),
      );
      return;
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
        // Restore the list from the saved state before optimistic removal
        _currentInternships = List.from(listBeforeOptimisticUpdate);
      }
      debugPrint(
        'Cubit: updateInternshipStatus - Error path: Reverted local list. Count: ${_currentInternships.length}',
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: updateInternshipStatus - Error path: InternshipLoaded state emitted after revert.',
      );
    }
  }

  //* Add an internship
  Future<void> addInternship(Internship internship) async {
    // Optimistic update for adding
    final List<Internship> optimisticList = List.from(_currentInternships);
    optimisticList.add(internship);
    debugPrint('Cubit: addInternship - Emitting optimistic state.');
    emit(InternshipLoaded(optimisticList)); // Emit optimistic state

    try {
      await _internshipRepository.addInternship(internship);
      debugPrint('Cubit: addInternship - Backend add successful.');
      // After success, re-fetch based on current filter or all to get accurate data including new ID
      if (_currentStatusFilter.isNotEmpty) {
        debugPrint(
          'Cubit: addInternship - Re-fetching by status: $_currentStatusFilter',
        );
        await fetchInternshipsByStatus(_currentStatusFilter);
      } else {
        debugPrint('Cubit: addInternship - Re-fetching all internships.');
        await fetchInternships();
      }
      emit(InternshipActionSuccess('Internship added successfully!'));
      debugPrint('Cubit: addInternship - Action success state emitted.');
    } catch (e) {
      debugPrint('Error in addInternship: ${e.toString()}');
      emit(
        InternshipError(
          'Error adding internship: ${e.toString()}',
          lastLoadedInternships: List.from(
            optimisticList,
          ), // Pass the list as it was
        ),
      );
      // Re-fetch to get the true state if optimistic add failed
      if (_currentStatusFilter.isNotEmpty) {
        debugPrint(
          'Cubit: addInternship - Error path: Re-fetching by status: $_currentStatusFilter',
        );
        await fetchInternshipsByStatus(_currentStatusFilter);
      } else {
        debugPrint(
          'Cubit: addInternship - Error path: Re-fetching all internships.',
        );
        await fetchInternships();
      }
    }
  }

  //* Delete an internship
  Future<void> deleteInternship(int? id) async {
    if (id == null) {
      emit(InternshipError("Cannot delete: Internship ID is null."));
      return;
    }
    final List<Internship> internshipsBeforeAction = List.from(
      _currentInternships,
    );
    // Optimistic removal for deletion
    final List<Internship> optimisticList = _currentInternships
        .where((internship) => internship.internshipID != id)
        .toList();
    debugPrint(
      'Cubit: deleteInternship - Emitting optimistic state for deletion.',
    );
    emit(InternshipLoaded(optimisticList)); // Emit optimistic state

    try {
      final success = await _internshipRepository.deleteInternship(id);
      debugPrint(
        'Cubit: deleteInternship - Backend delete successful: $success.',
      );
      if (success) {
        // If deletion was successful, the optimistic state is correct locally.
        // Re-fetch to confirm and ensure data consistency, especially with filters.
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
      } else {
        // If backend reports failure, revert to original list and emit error
        debugPrint(
          'Cubit: deleteInternship - Backend reported failure to delete.',
        );
        emit(
          InternshipError(
            'Failed to delete internship.',
            lastLoadedInternships: internshipsBeforeAction,
          ),
        );
        emit(InternshipLoaded(internshipsBeforeAction)); // Revert UI
        debugPrint(
          'Cubit: deleteInternship - Reverted local list on backend failure.',
        );
      }
    } catch (e) {
      debugPrint('Error in deleteInternship: ${e.toString()}');
      emit(
        InternshipError(
          'Error deleting internship: ${e.toString()}',
          lastLoadedInternships: internshipsBeforeAction,
        ),
      );
      emit(
        InternshipLoaded(internshipsBeforeAction),
      ); // Revert UI on network/other error
      debugPrint('Cubit: deleteInternship - Error path: Reverted local list.');
    }
  }

  //* Update an internship (generic update, not just status)
  Future<void> updateInternship(Internship internship) async {
    if (internship.internshipID == null) {
      emit(InternshipError("Cannot update: Internship ID is null."));
      return;
    }

    final List<Internship> internshipsBeforeAction = List.from(
      _currentInternships,
    );

    // Optimistic update for generic update
    final List<Internship> optimisticList = _currentInternships.map((i) {
      return i.internshipID == internship.internshipID ? internship : i;
    }).toList();
    debugPrint(
      'Cubit: updateInternship - Emitting optimistic state for update.',
    );
    emit(InternshipLoaded(optimisticList)); // Emit optimistic state

    try {
      final success = await _internshipRepository.updateInternship(internship);
      debugPrint(
        'Cubit: updateInternship - Backend update successful: $success.',
      );
      if (success) {
        // After success, re-fetch based on current filter or all to get accurate data
        if (_currentStatusFilter.isNotEmpty) {
          debugPrint(
            'Cubit: updateInternship - Re-fetching by status: $_currentStatusFilter',
          );
          await fetchInternshipsByStatus(_currentStatusFilter);
        } else {
          debugPrint('Cubit: updateInternship - Re-fetching all internships.');
          await fetchInternships();
        }
        emit(InternshipActionSuccess('Internship updated successfully!'));
        debugPrint('Cubit: updateInternship - Action success state emitted.');
      } else {
        // Revert on backend failure
        debugPrint(
          'Cubit: updateInternship - Backend reported failure to update.',
        );
        emit(
          InternshipError(
            'Failed to update internship.',
            lastLoadedInternships: internshipsBeforeAction,
          ),
        );
        emit(InternshipLoaded(internshipsBeforeAction)); // Revert UI
        debugPrint(
          'Cubit: updateInternship - Reverted local list on backend failure.',
        );
      }
    } catch (e) {
      debugPrint('Error in updateInternship: ${e.toString()}');
      emit(
        InternshipError(
          'Error updating internship: ${e.toString()}',
          lastLoadedInternships: internshipsBeforeAction,
        ),
      );
      emit(
        InternshipLoaded(internshipsBeforeAction),
      ); // Revert UI on network/other error
      debugPrint('Cubit: updateInternship - Error path: Reverted local list.');
    }
  }
}
