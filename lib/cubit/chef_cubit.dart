import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/evaluation_validation.dart';
import 'package:pfa/Repositories/chef_repo.dart';

// --- States (remain the same) ---
abstract class ChefCentreState extends Equatable {
  const ChefCentreState();

  @override
  List<Object> get props => [];
}

class ChefCentreInitial extends ChefCentreState {}

class EvaluationsLoading extends ChefCentreState {}

class EvaluationsLoaded extends ChefCentreState {
  final List<EvaluationToValidate> evaluations;
  const EvaluationsLoaded(this.evaluations);

  @override
  List<Object> get props => [evaluations];
}

class ChefCentreError extends ChefCentreState {
  final String message;
  const ChefCentreError(this.message);

  @override
  List<Object> get props => [message];
}

class EvaluationActionLoading extends ChefCentreState {
  final int targetEvaluationId;
  const EvaluationActionLoading(this.targetEvaluationId);

  @override
  List<Object> get props => [targetEvaluationId];
}

class EvaluationActionSuccess extends ChefCentreState {
  final String message;
  final int evaluationId;
  final String actionType;
  const EvaluationActionSuccess(
    this.message,
    this.evaluationId,
    this.actionType,
  );

  @override
  List<Object> get props => [message, evaluationId, actionType];
}

// --- Cubit ---
class ChefCentreCubit extends Cubit<ChefCentreState> {
  final ChefCentreRepository _chefCentreRepository; // Use the repository now

  ChefCentreCubit(this._chefCentreRepository) : super(ChefCentreInitial());
//* Fetch All Evaluations Pending Validation for Chef Centre
  Future<void> fetchEvaluationsToValidate() async {
    emit(EvaluationsLoading());
    try {
      final evaluations = await _chefCentreRepository
          .getEvaluationsToValidate();
      emit(EvaluationsLoaded(evaluations));
    } catch (e) {
      if (e is Exception) {
        // Catch the custom Exception thrown by the repository
        emit(ChefCentreError(e.toString().replaceFirst('Exception: ', '')));
      } else {
        emit(ChefCentreError('An unexpected error occurred: ${e.toString()}'));
      }
    }
  }

//* Validate or Reject an Evaluation
  Future<void> validateOrRejectEvaluation({
    required int evaluationID,
    required String actionType,
    
  }) async {
    final currentState = state;
    emit(EvaluationActionLoading(evaluationID));

    try {
      final result = await _chefCentreRepository.validateOrRejectEvaluation(
        evaluationID: evaluationID,
        actionType: actionType,
      );
      emit(
        EvaluationActionSuccess(result['message'], evaluationID, actionType),
      );
      // Re-fetch the list to update the UI after success
      fetchEvaluationsToValidate();
    } catch (e) {
      if (e is Exception) {
        emit(ChefCentreError(e.toString().replaceFirst('Exception: ', '')));
      } else {
        emit(ChefCentreError('An unexpected error occurred: ${e.toString()}'));
      }
      // Revert to the previous loaded state on error to avoid losing list data
      if (currentState is EvaluationsLoaded) {
        emit(EvaluationsLoaded(currentState.evaluations));
      } else {
        emit(ChefCentreInitial()); // Fallback
      }
    }
  }
}
