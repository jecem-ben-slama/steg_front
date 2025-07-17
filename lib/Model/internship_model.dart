// lib/Model/internship_model.dart
class Internship {
  final int? internshipID;
  final String? studentName;
  final String? subjectTitle; // Already declared here
  final String? supervisorName; // Already declared here
  final String? typeStage;
  final String? dateDebut;
  final String? dateFin;
  final String? statut;
  final bool? estRemunere;
  final double? montantRemuneration;

  Internship({
    this.internshipID,
    this.studentName,
    this.subjectTitle,
    this.supervisorName,
    this.typeStage,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.estRemunere,
    this.montantRemuneration,
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
      // FIX: Change 'titreSujet' to 'subjectTitle' as seen in Postman response
      subjectTitle: json['subjectTitle'] as String?, // Corrected key
      // FIX: Change 'nomEncadrant' to 'supervisorName' as seen in Postman response
      supervisorName: json['supervisorName'] as String?, // Corrected key
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
      estRemunere: parseBoolean(json['estRemunere']), // Use the helper
      montantRemuneration: json['montantRemuneration'] != null
          ? double.tryParse(json['montantRemuneration'].toString())
          : null,
      // You might also want to parse other IDs if they are relevant elsewhere in your app,
      // e.g., 'etudiantID', 'sujetID', 'encadrantProID', 'chefCentreValidationID'
      // For example:
      // etudiantID: int.tryParse(json['etudiantID'].toString()),
      // sujetID: int.tryParse(json['sujetID'].toString()),
      // encadrantProID: int.tryParse(json['encadrantProID']?.toString() ?? ''),
      // chefCentreValidationID: int.tryParse(json['chefCentreValidationID']?.toString() ?? ''),
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
      // If studentName, subjectTitle, supervisorName are part of the update payload
      // expected by your PHP script, include them here. Otherwise, they can be omitted
      // if they are only for display and not for modification in the update process.
      'studentName': studentName,
      'subjectTitle': subjectTitle,
      'supervisorName': supervisorName,
    };
  }
}
