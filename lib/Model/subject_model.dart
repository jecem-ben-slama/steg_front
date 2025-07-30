import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final int? subjectID; // Corresponds to 'sujetID' from API
  final String subjectName; // Corresponds to 'titre' from API
  final String? description; // Corresponds to 'description' from API
  final String? pdfUrl; // NEW: URL to the uploaded PDF

  const Subject({
    this.subjectID,
    required this.subjectName,
    this.description,
    this.pdfUrl,
  });

  // Factory constructor to create a Subject from JSON (from API response)
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectID: int.tryParse(json['sujetID']?.toString() ?? ''),
      subjectName: json['titre'] as String,
      description: json['description'] as String?,
      pdfUrl: json['pdfUrl'] as String?, // ✅ Extract from JSON
    );
  }

  // Method to convert Subject to JSON (for sending to API for add/update)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'titre': subjectName,
      'description': description,
    };
    if (subjectID != null) {
      data['sujetID'] = subjectID;
    }
    if (pdfUrl != null) {
      data['pdfUrl'] = pdfUrl; // ✅ Optional: in case you send URL back
    }
    return data;
  }

  // Method to create a copy with updated fields (useful for editing)
  Subject copyWith({
    int? subjectID,
    String? subjectName,
    String? description,
    String? pdfUrl,
  }) {
    return Subject(
      subjectID: subjectID ?? this.subjectID,
      subjectName: subjectName ?? this.subjectName,
      description: description ?? this.description,
      pdfUrl: pdfUrl ?? this.pdfUrl, // ✅ Added
    );
  }

  @override
  List<Object?> get props => [subjectID, subjectName, description, pdfUrl];
}
