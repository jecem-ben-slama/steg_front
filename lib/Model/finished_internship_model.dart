// lib/models/finished_internship.dart
import 'package:equatable/equatable.dart';

// Renaming EncadrantEvaluation to Evaluation for consistency
// You should ensure this matches the class name you use in your cubit
class Evaluation extends Equatable {
  final int evaluationID;
  final int stageID;
  final int encadrantID;
  final String dateEvaluation;
  final double? note;
  final String? commentaires;
  final int? chefCentreValidationID;
  final String? dateValidationChef;

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
    this.chefCentreValidationID,
    this.dateValidationChef,

    // --- START OF MODIFICATION ---
    // Add the new fields to the constructor
    this.displine,
    this.interest,
    this.presence,
    // --- END OF MODIFICATION ---
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    double? parsedNote;
    if (json['note'] != null) {
      if (json['note'] is num) {
        parsedNote = (json['note'] as num).toDouble();
      } else if (json['note'] is String) {
        parsedNote = double.tryParse(json['note']);
      }
    }

    return Evaluation(
      evaluationID: json['evaluationID'] as int,
      stageID: json['stageID'] as int,
      encadrantID: json['encadrantID'] as int,
      dateEvaluation: json['dateEvaluation'] as String,
      note: parsedNote,
      commentaires: json['commentaires'] as String?,
      chefCentreValidationID: json['chefCentreValidationID'] as int?,
      dateValidationChef: json['dateValidationChef'] as String?,

      // --- START OF MODIFICATION ---
      // Parse the new fields from the JSON map
      displine: json['displine'] as String?,
      interest: json['interest'] as String?,
      presence: json['presence'] as String?,
      // --- END OF MODIFICATION ---
    );
  }

  // --- START OF MODIFICATION ---
  // Add a toJson method to serialize the object
  Map<String, dynamic> toJson() {
    return {
      'evaluationID': evaluationID,
      'stageID': stageID,
      'encadrantID': encadrantID,
      'dateEvaluation': dateEvaluation,
      'note': note,
      'commentaires': commentaires,
      'chefCentreValidationID': chefCentreValidationID,
      'dateValidationChef': dateValidationChef,
      'displine': displine,
      'interest': interest,
      'presence': presence,
    };
  }
  // --- END OF MODIFICATION ---

  @override
  List<Object?> get props => [
    evaluationID,
    stageID,
    encadrantID,
    dateEvaluation,
    note,
    commentaires,
    chefCentreValidationID,
    dateValidationChef,

    // --- START OF MODIFICATION ---
    // Add the new fields to the props list
    displine,
    interest,
    presence,
    // --- END OF MODIFICATION ---
  ];
}

class FinishedInternship extends Equatable {
  final int internshipID;
  final int etudiantID;
  final int? sujetID;
  final String? subjectTitle;
  final String typeStage;
  final String dateDebut;
  final String dateFin;
  final String statut;
  final bool estRemunere;
  final double? montantRemuneration;
  final int encadrantProID;
  final int? chefCentreValidationID;
  final String? studentName;
  final String? studentEmail;
  final String? supervisorName;
  final String? encadrantProName;
  final String? encadrantPedaName;
  // --- START OF MODIFICATION ---
  // Changed type to Evaluation to match the updated model
  final Evaluation? encadrantEvaluation;
  // --- END OF MODIFICATION ---

  const FinishedInternship({
    required this.internshipID,
    required this.etudiantID,
    this.sujetID,
    this.subjectTitle,
    required this.typeStage,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.estRemunere,
    this.montantRemuneration,
    required this.encadrantProID,
    this.chefCentreValidationID,
    this.studentName,
    this.studentEmail,
    this.supervisorName,
    this.encadrantProName,
    this.encadrantPedaName,
    this.encadrantEvaluation,
  });

  factory FinishedInternship.fromJson(Map<String, dynamic> json) {
    return FinishedInternship(
      internshipID: json['internshipID'] as int,
      etudiantID: json['etudiantID'] as int,
      sujetID: json['sujetID'] as int?,
      subjectTitle: json['subjectTitle'] as String?,
      typeStage: json['typeStage'] as String,
      dateDebut: json['dateDebut'] as String,
      dateFin: json['dateFin'] as String,
      statut: json['statut'] as String,
      estRemunere: json['estRemunere'] as bool,
      montantRemuneration: (json['montantRemuneration'] as num?)?.toDouble(),
      encadrantProID: json['encadrantProID'] as int,
      chefCentreValidationID: json['chefCentreValidationID'] as int?,
      studentName: json['studentName'] as String?,
      studentEmail: json['studentEmail'] as String?,
      supervisorName: json['supervisorName'] as String?,
      encadrantProName: json['encadrantProName'] as String?,
      encadrantPedaName: json['encadrantPedaName'] as String?,
      // --- START OF MODIFICATION ---
      // Updated the factory constructor to use the new Evaluation class
      encadrantEvaluation: json['encadrantEvaluation'] != null
          ? Evaluation.fromJson(
              json['encadrantEvaluation'] as Map<String, dynamic>,
            )
          : null,
      // --- END OF MODIFICATION ---
    );
  }

  @override
  List<Object?> get props => [
    internshipID,
    etudiantID,
    sujetID,
    subjectTitle,
    typeStage,
    dateDebut,
    dateFin,
    statut,
    estRemunere,
    montantRemuneration,
    encadrantProID,
    chefCentreValidationID,
    studentName,
    studentEmail,
    supervisorName,
    encadrantProName,
    encadrantPedaName,
    encadrantEvaluation,
  ];
}

// You might also have a response wrapper if your API returns
// {"status": "success", "data": [...]}
class FinishedInternshipResponse {
  final String status;
  final List<FinishedInternship> data;

  FinishedInternshipResponse({required this.status, required this.data});

  factory FinishedInternshipResponse.fromJson(Map<String, dynamic> json) {
    return FinishedInternshipResponse(
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FinishedInternship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
