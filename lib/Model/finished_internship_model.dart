// lib/models/finished_internship.dart
import 'package:flutter/material.dart';

class FinishedInternship {
  final int internshipID;
  final int etudiantID;
  final int sujetID;
  final String subjectTitle;
  final String typeStage;
  final String dateDebut;
  final String dateFin;
  final String statut;
  final bool estRemunere;
  final double montantRemuneration;
  final int encadrantProID;
  final int? chefCentreValidationID; // Nullable
  final String? studentName; // <-- Make nullable
  final String? studentEmail; // <-- Make nullable
  final String supervisorName;
  final String encadrantProName;
  final String? encadrantPedaName; // Nullable
  final EncadrantEvaluation? encadrantEvaluation; // Nullable

  FinishedInternship({
    required this.internshipID,
    required this.etudiantID,
    required this.sujetID,
    required this.subjectTitle,
    required this.typeStage,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.estRemunere,
    required this.montantRemuneration,
    required this.encadrantProID,
    this.chefCentreValidationID,
    this.studentName, // Remove 'required' if making nullable
    this.studentEmail, // Remove 'required' if making nullable
    required this.supervisorName,
    required this.encadrantProName,
    this.encadrantPedaName,
    this.encadrantEvaluation,
  });

  factory FinishedInternship.fromJson(Map<String, dynamic> json) {
    return FinishedInternship(
      internshipID: json['internshipID'],
      etudiantID: json['etudiantID'],
      sujetID: json['sujetID'],
      subjectTitle: json['subjectTitle'],
      typeStage: json['typeStage'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      statut: json['statut'],
      estRemunere: json['estRemunere'] ?? false,
      montantRemuneration:
          (json['montantRemuneration'] as num?)?.toDouble() ?? 0.0,
      encadrantProID: json['encadrantProID'],
      chefCentreValidationID: json['chefCentreValidationID'],
      // Safely access potentially null strings. The ?? '' provides a default empty string if null,
      // but since the field is now nullable, you can just assign json['key'] directly.
      studentName:
          json['studentName'] as String?, // Directly assign as nullable String
      studentEmail:
          json['studentEmail'] as String?, // Directly assign as nullable String
      supervisorName: json['supervisorName'],
      encadrantProName: json['encadrantProName'],
      encadrantPedaName: json['encadrantPedaName'],
      encadrantEvaluation: json['encadrantEvaluation'] != null
          ? EncadrantEvaluation.fromJson(json['encadrantEvaluation'])
          : null,
    );
  }
}

class EncadrantEvaluation {
  final int evaluationID;
  final int stageID;
  final int encadrantID;
  final String dateEvaluation;
  final double? note; // Nullable
  final String? commentaires; // Nullable
  final int? chefCentreValidationID; // Nullable
  final String? dateValidationChef; // Nullable

  EncadrantEvaluation({
    required this.evaluationID,
    required this.stageID,
    required this.encadrantID,
    required this.dateEvaluation,
    this.note,
    this.commentaires,
    this.chefCentreValidationID,
    this.dateValidationChef,
  });

  factory EncadrantEvaluation.fromJson(Map<String, dynamic> json) {
    // Safely parse 'note' which might be a String or a num
    double? parsedNote;
    if (json['note'] != null) {
      if (json['note'] is num) {
        parsedNote = (json['note'] as num).toDouble();
      } else if (json['note'] is String) {
        parsedNote = double.tryParse(json['note']);
      }
    }

    return EncadrantEvaluation(
      evaluationID: json['evaluationID'],
      stageID: json['stageID'],
      encadrantID: json['encadrantID'],
      dateEvaluation: json['dateEvaluation'],
      note: parsedNote, // Use the safely parsed note
      commentaires:
          json['commentaires']
              as String?, // Make sure this is also safely cast as nullable String
      chefCentreValidationID: json['chefCentreValidationID'],
      dateValidationChef: json['dateValidationChef'],
    );
  }
}
