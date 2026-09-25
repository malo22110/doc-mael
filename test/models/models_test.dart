import 'package:flutter_test/flutter_test.dart';
import 'package:affluence_app/models/report.dart';
import 'package:affluence_app/models/daily_status.dart';

void main() {
  group('Models Serialization', () {
    test('Report should serialize to and from JSON', () {
      final now = DateTime.now();
      final report = Report(
        id: '123',
        locationId: 'loc1',
        countRange: '3-5',
        createdAt: now,
        origin: 'test',
        deviceHash: 'hash',
      );

      final json = report.toJson();
      expect(json['count_range'], '3-5');
      expect(json['location_id'], 'loc1');

      final deserialized = Report.fromJson(json, '123');
      expect(deserialized.id, '123');
      expect(deserialized.countRange, '3-5');
      expect(deserialized.locationId, 'loc1');
    });

    test('DailyStatus should serialize to and from JSON', () {
      final now = DateTime.now();
      final status = DailyStatus(
        date: '2026-09-25',
        activeDoctors: 3,
        lastUpdatedBy: 'system',
        updatedAt: now,
      );

      final json = status.toJson();
      expect(json['active_doctors'], 3);
      expect(json['date'], '2026-09-25');

      final deserialized = DailyStatus.fromJson(json, 'doc_id');
      expect(deserialized.activeDoctors, 3);
      expect(deserialized.date, '2026-09-25');
    });
  });
}
