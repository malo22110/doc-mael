class DailyStatus {
  final String date;
  final int activeDoctors;
  final String lastUpdatedBy;
  final DateTime updatedAt;

  DailyStatus({
    required this.date,
    required this.activeDoctors,
    required this.lastUpdatedBy,
    required this.updatedAt,
  });

  factory DailyStatus.fromJson(Map<String, dynamic> json, String id) {
    return DailyStatus(
      date: id,
      activeDoctors: json['active_doctors'] as int,
      lastUpdatedBy: json['last_updated_by'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_doctors': activeDoctors,
      'last_updated_by': lastUpdatedBy,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
