// lib/Model/internship_model.dart

class Internship {
  final int? internshipID; // Changed back to nullable
  final String? studentName;
  final String? studentEmail; // Added for completeness
  final String? subjectTitle;
  final String? supervisorName;
  final int? encadrantProID;
  final String? typeStage;
  final String? dateDebut;
  final String? dateFin;
  final String? statut;
  final bool? estRemunere;
  final double? montantRemuneration;
  final int? etudiantID;
  final int? sujetID;

  Internship({
    this.internshipID, // No longer required in constructor
    this.studentName,
    this.studentEmail, // Added for completeness
    this.subjectTitle,
    this.supervisorName,
    this.encadrantProID,
    this.typeStage,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.estRemunere,
    this.montantRemuneration,
    this.etudiantID,
    this.sujetID,
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
      internshipID: int.tryParse(
        json['stageID']?.toString() ?? '',
      ), // Handle potential null from backend
      studentName: json['studentName'] as String?,
      subjectTitle: json['subjectTitle'] as String?,
      supervisorName: json['supervisorName'] as String?,
      encadrantProID: int.tryParse(json['encadrantProID']?.toString() ?? ''),
      typeStage: json['typeStage'] as String?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
      estRemunere: parseBoolean(json['estRemunere']),
      montantRemuneration: json['montantRemuneration'] != null
          ? double.tryParse(json['montantRemuneration'].toString())
          : null,
      etudiantID: int.tryParse(json['etudiantID']?.toString() ?? ''),
      sujetID: int.tryParse(json['sujetID']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageID': internshipID,
      'typeStage': typeStage,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'statut': statut,
      'estRemunere': estRemunere != null ? (estRemunere! ? 1 : 0) : null,
      'montantRemuneration': montantRemuneration,
      'studentName': studentName,
      'subjectTitle': subjectTitle,
      'supervisorName': supervisorName,
      'encadrantProID': encadrantProID,
      'etudiantID': etudiantID,
      'sujetID': sujetID,
    };
  }

  // Updated copyWith method for nullable internshipID
  Internship copyWith({
    int? internshipID,
    String? studentName,
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
  }) {
    return Internship(
      internshipID: internshipID ?? this.internshipID,
      studentName: studentName ?? this.studentName,
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // If internshipID is null, then they are only equal if all other fields are equal.
    // However, for typical list operations (removeWhere, indexOf), if the ID is null,
    // it's likely a temporary object, so equality based on ID won't work.
    // For practical purposes, when dealing with items in a list, they should have IDs.
    return other is Internship && other.internshipID == internshipID;
  }

  @override
  int get hashCode => internshipID.hashCode;
}
