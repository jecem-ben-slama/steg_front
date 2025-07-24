class KpiData {
  final int activeInternshipsCount;
  final int encadrantsCount;
  final int pendingEvaluationsCount;

  KpiData({
    required this.activeInternshipsCount,
    required this.encadrantsCount,
    required this.pendingEvaluationsCount,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      activeInternshipsCount: json['activeInternshipsCount'] as int,
      encadrantsCount: json['encadrantsCount'] as int,
      pendingEvaluationsCount: json['pendingEvaluationsCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeInternshipsCount': activeInternshipsCount,
      'encadrantsCount': encadrantsCount,
      'pendingEvaluationsCount': pendingEvaluationsCount,
    };
  }
}
