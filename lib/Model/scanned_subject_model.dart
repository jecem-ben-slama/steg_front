import 'package:equatable/equatable.dart';

class NewSubject extends Equatable {
  final int?
  subjectID; // Corresponds to 'SubjectID' from DB, 'sujetID' from API
  final String title; // Corresponds to 'titre' from DB/API
  final String description; // Corresponds to 'description' from DB/API
  final String? pdfFileUrl; // Corresponds to 'pdfFileUrl' from DB/API

  const NewSubject({
    this.subjectID,
    required this.title,
    required this.description,
    this.pdfFileUrl,
  });

  // Factory constructor to create a Subject from JSON (from API response)
  factory NewSubject.fromJson(Map<String, dynamic> json) {
    return NewSubject(
      // 'SubjectID' from DB can be string from API, so use int.tryParse
      subjectID: json['SubjectID'] != null
          ? int.tryParse(json['SubjectID'].toString())
          : null,
      title: json['titre'] as String, // 'titre' from API for title
      description: json['description'] as String, // 'description' from API
      pdfFileUrl: json['pdfFileUrl'] as String?, // 'pdfFileUrl' from API
    );
  }

  // Method to convert Subject to JSON (for sending to API for add/update)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'titre': title,
      'description': description,
      'pdfFileUrl': pdfFileUrl, // Include pdfFileUrl
    };
    if (subjectID != null) {
      data['SubjectID'] =
          subjectID; // Include 'SubjectID' when updating/deleting
    }
    return data;
  }

  // Method to create a copy with updated fields (useful for editing)
  NewSubject copyWith({
    int? subjectID,
    String? title,
    String? description,
    String? pdfFileUrl,
  }) {
    return NewSubject(
      subjectID: subjectID ?? this.subjectID,
      title: title ?? this.title,
      description: description ?? this.description,
      pdfFileUrl: pdfFileUrl ?? this.pdfFileUrl,
    );
  }

  @override
  List<Object?> get props => [subjectID, title, description, pdfFileUrl];
}
