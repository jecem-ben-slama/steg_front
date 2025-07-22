class Note {
  final int? noteID;
  final int stageID;
  final int encadrantID;
  final String dateNote; // Store as String for now, or parse to DateTime
  final String contenuNote;
  final String?
  encadrantName; // Optional: If you want to display the encadrant's name with the note

  Note({
    this.noteID,
    required this.stageID,
    required this.encadrantID,
    required this.dateNote,
    required this.contenuNote,
    this.encadrantName,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteID: json['noteID'] as int?,
      stageID: json['stageID'] as int,
      encadrantID: json['encadrantID'] as int,
      dateNote: json['dateNote'] as String,
      contenuNote: json['contenuNote'] as String,
      encadrantName:
          json['encadrantName'] as String?, // Assuming backend provides this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noteID': noteID,
      'stageID': stageID,
      'encadrantID': encadrantID,
      'dateNote': dateNote,
      'contenuNote': contenuNote,
      'encadrantName': encadrantName,
    };
  }
}
