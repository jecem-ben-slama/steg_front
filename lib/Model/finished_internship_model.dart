// lib/models/finished_internship.dart
import 'package:equatable/equatable.dart'; // Consider using equatable for easier comparison in Bloc

class FinishedInternship extends Equatable {
  final int internshipID;
  final int etudiantID;
  final int? sujetID; // Changed to nullable based on JSON example
  final String? subjectTitle; // Changed to nullable based on JSON example
  final String typeStage;
  final String dateDebut; // Keeping as String as per your original model
  final String dateFin; // Keeping as String as per your original model
  final String statut;
  final bool estRemunere;
  final double?
  montantRemuneration; // Changed to nullable based on JSON example
  final int encadrantProID;
  final int? chefCentreValidationID; // Already nullable, good!
  final String? studentName; // Already nullable, good!
  final String?
  studentEmail; // Already nullable, good! (assuming this might be in your full JSON)
  final String? supervisorName; // Changed to nullable based on JSON example
  final String? encadrantProName; // Changed to nullable based on JSON example
  final String? encadrantPedaName; // Already nullable, good!
  final EncadrantEvaluation? encadrantEvaluation; // Already nullable, good!

  FinishedInternship({
    required this.internshipID,
    required this.etudiantID,
    this.sujetID, // Remove 'required' if nullable
    this.subjectTitle, // Remove 'required' if nullable
    required this.typeStage,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.estRemunere,
    this.montantRemuneration, // Remove 'required' if nullable
    required this.encadrantProID,
    this.chefCentreValidationID,
    this.studentName,
    this.studentEmail,
    this.supervisorName, // Remove 'required' if nullable
    this.encadrantProName, // Remove 'required' if nullable
    this.encadrantPedaName,
    this.encadrantEvaluation,
  });

  factory FinishedInternship.fromJson(Map<String, dynamic> json) {
    return FinishedInternship(
      internshipID: json['internshipID'] as int, // Explicitly cast
      etudiantID: json['etudiantID'] as int, // Explicitly cast
      sujetID: json['sujetID'] as int?, // Safely cast as nullable int
      subjectTitle:
          json['subjectTitle'] as String?, // Safely cast as nullable String
      typeStage: json['typeStage'] as String, // Explicitly cast
      dateDebut: json['dateDebut'] as String, // Explicitly cast
      dateFin: json['dateFin'] as String, // Explicitly cast
      statut: json['statut'] as String, // Explicitly cast
      estRemunere: json['estRemunere'] as bool, // Directly cast as bool
      montantRemuneration: (json['montantRemuneration'] as num?)
          ?.toDouble(), // Safely parse nullable num to double
      encadrantProID: json['encadrantProID'] as int, // Explicitly cast
      chefCentreValidationID:
          json['chefCentreValidationID'] as int?, // Safely cast as nullable int
      studentName:
          json['studentName'] as String?, // Safely cast as nullable String
      studentEmail:
          json['studentEmail'] as String?, // Safely cast as nullable String
      supervisorName:
          json['supervisorName'] as String?, // Safely cast as nullable String
      encadrantProName:
          json['encadrantProName'] as String?, // Safely cast as nullable String
      encadrantPedaName:
          json['encadrantPedaName']
              as String?, // Safely cast as nullable String
      encadrantEvaluation: json['encadrantEvaluation'] != null
          ? EncadrantEvaluation.fromJson(
              json['encadrantEvaluation'] as Map<String, dynamic>,
            ) // Explicitly cast nested map
          : null,
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

class EncadrantEvaluation extends Equatable {
  final int evaluationID;
  final int stageID;
  final int encadrantID;
  final String dateEvaluation; // Keeping as String as per your original model
  final double? note; // Nullable, good!
  final String? commentaires; // Nullable, good!
  final int? chefCentreValidationID; // Nullable, good!
  final String? dateValidationChef; // Nullable, good!

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
    double? parsedNote;
    if (json['note'] != null) {
      if (json['note'] is num) {
        parsedNote = (json['note'] as num).toDouble();
      } else if (json['note'] is String) {
        parsedNote = double.tryParse(json['note']);
      }
    }

    return EncadrantEvaluation(
      evaluationID: json['evaluationID'] as int, // Explicitly cast
      stageID: json['stageID'] as int, // Explicitly cast
      encadrantID: json['encadrantID'] as int, // Explicitly cast
      dateEvaluation: json['dateEvaluation'] as String, // Explicitly cast
      note: parsedNote,
      commentaires:
          json['commentaires'] as String?, // Safely cast as nullable String
      chefCentreValidationID:
          json['chefCentreValidationID'] as int?, // Safely cast as nullable int
      dateValidationChef:
          json['dateValidationChef']
              as String?, // Safely cast as nullable String
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
    chefCentreValidationID,
    dateValidationChef,
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
