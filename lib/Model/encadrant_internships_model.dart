// lib/Model/Assignedinternship_model.dart
import 'package:pfa/Model/note_model.dart'; // Import your Note model here

class AssignedInternship {
  final int stageID;
  final String typeStage;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String statut;
  final bool estRemunere; // Changed to bool
  final double? montantRemuneration; // Changed to double?
  final int etudiantID;
  final int? sujetID;
  final int encadrantProID;
  final String studentFirstName;
  final String studentLastName;
  final String studentEmail;
  final String? subjectTitle;
  final List<Note> notes; // List of Note objects

  AssignedInternship({
    required this.stageID,
    required this.typeStage,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.estRemunere,
    this.montantRemuneration,
    required this.etudiantID,
    this.sujetID,
    required this.encadrantProID,
    required this.studentFirstName,
    required this.studentLastName,
    required this.studentEmail,
    this.subjectTitle,
    required this.notes,
  });

  factory AssignedInternship.fromJson(Map<String, dynamic> json) {
    // Parse 'estRemunere' (0 or 1 from JSON) to a boolean
    final bool isRemunere = (json['estRemunere'] as int) == 1;

    // Parse 'montantRemuneration' to double
    // It can be null in JSON, so handle that.
    final double? remunerationAmount = json['montantRemuneration'] != null
        ? double.tryParse(json['montantRemuneration'].toString())
        : null;

    // Parse 'notes' list
    final List<Note> notesList =
        (json['notes'] as List<dynamic>?)
            ?.map((noteJson) => Note.fromJson(noteJson as Map<String, dynamic>))
            .toList() ??
        [];

    return AssignedInternship(
      stageID: json['stageID'] as int,
      typeStage: json['typeStage'] as String,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dateFin: DateTime.parse(json['dateFin'] as String),
      statut: json['statut'] as String,
      estRemunere: isRemunere,
      montantRemuneration: remunerationAmount,
      etudiantID: json['etudiantID'] as int,
      sujetID: json['sujetID'] as int?,
      encadrantProID: json['encadrantProID'] as int,
      studentFirstName: json['studentFirstName'] as String,
      studentLastName: json['studentLastName'] as String,
      studentEmail: json['studentEmail'] as String,
      subjectTitle: json['subjectTitle'] as String?,
      notes: notesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageID': stageID,
      'typeStage': typeStage,
      'dateDebut': dateDebut.toIso8601String().split(
        'T',
      )[0], // Format to "YYYY-MM-DD"
      'dateFin': dateFin.toIso8601String().split(
        'T',
      )[0], // Format to "YYYY-MM-DD"
      'statut': statut,
      'estRemunere': estRemunere ? 1 : 0,
      'montantRemuneration': montantRemuneration?.toStringAsFixed(
        2,
      ), // Convert double to string with 2 decimal places
      'etudiantID': etudiantID,
      'sujetID': sujetID,
      'encadrantProID': encadrantProID,
      'studentFirstName': studentFirstName,
      'studentLastName': studentLastName,
      'studentEmail': studentEmail,
      'subjectTitle': subjectTitle,
      'notes': notes.map((note) => note.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Internship(\n'
        '  stageID: $stageID,\n'
        '  typeStage: $typeStage,\n'
        '  dateDebut: $dateDebut,\n'
        '  dateFin: $dateFin,\n'
        '  statut: $statut,\n'
        '  estRemunere: $estRemunere,\n'
        '  montantRemuneration: $montantRemuneration,\n'
        '  etudiantID: $etudiantID,\n'
        '  sujetID: $sujetID,\n'
        '  encadrantProID: $encadrantProID,\n'
        '  studentFirstName: $studentFirstName,\n'
        '  studentLastName: $studentLastName,\n'
        '  studentEmail: $studentEmail,\n'
        '  subjectTitle: $subjectTitle,\n'
        '  notes: $notes\n'
        ')';
  }
}

// Model for the overall response structure
class AssignedInternshipResponse {
  final String status;
  final String message;
  final List<AssignedInternship> data;

  AssignedInternshipResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AssignedInternshipResponse.fromJson(Map<String, dynamic> json) {
    final List<AssignedInternship> assignedinternships = (json['data'] as List<dynamic>)
        .map((e) => AssignedInternship.fromJson(e as Map<String, dynamic>))
        .toList();

    return AssignedInternshipResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: assignedinternships,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((assignedinternship) => assignedinternship.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AssignedInternshipResponse(status: $status, message: $message, data: $data)';
  }
}
