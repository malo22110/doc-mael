import 'package:flutter_test/flutter_test.dart';
import 'package:affluence_app/utils/time_utils.dart';

void main() {
  group('TimeUtils', () {
    test('[SPEC-F04] isOpen should return correct boolean based on time and day', () {
      // Monday 10:00 (Open)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 21, 10, 0)), isTrue);
      // Monday 13:00 (Closed - Lunch break)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 21, 13, 0)), isFalse);
      // Monday 15:00 (Open)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 21, 15, 0)), isTrue);
      // Monday 19:00 (Closed)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 21, 19, 0)), isFalse);

      // Saturday 10:00 (Open)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 26, 10, 0)), isTrue);
      // Saturday 15:00 (Closed usually, but check fakeTestHours)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 26, 15, 0)), isFalse);

      // Sunday 10:00 (Closed)
      expect(TimeUtils.isOpen(DateTime(2026, 9, 27, 10, 0)), isFalse);
    });

    test('[SPEC-F04] getNextOpenDate should return the correct next available day', () {
      // Monday 10:00 -> Same day
      final monday = DateTime(2026, 9, 21, 10, 0);
      expect(TimeUtils.getNextOpenDate(monday).day, 21);

      // Saturday 23:59 -> Monday
      final lateSaturday = DateTime(2026, 9, 26, 23, 59);
      expect(TimeUtils.getNextOpenDate(lateSaturday).day, 28); // 26 + 2 = 28

      // Sunday -> Monday
      final sunday = DateTime(2026, 9, 27, 10, 0);
      expect(TimeUtils.getNextOpenDate(sunday).day, 28);
    });
  });
}
