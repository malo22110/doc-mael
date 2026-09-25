class TimeUtils {
  static bool isOpen(DateTime time) {
    if (time.weekday == DateTime.sunday) return false;
    
    double hour = time.hour + time.minute / 60.0;
    bool morning = hour >= 8.0 && hour < 12.0;
    bool afternoon = hour >= 14.0 && hour < 18.5;
    bool fakeTestHours = hour >= 22.0 && hour < 24.0; // TEMPORARY FOR TESTING
    
    if (time.weekday == DateTime.saturday) {
      return morning || fakeTestHours;
    }
    return morning || afternoon || fakeTestHours;
  }

  static DateTime getNextOpenDate(DateTime now) {
    // If it's Sunday, next is Monday
    if (now.weekday == DateTime.sunday) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
    
    // If Saturday after 24:00 (which is impossible, but handle normal closing)
    // Actually we added 22-24h so it closes at midnight
    if (now.weekday == DateTime.saturday && now.hour >= 23 && now.minute >= 59) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    }
    
    // If weekday after 23:59, next is tomorrow
    if (now.weekday < DateTime.saturday && (now.hour >= 23 && now.minute >= 59)) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
    
    // Otherwise, it's today
    return DateTime(now.year, now.month, now.day);
  }

  static List<String> getSlotsForDate(DateTime date, DateTime now) {
    List<String> allSlots = [];
    if (date.weekday != DateTime.sunday) {
      allSlots.addAll([
        "08:00 - 09:00",
        "09:00 - 10:00",
        "10:00 - 11:00",
        "11:00 - 12:00",
      ]);
    }
    if (date.weekday < DateTime.saturday) {
      allSlots.addAll([
        "14:00 - 15:00",
        "15:00 - 16:00",
        "16:00 - 17:00",
        "17:00 - 18:30",
      ]);
    }

    // FAKE SLOTS FOR TESTING
    if (date.weekday != DateTime.sunday) {
      allSlots.addAll([
        "22:00 - 23:00",
        "23:00 - 23:59",
      ]);
    }

    // Filter past slots if the date is today
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return allSlots.where((slot) {
        final parts = slot.split(' - ')[1].split(':');
        final endHour = int.parse(parts[0]);
        final endMinute = int.parse(parts[1]);
        
        final slotEnd = DateTime(now.year, now.month, now.day, endHour, endMinute);
        return now.isBefore(slotEnd);
      }).toList();
    }

    return allSlots;
  }

  static String formatDate(DateTime date) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    
    return "${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}";
  }

  static String toDateString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
