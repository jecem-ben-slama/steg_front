// lib/Model/internship_model.dart
import 'package:equatable/equatable.dart'; // Import Equatable
import 'package:pfa/Model/evaluation_model.dart'; // Import the new Evaluation model

class Internship extends Equatable { // Extend Equatable
  final int? internshipID;
  final String? studentName;
  final String? studentEmail; // Added for completeness, if it's coming from API
  final String? subjectTitle;
  final String? supervisorName; // Maps to encadrantProName or similar
  final int? encadrantProID;
  final String? typeStage;
  final String? dateDebut;
  final String? dateFin;
  final String? statut;
  final bool? estRemunere;
  final double? montantRemuneration;
  final int? etudiantID; // Assuming this maps to studentID
  final int? sujetID; // Assuming this maps to the subject's ID

  // Add fields that were in my previous version but missing from yours:
  final String? description;
  final int? companyID;
  final int? encadrantPedaID;
  final String? encadrantPedaName; // Assuming this is needed somewhere
  final int? studentID; // This might be redundant with etudiantID, confirm your backend maps
  final String? encadrantProName; // Assuming supervisorName is encadrantProName from DB

  // New: Holds the Encadrant's specific evaluation for this internship
  final Evaluation? encadrantEvaluation;


  Internship({
    this.internshipID,
    this.studentName,
    this.studentEmail,
    this.subjectTitle,
    this.supervisorName, // This will be mapped from 'encadrantProName' or similar
    this.encadrantProID,
    this.typeStage,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.estRemunere,
    this.montantRemuneration,
    this.etudiantID,
    this.sujetID,
    // Add the missing fields from my previous full model (if they exist in your backend)
    this.description,
    this.companyID,
    this.encadrantPedaID,
    this.encadrantPedaName,
    this.studentID, // Confirm if studentID and etudiantID are the same or different in your backend
    this.encadrantProName, // Keep this if 'supervisorName' is just a display name

    this.encadrantEvaluation, // New field for the nested evaluation
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    bool? parseBoolean(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lowerCaseValue = value.toLowerCase();
        if (lowerCaseValue == '1' || lowerCaseValue == 'true') return true;
        if (lowerCaseValue == '0' || lowerCaseValue == 'false') return false;
      }
      return null;
    }

    return Internship(
      internshipID: int.tryParse(json['stageID']?.toString() ?? ''),
      studentName: json['studentName'] as String?,
      studentEmail: json['studentEmail'] as String?, // Assuming 'studentEmail' comes from backend
      subjectTitle: json['subjectTitle'] as String?,
      // Map supervisorName from encadrantProName or similar from the API
      supervisorName: json['supervisorName'] as String? ?? json['encadrantProName'] as String?,
      encadrantProID: int.tryParse(json['encadrantProID']?.toString() ?? ''),
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
      estRemunere: parseBoolean(json['estRemunere']),
      montantRemuneration: json['montantRemuneration'] != null
          ? double.tryParse(json['montantRemuneration'].toString())
          : null,
      etudiantID: int.tryParse(json['etudiantID']?.toString() ?? '') ?? int.tryParse(json['studentID']?.toString() ?? ''), // Handle both
      sujetID: int.tryParse(json['sujetID']?.toString() ?? ''),

      // These fields were present in your provided image and in my "full" model.
      // Ensure they map correctly from your PHP results.
      description: json['description'] as String?,
      companyID: int.tryParse(json['entrepriseID']?.toString() ?? ''),
      encadrantPedaID: int.tryParse(json['encadrantPedaID']?.toString() ?? ''),
      encadrantPedaName: json['encadrantPedaName'] as String?, // Assuming this exists
      studentID: int.tryParse(json['studentID']?.toString() ?? ''), // Keep if distinct from etudiantID
      encadrantProName: json['encadrantProName'] as String?,

      // Parse the nested 'encadrantEvaluation' JSON into an Evaluation object
      encadrantEvaluation: json['encadrantEvaluation'] != null
          ? Evaluation.fromJson(json['encadrantEvaluation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageID': internshipID,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'subjectTitle': subjectTitle,
      'supervisorName': supervisorName,
      'encadrantProID': encadrantProID,
      'typeStage': typeStage,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'statut': statut,
      'estRemunere': estRemunere != null ? (estRemunere! ? 1 : 0) : null,
      'montantRemuneration': montantRemuneration,
      'etudiantID': etudiantID,
      'sujetID': sujetID,
      'description': description,
      'companyID': companyID,
      'encadrantPedaID': encadrantPedaID,
      'encadrantPedaName': encadrantPedaName,
      'studentID': studentID,
      'encadrantProName': encadrantProName,
      // Evaluation is not typically serialized back to JSON for a POST,
      // but if needed, it would look like:
      // 'encadrantEvaluation': encadrantEvaluation?.toJson(),
    };
  }

  // Updated copyWith method for nullable internshipID and new fields
  Internship copyWith({
    int? internshipID,
    String? studentName,
    String? studentEmail,
    String? subjectTitle,
    String? supervisorName,
    int? encadrantProID,
    String? typeStage,
    String? dateDebut,
    String? dateFin,
    String? statut,
    bool? estRemunere,
    double? montantRemuneration,
    int? etudiantID,
    int? sujetID,
    String? description,
    int? companyID,
    int? encadrantPedaID,
    String? encadrantPedaName,
    int? studentID,
    String? encadrantProName,
    Evaluation? encadrantEvaluation,
  }) {
    return Internship(
      internshipID: internshipID ?? this.internshipID,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      subjectTitle: subjectTitle ?? this.subjectTitle,
      supervisorName: supervisorName ?? this.supervisorName,
      encadrantProID: encadrantProID ?? this.encadrantProID,
      typeStage: typeStage ?? this.typeStage,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      estRemunere: estRemunere ?? this.estRemunere,
      montantRemuneration: montantRemuneration ?? this.montantRemuneration,
      etudiantID: etudiantID ?? this.etudiantID,
      sujetID: sujetID ?? this.sujetID,
      description: description ?? this.description,
      companyID: companyID ?? this.companyID,
      encadrantPedaID: encadrantPedaID ?? this.encadrantPedaID,
      encadrantPedaName: encadrantPedaName ?? this.encadrantPedaName,
      studentID: studentID ?? this.studentID,
      encadrantProName: encadrantProName ?? this.encadrantProName,
      encadrantEvaluation: encadrantEvaluation ?? this.encadrantEvaluation,
    );
  }

  @override
  List<Object?> get props => [
        internshipID,
        studentName,
        studentEmail,
        subjectTitle,
        supervisorName,
        encadrantProID,
        typeStage,
        dateDebut,
        dateFin,
        statut,
        estRemunere,
        montantRemuneration,
        etudiantID,
        sujetID,
        description,
        companyID,
        encadrantPedaID,
        encadrantPedaName,
        studentID,
        encadrantProName,
        encadrantEvaluation, // Include the new Evaluation field in props
      ];

  // The operator == and hashCode are handled by Equatable,
  // so you typically don't need to override them explicitly unless you want custom logic.
  // If you want to keep your custom equality:
  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return other is Internship && other.internshipID == internshipID;
  // }
  //
  // @override
  // int get hashCode => internshipID.hashCode;
}