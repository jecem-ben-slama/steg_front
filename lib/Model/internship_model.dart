// lib/models/internship.dart
class Internship {
  final String? internshipID;
  final String?
  studentID; // Still good to keep the ID if needed for other operations
  final String? studentName; // NEW: From backend join
  final String?
  sujetID; // Changed from sujetStageID to sujetID to match PHP output
  final String? subjectTitle; // NEW: From backend join
  final String? typeStage;
  final String? dateDebut; // Changed from startDate to dateDebut
  final String? dateFin; // Changed from endDate to dateFin
  final String? statut; // Changed from status to statut
  final String? estRemunere;
  final String? montantRemuneration;
  final String? encadrantProID; // Still good to keep the ID
  final String? supervisorName; // NEW: From backend join
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
      internshipID: json['stageID']?.toString(), // Matches PHP output 'stageID'
      studentID: json['etudiantID']
          ?.toString(), // Matches PHP output 'etudiantID'
      studentName: json['studentName'] as String?, // Directly map
      sujetID: json['sujetID']?.toString(), // Matches PHP output 'sujetID'
      subjectTitle: json['subjectTitle'] as String?, // Directly map
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?, // Matches PHP output 'dateDebut'
      dateFin: json['dateFin'] as String?, // Matches PHP output 'dateFin'
      statut: json['statut'] as String?, // Matches PHP output 'statut'
      estRemunere: json['estRemunere']?.toString(),
      montantRemuneration: json['montantRemuneration']?.toString(),
      encadrantProID: json['encadrantProID']
          ?.toString(), // Matches PHP output 'encadrantProID'
      supervisorName: json['supervisorName'] as String?, // Directly map
      chefCentreValidationID: json['chefCentreValidationID']?.toString(),
    );
  }

  // Optional: A toJson method if you need to send Internship objects back to the API
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
      // Note: We typically don't send the 'name' fields back, as they are derived.
      // If your API expects them, add them here.
    };
  }
}
