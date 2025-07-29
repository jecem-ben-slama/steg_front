// lib/Model/student_model.dart
import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final int? studentID;
  final String username;
  final String lastname;
  final String email;
  final String? cin; // Sticking to lowercase in Dart for consistency with PHP
  final String? niveau_etude; // Updated to match JSON
  final String? faculte; // Updated to match JSON
  final String? cycle;
  final String? specialite;

  const Student({
    this.studentID,
    required this.username,
    required this.lastname,
    required this.email,
    this.cin,
    this.niveau_etude,
    this.faculte,
    this.cycle,
    this.specialite,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: int.tryParse(json['etudiantID']?.toString() ?? ''),
      username: json['username'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      cin: json['cin'] as String?,
      niveau_etude: json['niveauEtude'] as String?,
      faculte: json['nomFaculte'] as String?, // Map from 'faculte'
      cycle: json['cycle'] as String?,
      specialite: json['specialite'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'lastname': lastname,
      'email': email,
      if (cin != null) 'cin': cin, // Send as lowercase 'cin' to PHP
      if (niveau_etude != null) 'niveau_etude': niveau_etude,
      if (faculte != null) 'faculte': faculte,
      if (cycle != null) 'cycle': cycle,
      if (specialite != null) 'specialite': specialite,
    };
    if (studentID != null) {
      data['etudiantID'] = studentID;
    }
    return data;
  }

  Student copyWith({
    int? studentID,
    int? userID,
    String? username,
    String? lastname,
    String? email,
    String? cin,
    String? niveau_etude,
    String? faculte,
    String? cycle,
    String? specialite,
  }) {
    return Student(
      studentID: studentID ?? this.studentID,
      username: username ?? this.username,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      cin: cin ?? this.cin,
      niveau_etude: niveau_etude ?? this.niveau_etude,
      faculte: faculte ?? this.faculte,
      cycle: cycle ?? this.cycle,
      specialite: specialite ?? this.specialite,
    );
  }

  @override
  List<Object?> get props => [
    studentID,
    username,
    lastname,
    email,
    cin,
    niveau_etude,
    faculte,
    cycle,
    specialite,
  ];
}
