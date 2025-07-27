import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/attestation_model.dart'; // Corrected import for AttestationData
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

// NEW: States for fetching a list of attestable internships
class AttestableInternshipsLoading extends InternshipState {}

class AttestableInternshipsLoaded extends InternshipState {
  final List<Internship> internships;
  AttestableInternshipsLoaded(this.internships);
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

// --- ATTESTATION STATES (integrated into InternshipState hierarchy) ---
class AttestationLoading extends InternshipState {}

class AttestationLoaded extends InternshipState {
  final AttestationData attestationData;
  AttestationLoaded(this.attestationData);
}

class AttestationErrorState extends InternshipState {
  // Renamed to avoid conflict with main InternshipError
  final String message;
  AttestationErrorState(this.message);
}
// --- END NEW ATTESTATION STATES ---

// --- Internship Cubit ---
class InternshipCubit extends Cubit<InternshipState> {
  final InternshipRepository _internshipRepository;

  InternshipCubit(this._internshipRepository) : super(InternshipInitial());

  List<Internship> _currentInternships = []; // Internal list to manage state
  String _currentStatusFilter =
      'Proposé'; // To keep track of the last status fetched

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

  //* Fetch internships by status (for Chef )
  Future<void> fetchInternshipsByStatus() async {
    // Set the current filter
    emit(InternshipLoading());
    try {
      _currentInternships = await _internshipRepository
          .fetchProposedInternships(); // Assuming this fetches for a specific status
      debugPrint(
        'Cubit: fetchInternshipsByStatus - Data fetched successfully for status "WHAT". Count: ${_currentInternships.length}',
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: fetchInternshipsByStatus - InternshipLoaded state emitted.',
      );
    } catch (e) {
      debugPrint('Error in fetchInternshipsByStatus: ${e.toString()}');
      emit(
        InternshipError(
          'Failed to fetch internships with status "WHAT": ${e.toString()}',
        ),
      );
    }
  }

  // NEW METHOD: Fetch internships eligible for attestation
  Future<void> fetchAttestableInternships() async {
    emit(AttestableInternshipsLoading()); // Emit new loading state
    try {
      final internships = await _internshipRepository
          .fetchTerminatedAndEvaluatedInternships();
      debugPrint(
        'Cubit: fetchAttestableInternships - Data fetched successfully. Count: ${internships.length}',
      );
      emit(AttestableInternshipsLoaded(internships)); // Emit new loaded state
    } catch (e) {
      debugPrint('Error in fetchAttestableInternships: ${e.toString()}');
      // Using the general InternshipError for this list fetch for simplicity
      emit(
        InternshipError(
          'Failed to fetch attestable internships: ${e.toString()}',
        ),
      );
    }
  }

  //* Update an internship's status ()
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

    // Emit a state indicating a specific item is updating (for granular UI feedback like a spinner)
    // This should happen *before* any optimistic local list modification
    emit(
      InternshipUpdatingSingle(internshipId, List.from(_currentInternships)),
    );
    debugPrint(
      'Cubit: updateInternshipStatus - Emitted InternshipUpdatingSingle for ID $internshipId.',
    );

    try {
      // 1. Call the backend API to update the status
      await _internshipRepository.updateInternshipStatus(
        internshipId,
        newStatus,
      );
      debugPrint(
        'Cubit: updateInternshipStatus - Backend update successful for ID $internshipId.',
      );

      // 2. If backend call is successful, re-fetch the internships based on the active filter.
      if (_currentStatusFilter.isNotEmpty) {
        debugPrint(
          'Cubit: updateInternshipStatus - Re-fetching by status: $_currentStatusFilter',
        );
        await fetchInternshipsByStatus();
      } else {
        debugPrint(
          'Cubit: updateInternshipStatus - Re-fetching all internships.',
        );
        await fetchInternships();
      }

      // 3. Emit a success message (optional, but good for user feedback)
      emit(InternshipActionSuccess('Internship status updated to $newStatus!'));
      debugPrint(
        'Cubit: updateInternshipStatus - Action success state emitted.',
      );
    } catch (e) {
      debugPrint('Error in updateInternshipStatus: ${e.toString()}');
      // On failure:
      // 1. Revert the local list state to what it was before the optimistic update
      _currentInternships = List.from(listBeforeOptimisticUpdate);
      debugPrint(
        'Cubit: updateInternshipStatus - Error path: Reverted local list. Count: ${_currentInternships.length}',
      );
      // 2. Emit an error message to the UI
      emit(
        InternshipError(
          'Failed to update status for internship $internshipId: ${e.toString()}',
          lastLoadedInternships:
              _currentInternships, // Provide the list for potential UI revert
        ),
      );
      // 3. Re-emit the InternshipLoaded state with the reverted list to update the UI
      emit(InternshipLoaded(List.from(_currentInternships)));
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
        await fetchInternshipsByStatus();
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

  //* Delete Internship ()
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
      debugPrint(
        'Cubit: deleteInternship - Internship ID $internshipId not found locally for optimistic removal.',
      );
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
        await fetchInternshipsByStatus();
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

  //* Edit Internship ()
  Future<void> editInternship(Internship updatedInternship) async {
    emit(InternshipLoading()); // Indicate loading while editing
    try {
      await _internshipRepository.updateInternship(
        updatedInternship,
      ); // Assuming an update method in your repo
      debugPrint('Cubit: editInternship - Backend update successful.');
      // After editing, re-fetch all internships to ensure UI is consistent
      if (_currentStatusFilter.isNotEmpty) {
        await fetchInternshipsByStatus();
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

  // NEW METHOD: Fetch Attestation Data
  Future<void> fetchAttestationData(int stageID) async {
    emit(AttestationLoading()); // Indicate loading for attestation
    try {
      final attestationData = await _internshipRepository.getAttestationData(
        stageID,
      );
      debugPrint(
        'Cubit: fetchAttestationData - Attestation data fetched successfully.',
      );
      emit(AttestationLoaded(attestationData)); // Emit loaded attestation data
    } catch (e) {
      debugPrint('Error in fetchAttestationData: ${e.toString()}');
      emit(
        AttestationErrorState('Failed to load attestation: ${e.toString()}'),
      ); // Emit attestation-specific error
    }
  }
}
