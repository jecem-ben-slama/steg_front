// lib/models/internship.dart
class Internship {
  final int? internshipID; // This should be int? as discussed
  final String? studentID;
  final String? studentName;
  final String? sujetID;
  final String? subjectTitle;
  final String? typeStage;
  final String? dateDebut;
  final String? dateFin;
  final String? statut;
  final String? estRemunere;
  final String? montantRemuneration;
  final String? encadrantProID;
  final String? supervisorName;
  final String? chefCentreValidationID;

  Internship({
    this.internshipID,
    this.studentID,
    this.studentName,
    this.sujetID,
    this.subjectTitle,
    this.typeStage,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.estRemunere,
    this.montantRemuneration,
    this.encadrantProID,
    this.supervisorName,
    this.chefCentreValidationID,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      // === FIX IS HERE ===
      internshipID: int.tryParse(json['stageID']?.toString() ?? ''),

      // json['stageID']?.toString() ensures it's a string (or null)
      // int.tryParse attempts to convert that string to an int.
      // If it fails (e.g., 'abc' or null string), it returns null,
      // which matches the int? type.
      studentID: json['etudiantID']?.toString(),
      studentName: json['studentName'] as String?,
      sujetID: json['sujetID']?.toString(),
      subjectTitle: json['subjectTitle'] as String?,
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
      estRemunere: json['estRemunere']?.toString(),
      montantRemuneration: json['montantRemuneration']?.toString(),
      encadrantProID: json['encadrantProID']?.toString(),
      supervisorName: json['supervisorName'] as String?,
      chefCentreValidationID: json['chefCentreValidationID']?.toString(),
    );
  }

  // Your toJson method (no changes needed for this specific issue)
  Map<String, dynamic> toJson() {
    return {
      'stageID': internshipID,
      'etudiantID': studentID,
      'sujetID': sujetID,
      'typeStage': typeStage,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'statut': statut,
      'estRemunere': estRemunere,
      'montantRemuneration': montantRemuneration,
      'encadrantProID': encadrantProID,
      'chefCentreValidationID': chefCentreValidationID,
    };
  }
}
