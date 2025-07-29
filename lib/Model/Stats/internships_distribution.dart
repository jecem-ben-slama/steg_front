import 'package:equatable/equatable.dart';

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
  List<FacultyInternshipSummary>? facultyInternshipSummary;
  List<SubjectDistribution>? subjectDistribution;
  double? totalFinancialExpenses;
  List<AnnualFinancialExpense>?
  annualFinancialExpenses; // NEW FIELD: For annual expenses

  Data({
    this.statusDistribution,
    this.typeDistribution,
    this.durationDistribution,
    this.encadrantDistribution,
    this.facultyInternshipSummary,
    this.subjectDistribution,
    this.totalFinancialExpenses,
    this.annualFinancialExpenses, // NEW: Add to constructor
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
    facultyInternshipSummary = json["faculty_internship_summary"] == null
        ? null
        : (json["faculty_internship_summary"] as List)
              .map((e) => FacultyInternshipSummary.fromJson(e))
              .toList();
    subjectDistribution = json["subject_distribution"] == null
        ? null
        : (json["subject_distribution"] as List)
              .map((e) => SubjectDistribution.fromJson(e))
              .toList();
    totalFinancialExpenses = (json["total_financial_expenses"] as num?)
        ?.toDouble();
    // NEW: Parse annual_financial_expenses
    annualFinancialExpenses = json["annual_financial_expenses"] == null
        ? null
        : (json["annual_financial_expenses"] as List)
              .map((e) => AnnualFinancialExpense.fromJson(e))
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
    if (facultyInternshipSummary != null) {
      newData["faculty_internship_summary"] = facultyInternshipSummary
          ?.map((e) => e.toJson())
          .toList();
    }
    if (subjectDistribution != null) {
      newData["subject_distribution"] = subjectDistribution
          ?.map((e) => e.toJson())
          .toList();
    }
    if (totalFinancialExpenses != null) {
      newData["total_financial_expenses"] = totalFinancialExpenses;
    }
    // NEW: Include annual_financial_expenses in toJson
    if (annualFinancialExpenses != null) {
      newData["annual_financial_expenses"] = annualFinancialExpenses
          ?.map((e) => e.toJson())
          .toList();
    }
    return newData;
  }
}

// NEW CLASS: To represent annual financial expense data
class AnnualFinancialExpense {
  int? year;
  double? annualExpenses;

  AnnualFinancialExpense({this.year, this.annualExpenses});

  factory AnnualFinancialExpense.fromJson(Map<String, dynamic> json) {
    return AnnualFinancialExpense(
      year: json["year"] as int?,
      annualExpenses: (json["annualExpenses"] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["year"] = year;
    newData["annualExpenses"] = annualExpenses;
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

class FacultyInternshipSummary {
  String? facultyName;
  int? totalStudents;
  int? totalInternships;
  int? validatedInternships;
  double? successRate;

  FacultyInternshipSummary({
    this.facultyName,
    this.totalStudents,
    this.totalInternships,
    this.validatedInternships,
    this.successRate,
  });

  FacultyInternshipSummary.fromJson(Map<String, dynamic> json) {
    facultyName = json["facultyName"];
    totalStudents = json["totalStudents"];
    totalInternships = json["totalInternships"];
    validatedInternships = json["validatedInternships"];
    successRate = (json["successRate"] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> newData = <String, dynamic>{};
    newData["facultyName"] = facultyName;
    newData["totalStudents"] = totalStudents;
    newData["totalInternships"] = totalInternships;
    newData["validatedInternships"] = validatedInternships;
    newData["successRate"] = successRate;
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
