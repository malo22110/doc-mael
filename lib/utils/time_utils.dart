class TimeUtils {
  static bool isOpen(DateTime time) {
    if (time.weekday == DateTime.sunday) return false;
    
    double hour = time.hour + time.minute / 60.0;
    bool morning = hour >= 8.0 && hour < 12.0;
    bool afternoon = hour >= 14.0 && hour < 18.5;
    
    if (time.weekday == DateTime.saturday) {
      return morning;
    }
    return morning || afternoon;
  }

  static DateTime getNextOpenDate(DateTime now) {
    if (now.weekday == DateTime.sunday) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
    if (now.weekday == DateTime.saturday && now.hour >= 12) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    }
    if (now.weekday < DateTime.saturday && (now.hour > 18 || (now.hour == 18 && now.minute >= 30))) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
    return DateTime(now.year, now.month, now.day);
  }

  static List<String> getAvailableSlots(DateTime date) {
    if (date.weekday == DateTime.sunday) return [];

    List<String> allSlots = [
      "08:00 - 09:00",
      "09:00 - 10:00",
      "10:00 - 11:00",
      "11:00 - 12:00",
    ];

    if (date.weekday != DateTime.saturday) {
      allSlots.addAll([
        "14:00 - 15:00",
        "15:00 - 16:00",
        "16:00 - 17:00",
        "17:00 - 18:00",
        "18:00 - 18:30",
      ]);
    }

    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return allSlots.where((slot) {
        final endHour = int.parse(slot.split(" - ")[1].split(":")[0]);
        final endMinute = int.parse(slot.split(" - ")[1].split(":")[1]);
        
        if (now.hour < endHour) return true;
        if (now.hour == endHour && now.minute < endMinute) return true;
        return false;
      }).toList();
    }

    return allSlots;
  }

  static String getFormattedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }
  
  static String formatDate(DateTime date) {
    return getFormattedDate(date);
  }

  static String toDateString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static List<String> getSlotsForDate(DateTime targetDate, DateTime now) {
    return getAvailableSlots(targetDate);
  }
}
