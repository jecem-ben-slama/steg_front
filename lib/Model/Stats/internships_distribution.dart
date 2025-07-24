class InternshipDistribution {
  String? status;
  Data? data;

  InternshipDistribution({this.status, this.data});

  InternshipDistribution.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["status"] = status;
    if (data != null) {
      newData["data"] = data?.toJson();
    }
    return newData;
  }
}

class Data {
  List<StatusDistribution>? statusDistribution;
  List<TypeDistribution>? typeDistribution;
  List<DurationDistribution>? durationDistribution;
  List<EncadrantDistribution>? encadrantDistribution;
  List<FacultyDistribution>? facultyDistribution;
  List<SubjectDistribution>? subjectDistribution;

  Data({
    this.statusDistribution,
    this.typeDistribution,
    this.durationDistribution,
    this.encadrantDistribution,
    this.facultyDistribution,
    this.subjectDistribution,
  });

  Data.fromJson(Map<String, dynamic> json) {
    statusDistribution = json["status_distribution"] == null
        ? null
        : (json["status_distribution"] as List)
              .map((e) => StatusDistribution.fromJson(e))
              .toList();
    typeDistribution = json["type_distribution"] == null
        ? null
        : (json["type_distribution"] as List)
              .map((e) => TypeDistribution.fromJson(e))
              .toList();
    durationDistribution = json["duration_distribution"] == null
        ? null
        : (json["duration_distribution"] as List)
              .map((e) => DurationDistribution.fromJson(e))
              .toList();
    encadrantDistribution = json["encadrant_distribution"] == null
        ? null
        : (json["encadrant_distribution"] as List)
              .map((e) => EncadrantDistribution.fromJson(e))
              .toList();
    facultyDistribution = json["faculty_distribution"] == null
        ? null
        : (json["faculty_distribution"] as List)
              .map((e) => FacultyDistribution.fromJson(e))
              .toList();
    subjectDistribution = json["subject_distribution"] == null
        ? null
        : (json["subject_distribution"] as List)
              .map((e) => SubjectDistribution.fromJson(e))
              .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    if (statusDistribution != null) {
      newData["status_distribution"] = statusDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    if (typeDistribution != null) {
      newData["type_distribution"] = typeDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    if (durationDistribution != null) {
      newData["duration_distribution"] = durationDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    if (encadrantDistribution != null) {
      newData["encadrant_distribution"] = encadrantDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    if (facultyDistribution != null) {
      newData["faculty_distribution"] = facultyDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    if (subjectDistribution != null) {
      newData["subject_distribution"] = subjectDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    return newData;
  }
}

class SubjectDistribution {
  String? subjectTitle;
  int? count;

  SubjectDistribution({this.subjectTitle, this.count});

  SubjectDistribution.fromJson(Map<String, dynamic> json) {
    subjectTitle = json["subjectTitle"];
    count = json["count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["subjectTitle"] = subjectTitle;
    newData["count"] = count;
    return newData;
  }
}

class FacultyDistribution {
  String? facultyName;
  int? count;

  FacultyDistribution({this.facultyName, this.count});

  FacultyDistribution.fromJson(Map<String, dynamic> json) {
    facultyName = json["facultyName"];
    count = json["count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["facultyName"] = facultyName;
    newData["count"] = count;
    return newData;
  }
}

class EncadrantDistribution {
  String? encadrantName;
  int? internshipCount;

  EncadrantDistribution({this.encadrantName, this.internshipCount});

  EncadrantDistribution.fromJson(Map<String, dynamic> json) {
    encadrantName = json["encadrantName"];
    internshipCount = json["internshipCount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["encadrantName"] = encadrantName;
    newData["internshipCount"] = internshipCount;
    return newData;
  }
}

class DurationDistribution {
  String? range;
  int? count;

  DurationDistribution({this.range, this.count});

  DurationDistribution.fromJson(Map<String, dynamic> json) {
    range = json["range"];
    count = json["count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["range"] = range;
    newData["count"] = count;
    return newData;
  }
}

class TypeDistribution {
  String? type;
  int? count;

  TypeDistribution({this.type, this.count});

  TypeDistribution.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    count = json["count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["type"] = type;
    newData["count"] = count;
    return newData;
  }
}

class StatusDistribution {
  String? status;
  int? count;

  StatusDistribution({this.status, this.count});

  StatusDistribution.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    count = json["count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["status"] = status;
    newData["count"] = count;
    return newData;
  }
}
