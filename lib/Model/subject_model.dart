// lib/Model/subject_model.dart
import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final int? subjectID; // Corresponds to 'sujetID' from API
  final String subjectName; // Corresponds to 'titre' from API
  final String? description; // Corresponds to 'description' from API

  const Subject({this.subjectID, required this.subjectName, this.description});

  // Factory constructor to create a Subject from JSON (from API response)
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      // 'sujetID' from API can be string, so use int.tryParse
      subjectID: int.tryParse(json['sujetID']?.toString() ?? ''),
      subjectName: json['titre'] as String, // 'titre' from API for subjectName
      description: json['description'] as String?, // 'description' from API
    );
  }

  // Method to convert Subject to JSON (for sending to API for add/update)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'titre': subjectName, // Send 'titre' to API for subjectName
      'description': description, // Send 'description' to API for description
    };
    if (subjectID != null) {
      data['sujetID'] = subjectID; // Include 'sujetID' when updating
    }
    return data;
  }

  // Method to create a copy with updated fields (useful for editing)
  Subject copyWith({int? subjectID, String? subjectName, String? description}) {
    return Subject(
      subjectID: subjectID ?? this.subjectID,
      subjectName: subjectName ?? this.subjectName,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [subjectID, subjectName, description];
}
