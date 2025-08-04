// lib/cubits/encadrant_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/encadrant_internships_model.dart';
import 'package:pfa/Model/note_model.dart';
import 'package:pfa/Model/finished_internship_model.dart';
import 'package:pfa/Repositories/encadrant_repo.dart';

// --- States ---
abstract class EncadrantState extends Equatable {
  const EncadrantState();

  @override
  List<Object?> get props => [];
}

class EncadrantInitial extends EncadrantState {}

class EncadrantLoading extends EncadrantState {} // For initial page load

// State for actions related to notes, keeping the main list visible
class NoteActionLoading extends EncadrantState {
  final int? targetInternshipId; // The ID of the internship being acted upon
  const NoteActionLoading({this.targetInternshipId});

  @override
  List<Object?> get props => [targetInternshipId];
}

// State for loading finished internships
class FinishedInternshipsLoading extends EncadrantState {}

class EncadrantLoaded extends EncadrantState {
  final List<AssignedInternship> internships; // Changed to AssignedInternship
  const EncadrantLoaded(this.internships);

  @override
  List<Object?> get props => [internships];
}

// State for finished internships loaded
class FinishedInternshipsLoaded extends EncadrantState {
  final List<FinishedInternship> finishedInternships;
  const FinishedInternshipsLoaded(this.finishedInternships);

  @override
  List<Object?> get props => [finishedInternships];
}

class NotesLoaded extends EncadrantState {
  final List<Note> notes;
  final int internshipId; // To link notes to a specific internship
  const NotesLoaded(this.notes, this.internshipId);

  @override
  List<Object?> get props => [notes, internshipId];
}

// State for evaluation action loading, specific to a finished internship
class EvaluationActionLoading extends EncadrantState {
  final int targetStageId;
  const EvaluationActionLoading({required this.targetStageId});

  @override
  List<Object?> get props => [targetStageId];
}

// New: State for subject assignment action loading
class SubjectAssignmentLoading extends EncadrantState {
  final int targetStageId;
  const SubjectAssignmentLoading({required this.targetStageId});

  @override
  List<Object?> get props => [targetStageId];
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
  List<AssignedInternship> _lastLoadedInternships =
      []; // Changed to AssignedInternship
  // Hold the last successfully loaded finished internships
  List<FinishedInternship> _lastLoadedFinishedInternships = [];

  EncadrantCubit(this._encadrantRepository) : super(EncadrantInitial());

  //* Fetch all assigned internships for the Encadrant
  Future<void> fetchAssignedInternships() async {
    try {
      emit(EncadrantLoading());
      // The repository method should now return List<AssignedInternship>
      final internships = await _encadrantRepository.getAssignedInternships();
      _lastLoadedInternships = internships; // Store for later
      emit(EncadrantLoaded(internships));
    } catch (e) {
      emit(
        EncadrantError('Failed to load assigned internships: ${e.toString()}'),
      );
    }
  }

  //* Fetch all finished internships for the Encadrant
  Future<void> fetchFinishedInternships() async {
    try {
      emit(FinishedInternshipsLoading()); // Emit loading state
      final finishedInternships = await _encadrantRepository
          .getFinishedInternships();
      _lastLoadedFinishedInternships = finishedInternships; // Store for later
      emit(FinishedInternshipsLoaded(finishedInternships)); // Emit loaded state
    } catch (e) {
      emit(
        EncadrantError('Failed to load finished internships: ${e.toString()}'),
      ); // Handle error
    }
  }

  //* Add a new note to an internship
  // Note: The `internship_model.dart` and `AssignedInternship` are identical
  // so this method should work without changes, but it's good to be explicit
  // about which model it expects if there were differences.
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

  //** Evaluate or Unvalidate an Internship (UPDATED)
  Future<void> evaluateInternship({
    required int stageID,
    required String actionType,
    String? commentaires,
    String? displine,
    String? interest,
    String? presence,
    double? note, // Add the new 'note' parameter here
  }) async {
    try {
      emit(
        EvaluationActionLoading(targetStageId: stageID),
      ); // Emit loading state specific to evaluation

      final result = await _encadrantRepository.evaluateInternship(
        stageID: stageID,
        actionType: actionType,
        commentaires: commentaires,
        displine: displine,
        interest: interest,
        presence: presence,
        note: note, // Pass the new 'note' parameter to the repository
      );

      // After successful evaluation, re-fetch the finished internships to update the UI
      await fetchFinishedInternships();

      emit(
        EncadrantActionSuccess(
          result['message'] ?? 'Internship evaluation updated!',
        ),
      ); // Emit success with message
    } catch (e) {
      // If evaluation fails, attempt to re-emit the last loaded finished internships to maintain state
      if (_lastLoadedFinishedInternships.isNotEmpty) {
        emit(
          FinishedInternshipsLoaded(List.from(_lastLoadedFinishedInternships)),
        );
      } else {
        // If no finished internships were loaded, revert to initial or a generic error state
        emit(
          EncadrantInitial(),
        ); // Or emit EncadrantLoading() or a more specific error
      }
      emit(
        EncadrantError('Error evaluating internship: ${e.toString()}'),
      ); // Emit error state
    }
  }
  // * Assign Subject to Internship (NEW FUNCTION INTEGRATED HERE)
  Future<void> assignSubjectToInternship(int stageID, int sujetID) async {
    try {
      emit(
        SubjectAssignmentLoading(targetStageId: stageID),
      ); // Emit loading state for this specific action

      final message = await _encadrantRepository.assignSubjectToInternship(
        stageID,
        sujetID,
      );

      emit(EncadrantActionSuccess(message)); // Emit success message

      // After successfully assigning the subject, refresh the list of assigned internships
      // to reflect the change (e.g., subject title updated, status changed to 'en cours')
      await fetchAssignedInternships();
    } catch (e) {
      // If an error occurs, emit an error state
      emit(EncadrantError('Failed to assign subject: ${e.toString()}'));
      // Attempt to re-fetch assigned internships to ensure the list is up-to-date
      // even if the assignment failed (e.g., due to server error, not invalid input)
      // This is a common pattern to ensure data consistency after an action.
      // However, be mindful of potential infinite loops if the error constantly triggers a re-fetch that fails.
      // For now, keeping it as is, assuming the re-fetch itself won't immediately re-error with the same problem.
      await fetchAssignedInternships();
    }
  }
}
