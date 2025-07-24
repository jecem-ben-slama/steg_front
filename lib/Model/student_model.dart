import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final int? studentID;
  final int? userID;
  final String username;
  final String lastname;
  final String email;
  final String? major;
  final String? level;
  final String? cin;
  final String? phoneNumber;

  final String? niveauEtude;
  final String? nomFaculte;
  final String? cycle;
  final String? specialite;

  const Student({
    this.studentID,
    this.userID,
    required this.username,
    required this.lastname,
    required this.email,
    this.major,
    this.level,
    this.cin,
    this.phoneNumber,
    this.niveauEtude,
    this.nomFaculte,
    this.cycle,
    this.specialite,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: int.tryParse(json['etudiantID']?.toString() ?? ''),
      userID: int.tryParse(json['userID']?.toString() ?? ''),
      username: json['username'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      major: json['specialite'] as String?,
      level: json['niveauEtude'] as String?,
      cin: json['cin'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      niveauEtude: json['niveauEtude'] as String?,
      nomFaculte: json['nomFaculte'] as String?,
      cycle: json['cycle'] as String?,
      specialite: json['specialite'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'lastname': lastname,
      'email': email,
      if (major != null) 'specialite': major,
      if (level != null) 'niveauEtude': level,
      if (cin != null) 'CIN': cin,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (userID != null) 'userID': userID,
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
    String? major,
    String? level,
    String? cin,
    String? phoneNumber,
    String? niveauEtude,
    String? nomFaculte,
    String? cycle,
    String? specialite,
  }) {
    return Student(
      studentID: studentID ?? this.studentID,
      userID: userID ?? this.userID,
      username: username ?? this.username,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      major: major ?? this.major,
      level: level ?? this.level,
      cin: cin ?? this.cin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      niveauEtude: niveauEtude ?? this.niveauEtude,
      nomFaculte: nomFaculte ?? this.nomFaculte,
      cycle: cycle ?? this.cycle,
      specialite: specialite ?? this.specialite,
    );
  }

  @override
  List<Object?> get props => [
    studentID,
    userID,
    username,
    lastname,
    email,
    major,
    level,
    cin,
    phoneNumber,
    niveauEtude,
    nomFaculte,
    cycle,
    specialite,
  ];
}
