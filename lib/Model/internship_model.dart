// lib/Model/internship_model.dart
class Internship {
  final int? internshipID;
  final String? studentName;
  final String? subjectTitle;
  final String? supervisorName;
  final int? encadrantProID; // NEW: Add encadrantProID
  final String? typeStage;
  final String? dateDebut;
  final String? dateFin;
  final String? statut;
  final bool? estRemunere;
  final double? montantRemuneration;

  // You might also want to include other IDs like etudiantID, sujetID, etc.,
  // if they are part of your Internship object and need to be carried around.
  // For this update, I'm focusing on encadrantProID as requested.
  final int? etudiantID;
  final int? sujetID;
  final int? chefCentreValidationID;

  Internship({
    this.internshipID,
    this.studentName,
    this.subjectTitle,
    this.supervisorName,
    this.encadrantProID, // NEW: Add to constructor
    this.typeStage,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.estRemunere,
    this.montantRemuneration,
    this.etudiantID, // Added for completeness if present in JSON
    this.sujetID, // Added for completeness if present in JSON
    this.chefCentreValidationID, // Added for completeness if present in JSON
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    // Helper function to parse boolean from various formats
    bool? parseBoolean(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1; // Handles 0 or 1
      if (value is String) {
        final lowerCaseValue = value.toLowerCase();
        if (lowerCaseValue == '1' || lowerCaseValue == 'true') return true;
        if (lowerCaseValue == '0' || lowerCaseValue == 'false') return false;
      }
      return null; // Or throw an error if you expect strict boolean values
    }

    return Internship(
      internshipID: int.tryParse(json['stageID'].toString()),
      studentName: json['studentName'] as String?,
      subjectTitle: json['subjectTitle'] as String?,
      supervisorName: json['supervisorName'] as String?,
      encadrantProID: int.tryParse(
        json['encadrantProID']?.toString() ?? '',
      ), // NEW: Parse encadrantProID
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
      estRemunere: parseBoolean(json['estRemunere']), // Use the helper
      montantRemuneration: json['montantRemuneration'] != null
          ? double.tryParse(json['montantRemuneration'].toString())
          : null,
      etudiantID: int.tryParse(json['etudiantID']?.toString() ?? ''),
      sujetID: int.tryParse(json['sujetID']?.toString() ?? ''),
      chefCentreValidationID: int.tryParse(
        json['chefCentreValidationID']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageID': internshipID,
      'typeStage': typeStage,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'statut': statut,
      'estRemunere': estRemunere != null
          ? (estRemunere! ? 1 : 0)
          : null, // Send as int (0 or 1)
      'montantRemuneration': montantRemuneration,
      'studentName':
          studentName, // Generally not sent for update, but kept if your backend expects it
      'subjectTitle':
          subjectTitle, // Generally not sent for update, but kept if your backend expects it
      'supervisorName':
          supervisorName, // Generally not sent for update, but kept if your backend expects it
      'encadrantProID': encadrantProID, // NEW: Add to toJson
      'etudiantID': etudiantID,
      'sujetID': sujetID,
      'chefCentreValidationID': chefCentreValidationID,
    };
  }
}
