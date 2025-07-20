class Internship {
  final int? internshipID;
  final String? studentName;
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
    this.internshipID,
    this.studentName,
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
      internshipID: int.tryParse(json['stageID'].toString()),
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

  Internship copyWith({
    int? internshipID,
    // add other fields here as needed, e.g. String? title, etc.
  }) {
    return Internship(
      internshipID: internshipID ?? this.internshipID,
      // copy other fields here, e.g. title: title ?? this.title, etc.
    );
  }
}
