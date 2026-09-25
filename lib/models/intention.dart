class Intention {
  final String id;
  final String locationId;
  final String targetDate;
  final String timeSlot;
  final DateTime createdAt;

  Intention({
    required this.id,
    required this.locationId,
    required this.targetDate,
    required this.timeSlot,
    required this.createdAt,
  });

  factory Intention.fromJson(Map<String, dynamic> json, String id) {
    return Intention(
      id: id,
      locationId: json['location_id'] as String,
      targetDate: json['target_date'] as String,
      timeSlot: json['time_slot'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'target_date': targetDate,
      'time_slot': timeSlot,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
