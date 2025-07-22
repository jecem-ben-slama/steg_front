import 'package:flutter/material.dart';

class EvaluationToValidate {
  final int evaluationID;
  final int stageID;
  final int encadrantID;
  final String dateEvaluation;
  final double? note;
  final String? commentaires;
  final int? chefCentreValidationID;
  final String? dateValidationChef;

  final InternshipDetails internshipDetails;
  final StudentDetails studentDetails;
  final EncadrantDetails encadrantDetails;

  EvaluationToValidate({
    required this.evaluationID,
    required this.stageID,
    required this.encadrantID,
    required this.dateEvaluation,
    this.note,
    this.commentaires,
    this.chefCentreValidationID,
    this.dateValidationChef,
    required this.internshipDetails,
    required this.studentDetails,
    required this.encadrantDetails,
  });

  factory EvaluationToValidate.fromJson(Map<String, dynamic> json) {
    double? parsedNote;
    if (json['note'] != null) {
      if (json['note'] is num) {
        parsedNote = (json['note'] as num).toDouble();
      } else if (json['note'] is String) {
        parsedNote = double.tryParse(json['note']);
      }
    }

    return EvaluationToValidate(
      evaluationID: json['evaluationID'],
      stageID: json['stageID'],
      encadrantID: json['encadrantID'],
      dateEvaluation: json['dateEvaluation'],
      note: parsedNote,
      commentaires: json['commentaires'] as String?,
      chefCentreValidationID: json['chefCentreValidationID'],
      dateValidationChef: json['dateValidationChef'] as String?,
      internshipDetails: InternshipDetails.fromJson(json['internshipDetails']),
      studentDetails: StudentDetails.fromJson(json['studentDetails']),
      encadrantDetails: EncadrantDetails.fromJson(json['encadrantDetails']),
    );
  }
}

class InternshipDetails {
  final String? subjectTitle;
  final String? typeStage;
  final String? dateDebut;
  final String? dateFin;
  final String? statut;

  InternshipDetails({
    this.subjectTitle,
    this.typeStage,
    this.dateDebut,
    this.dateFin,
    this.statut,
  });

  factory InternshipDetails.fromJson(Map<String, dynamic> json) {
    return InternshipDetails(
      subjectTitle: json['subjectTitle'] as String?,
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
    );
  }
}

class StudentDetails {
  final String? studentName;
  final String? studentEmail;

  StudentDetails({this.studentName, this.studentEmail});

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      studentName: json['studentName'] as String?,
      studentEmail: json['studentEmail'] as String?,
    );
  }
}

class EncadrantDetails {
  final String? encadrantUsername;
  final String? encadrantEmail;

  EncadrantDetails({this.encadrantUsername, this.encadrantEmail});

  factory EncadrantDetails.fromJson(Map<String, dynamic> json) {
    return EncadrantDetails(
      encadrantUsername: json['encadrantUsername'] as String?,
      encadrantEmail: json['encadrantEmail'] as String?,
    );
  }
}
