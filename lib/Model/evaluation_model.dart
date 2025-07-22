import 'package:equatable/equatable.dart';

class Evaluation extends Equatable {
  final int evaluationID;
  final int stageID;
  final int encadrantID;
  final String dateEvaluation;
  final double? note;
  final String? commentaires;

  const Evaluation({
    required this.evaluationID,
    required this.stageID,
    required this.encadrantID,
    required this.dateEvaluation,
    this.note,
    this.commentaires,
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
  ];
}
