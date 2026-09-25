class Report {
  final String id;
  final String locationId;
  final String countRange;
  final DateTime createdAt;
  final String origin;
  final String deviceHash;

  Report({
    required this.id,
    required this.locationId,
    required this.countRange,
    required this.createdAt,
    required this.origin,
    required this.deviceHash,
  });

  factory Report.fromJson(Map<String, dynamic> json, String id) {
    return Report(
      id: id,
      locationId: json['location_id'] as String,
      countRange: json['count_range'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      origin: json['origin'] as String,
      deviceHash: json['device_hash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'count_range': countRange,
      'created_at': createdAt.toIso8601String(),
      'origin': origin,
      'device_hash': deviceHash,
    };
  }
}
