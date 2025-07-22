// lib/cubits/encadrant_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Model/note_model.dart';
import 'package:pfa/Repositories/encadrant_repo.dart';

// --- States ---
abstract class EncadrantState extends Equatable {
  const EncadrantState();

  @override
  List<Object?> get props => [];
}

class EncadrantInitial extends EncadrantState {}

class EncadrantLoading extends EncadrantState {} // For initial page load

// New: State for actions related to notes, keeping the main list visible
class NoteActionLoading extends EncadrantState {
  final int? targetInternshipId; // The ID of the internship being acted upon
  const NoteActionLoading({this.targetInternshipId});

  @override
  List<Object?> get props => [targetInternshipId];
}

class EncadrantLoaded extends EncadrantState {
  final List<Internship> internships;
  const EncadrantLoaded(this.internships);

  @override
  List<Object?> get props => [internships];
}

class NotesLoaded extends EncadrantState {
  final List<Note> notes;
  final int internshipId; // To link notes to a specific internship
  const NotesLoaded(this.notes, this.internshipId);

  @override
  List<Object?> get props => [notes, internshipId];
}

class EncadrantActionSuccess extends EncadrantState {
  final String message;
  const EncadrantActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EncadrantError extends EncadrantState {
  final String message;
  const EncadrantError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class EncadrantCubit extends Cubit<EncadrantState> {
  final EncadrantRepository _encadrantRepository;
  // Hold the last successfully loaded internships to keep them visible
  List<Internship> _lastLoadedInternships = [];

  EncadrantCubit(this._encadrantRepository) : super(EncadrantInitial());

  //* Fetch all assigned internships for the Encadrant
  Future<void> fetchAssignedInternships() async {
    try {
      emit(EncadrantLoading());
      final internships = await _encadrantRepository.getAssignedInternships();
      _lastLoadedInternships = internships; // Store for later
      emit(EncadrantLoaded(internships));
    } catch (e) {
      emit(EncadrantError('Failed to load internships: ${e.toString()}'));
    }
  }

  //* Add a new note to an internship
  Future<void> addNoteToInternship(int stageID, String contenuNote) async {
    try {
      emit(
        NoteActionLoading(targetInternshipId: stageID),
      ); // Emit specific loading state
      await _encadrantRepository.addInternshipNote(stageID, contenuNote);
      // Refetch current internship notes to update the expanded view instantly
      await fetchNotesForInternship(
        stageID,
        notifySuccess: false,
      ); // Fetch without emitting new success state
      // Re-emit EncadrantLoaded with the existing data to clear loading state and show success
      emit(EncadrantLoaded(List.from(_lastLoadedInternships)));
      emit(const EncadrantActionSuccess('Note added successfully!'));
    } catch (e) {
      // Re-emit EncadrantLoaded with existing data before error
      emit(EncadrantLoaded(List.from(_lastLoadedInternships)));
      emit(EncadrantError('Error adding note: ${e.toString()}'));
    }
  }

  //* Fetch notes for a specific internship
  Future<void> fetchNotesForInternship(
    int stageID, {
    bool notifySuccess = true,
  }) async {
    try {
      emit(
        NoteActionLoading(targetInternshipId: stageID),
      ); // Emit specific loading state
      final notes = await _encadrantRepository.getInternshipNotes(stageID);
      emit(NotesLoaded(notes, stageID)); // Emit loaded notes with internship ID
      if (notifySuccess) {
        // Only notify success if explicitly requested (e.g., when opening the expansion tile)
        emit(EncadrantActionSuccess('Notes loaded successfully!'));
      }
    } catch (e) {
      // If fetching notes fails, revert to showing the loaded internships
      emit(EncadrantLoaded(List.from(_lastLoadedInternships)));
      emit(EncadrantError('Error fetching notes: ${e.toString()}'));
    }
  }

  //* Validate an internship
  Future<void> validateInternship(int stageID) async {
    try {
      emit(
        NoteActionLoading(targetInternshipId: stageID),
      ); // Use specific loading state
      await _encadrantRepository.validateInternship(stageID);
      await fetchAssignedInternships(); // Refetch all internships to get the updated status (this will emit EncadrantLoaded)
      emit(const EncadrantActionSuccess('Internship validated successfully!'));
    } catch (e) {
      // Re-emit EncadrantLoaded with existing data before error
      emit(EncadrantLoaded(List.from(_lastLoadedInternships)));
      emit(EncadrantError('Error validating internship: ${e.toString()}'));
    }
  }
}
