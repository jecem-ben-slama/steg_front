// lib/cubit/internship_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/attestation_model.dart'; // Corrected import
import 'package:pfa/Model/internship_model.dart'; // Assuming this model exists
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
class AttestationLoading
    extends InternshipState {} // For fetching existing attestation

class AttestationLoaded extends InternshipState {
  // For fetching existing attestation
  final AttestationData attestationData;
  AttestationLoaded(this.attestationData);
}

class AttestationGenerating
    extends InternshipState {} // For generating a new attestation

class AttestationGenerated extends InternshipState {
  // For a newly generated attestation
  final AttestationData attestationData;
  AttestationGenerated(this.attestationData);
}

class AttestationErrorState extends InternshipState {
  final String message;
  AttestationErrorState(this.message);
}

// --- END NEW ATTESTATION STATES ---

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

  //* Fetch internships by status (for Chef )
  Future<void> fetchInternshipsByStatus() async {
    emit(InternshipLoading());
    try {
      _currentInternships = await _internshipRepository
          .fetchProposedInternships();
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
      emit(
        InternshipError(
          'Failed to fetch attestable internships: ${e.toString()}',
        ),
      );
    }
  }

  //* Update an internship's status
  Future<void> updateInternshipStatus(
    int? internshipId,
    String newStatus,
  ) async {
    if (internshipId == null) {
      emit(InternshipError("Cannot update status: Internship ID is null."));
      return;
    }

    final List<Internship> listBeforeOptimisticUpdate = List.from(
      _currentInternships,
    );

    emit(
      InternshipUpdatingSingle(internshipId, List.from(_currentInternships)),
    );
    debugPrint(
      'Cubit: updateInternshipStatus - Emitted InternshipUpdatingSingle for ID $internshipId.',
    );

    try {
      await _internshipRepository.updateInternshipStatus(
        internshipId,
        newStatus,
      );
      debugPrint(
        'Cubit: updateInternshipStatus - Backend update successful for ID $internshipId.',
      );

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

      emit(InternshipActionSuccess('Internship status updated to $newStatus!'));
      debugPrint(
        'Cubit: updateInternshipStatus - Action success state emitted.',
      );
    } catch (e) {
      debugPrint('Error in updateInternshipStatus: ${e.toString()}');
      _currentInternships = List.from(listBeforeOptimisticUpdate);
      emit(
        InternshipError(
          'Failed to update status for internship $internshipId: ${e.toString()}',
          lastLoadedInternships: _currentInternships,
        ),
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: updateInternshipStatus - Error path: InternshipLoaded state emitted after revert.',
      );
    }
  }

  //* Add Internship
  Future<void> addInternship(Internship newInternship) async {
    emit(InternshipLoading());
    try {
      await _internshipRepository.addInternship(newInternship);
      debugPrint('Cubit: addInternship - Backend add successful.');
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

  //* Delete Internship
  Future<void> deleteInternship(int internshipId) async {
    final List<Internship> listBeforeOptimisticUpdate = List.from(
      _currentInternships,
    );
    final int index = _currentInternships.indexWhere(
      (i) => i.internshipID == internshipId,
    );

    if (index != -1) {
      _currentInternships.removeAt(index);
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: deleteInternship - Optimistically removed ID $internshipId.',
      );
    } else {
      debugPrint(
        'Cubit: deleteInternship - Internship ID $internshipId not found locally for optimistic removal.',
      );
    }

    try {
      await _internshipRepository.deleteInternship(internshipId);
      debugPrint(
        'Cubit: deleteInternship - Backend delete successful for ID $internshipId.',
      );
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
      _currentInternships = List.from(listBeforeOptimisticUpdate);
      emit(
        InternshipError(
          'Failed to delete internship: ${e.toString()}',
          lastLoadedInternships: _currentInternships,
        ),
      );
      emit(InternshipLoaded(List.from(_currentInternships)));
      debugPrint(
        'Cubit: deleteInternship - Error path: InternshipLoaded state emitted after revert.',
      );
    }
  }

  //* Edit Internship
  Future<void> editInternship(Internship updatedInternship) async {
    emit(InternshipLoading());
    try {
      await _internshipRepository.updateInternship(updatedInternship);
      debugPrint('Cubit: editInternship - Backend update successful.');
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

  //* Fetch Attestation Data (for Gestionnaire to view existing, if needed)
  Future<void> fetchAttestationData(int stageID) async {
    emit(AttestationLoading());
    try {
      final attestationData = await _internshipRepository.getAttestationData(
        stageID,
      );
      debugPrint(
        'Cubit: fetchAttestationData - Attestation data fetched successfully.',
      );
      emit(AttestationLoaded(attestationData));
    } catch (e) {
      debugPrint('Error in fetchAttestationData: ${e.toString()}');
      emit(
        AttestationErrorState('Failed to load attestation: ${e.toString()}'),
      );
    }
  }

}
