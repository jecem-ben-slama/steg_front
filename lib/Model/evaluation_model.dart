import 'package:equatable/equatable.dart';

class Evaluation extends Equatable {
  final int evaluationID;
  final int stageID;
  final int encadrantID;
  final String dateEvaluation;
  final double? note;
  final String? commentaires;

  // --- START OF MODIFICATION ---
  // Add the new fields as nullable strings
  final String? displine;
  final String? interest;
  final String? presence;
  // --- END OF MODIFICATION ---

  const Evaluation({
    required this.evaluationID,
    required this.stageID,
    required this.encadrantID,
    required this.dateEvaluation,
    this.note,
    this.commentaires,

    // --- START OF MODIFICATION ---
    // Add the new fields to the constructor
    this.displine,
    this.interest,
    this.presence,
    // --- END OF MODIFICATION ---
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      evaluationID: json['evaluationID'] as int,
      stageID: json['stageID'] as int,
      encadrantID: json['encadrantID'] as int,
      dateEvaluation: json['dateEvaluation'] as String,
      note: (json['note'] != null)
          ? double.tryParse(json['note'].toString())
          : null,
      commentaires: json['commentaires'] as String?,

      // --- START OF MODIFICATION ---
      // Parse the new fields from the JSON map
      displine: json['displine'] as String?,
      interest: json['interest'] as String?,
      presence: json['presence'] as String?,
      // --- END OF MODIFICATION ---
    );
  }

  @override
  List<Object?> get props => [
    evaluationID,
    stageID,
    encadrantID,
    dateEvaluation,
    note,
    commentaires,

    // --- START OF MODIFICATION ---
    // Add the new fields to the props list
    displine,
    interest,
    presence,
    // --- END OF MODIFICATION ---
  ];
}
