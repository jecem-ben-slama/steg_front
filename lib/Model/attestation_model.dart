// lib/Model/attestation_data_model.dart
import 'package:equatable/equatable.dart';

// Main model to hold all attestation data
class AttestationData extends Equatable {
  final InternshipAttestationData internship;
  final StudentAttestationData student;
  final SubjectAttestationData subject;
  final SupervisorAttestationData supervisor;
  final EvaluationAttestationData evaluation;

  const AttestationData({
    required this.internship,
    required this.student,
    required this.subject,
    required this.supervisor,
    required this.evaluation,
  });

  factory AttestationData.fromJson(Map<String, dynamic> json) {
    return AttestationData(
      internship: InternshipAttestationData.fromJson(
        json['internship'] as Map<String, dynamic>,
      ),
      student: StudentAttestationData.fromJson(
        json['student'] as Map<String, dynamic>,
      ),
      subject: SubjectAttestationData.fromJson(
        json['subject'] as Map<String, dynamic>,
      ),
      supervisor: SupervisorAttestationData.fromJson(
        json['supervisor'] as Map<String, dynamic>,
      ),
      evaluation: EvaluationAttestationData.fromJson(
        json['evaluation'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  List<Object?> get props => [
    internship,
    student,
    subject,
    supervisor,
    evaluation,
  ];
}

// Sub-model for Internship details
class InternshipAttestationData extends Equatable {
  final int stageID;
  final String typeStage;
  final String dateDebut;
  final String dateFin;
  final String statut;
  final bool estRemunere;
  final double? montantRemuneration;

  const InternshipAttestationData({
    required this.stageID,
    required this.typeStage,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.estRemunere,
    this.montantRemuneration,
  });

  factory InternshipAttestationData.fromJson(Map<String, dynamic> json) {
    return InternshipAttestationData(
      stageID: json['stageID'] as int,
      typeStage: json['typeStage'] as String,
      dateDebut: json['dateDebut'] as String,
      dateFin: json['dateFin'] as String,
      statut: json['statut'] as String,
      estRemunere: json['estRemunere'] == 1, // PHP returns 0/1 for bool
      montantRemuneration: json['montantRemuneration'] != null
          ? (json['montantRemuneration'] as num).toDouble()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    stageID,
    typeStage,
    dateDebut,
    dateFin,
    statut,
    estRemunere,
    montantRemuneration,
  ];
}

// Sub-model for Student details
class StudentAttestationData extends Equatable {
  final int studentID;
  final String firstName;
  final String lastName;
  final String email;

  const StudentAttestationData({
    required this.studentID,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory StudentAttestationData.fromJson(Map<String, dynamic> json) {
    return StudentAttestationData(
      studentID: json['studentID'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );
  }

  @override
  List<Object?> get props => [studentID, firstName, lastName, email];
}

// Sub-model for Subject details
class SubjectAttestationData extends Equatable {
  final int? subjectID; // Can be null if not assigned
  final String? title;
  final String? description;

  const SubjectAttestationData({this.subjectID, this.title, this.description});

  factory SubjectAttestationData.fromJson(Map<String, dynamic> json) {
    return SubjectAttestationData(
      subjectID: json['subjectID'] != null
          ? int.tryParse(json['subjectID'].toString())
          : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [subjectID, title, description];
}

// Sub-model for Supervisor details
class SupervisorAttestationData extends Equatable {
  final int? supervisorID; // Can be null if not assigned
  final String? firstName;
  final String? lastName;
  final String? email;

  const SupervisorAttestationData({
    this.supervisorID,
    this.firstName,
    this.lastName,
    this.email,
  });

  factory SupervisorAttestationData.fromJson(Map<String, dynamic> json) {
    return SupervisorAttestationData(
      supervisorID: json['supervisorID'] != null
          ? int.tryParse(json['supervisorID'].toString())
          : null,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  List<Object?> get props => [supervisorID, firstName, lastName, email];
}

// Sub-model for Evaluation details
class EvaluationAttestationData extends Equatable {
  final int evaluationID;
  final double note;
  final String comments;
  final String dateEvaluation;

  const EvaluationAttestationData({
    required this.evaluationID,
    required this.note,
    required this.comments,
    required this.dateEvaluation,
  });

  factory EvaluationAttestationData.fromJson(Map<String, dynamic> json) {
    return EvaluationAttestationData(
      evaluationID: json['evaluationID'] as int,
      note: (json['note'] as num)
          .toDouble(), // PHP returns float, Dart needs double
      comments: json['comments'] as String,
      dateEvaluation: json['dateEvaluation'] as String,
    );
  }

  @override
  List<Object?> get props => [evaluationID, note, comments, dateEvaluation];
}
