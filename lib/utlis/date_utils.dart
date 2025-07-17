import 'package:intl/intl.dart';

class DateUtils {
  // Date formatters
  static final DateFormat _dayFormat = DateFormat('d');
  static final DateFormat _monthFormat = DateFormat('MMM');
  static final DateFormat _yearFormat = DateFormat('yyyy');
  static final DateFormat _fullDateFormat = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dayNameFormat = DateFormat('EEEE');
  static final DateFormat _shortDayFormat = DateFormat('EEE');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('MMM d');

  /// Returns the current date without time
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns yesterday's date
  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  /// Returns tomorrow's date
  static DateTime get tomorrow {
    return today.add(const Duration(days: 1));
  }

  /// Returns the start of the current week (Monday)
  static DateTime get startOfWeek {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  /// Returns the end of the current week (Sunday)
  static DateTime get endOfWeek {
    final now = DateTime.now();
    return now.add(Duration(days: 7 - now.weekday));
  }

  /// Returns the start of the current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Returns the end of the current month
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  /// Returns the start of the current year
  static DateTime get startOfYear {
    final now = DateTime.now();
    return DateTime(now.year, 1, 1);
  }

  /// Returns the end of the current year
  static DateTime get endOfYear {
    final now = DateTime.now();
    return DateTime(now.year, 12, 31);
  }

  /// Checks if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Checks if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime date) {
    return isSameDay(date, yesterday);
  }

  /// Checks if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    return isSameDay(date, tomorrow);
  }

  /// Checks if a date is in the current week
  static bool isInCurrentWeek(DateTime date) {
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Checks if a date is in the current month
  static bool isInCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Checks if a date is in the current year
  static bool isInCurrentYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  /// Returns the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  /// Returns the number of weeks between two dates
  static int weeksBetween(DateTime from, DateTime to) {
    return (daysBetween(from, to) / 7).round();
  }

  /// Returns the number of months between two dates
  static int monthsBetween(DateTime from, DateTime to) {
    return ((to.year - from.year) * 12) + (to.month - from.month);
  }

  /// Returns a list of dates for the current week
  static List<DateTime> getCurrentWeekDates() {
    final List<DateTime> dates = [];
    final start = startOfWeek;

    for (int i = 0; i < 7; i++) {
      dates.add(start.add(Duration(days: i)));
    }

    return dates;
  }

  /// Returns a list of dates for the current month
  static List<DateTime> getCurrentMonthDates() {
    final List<DateTime> dates = [];
    final start = startOfMonth;
    final end = endOfMonth;

    for (int i = 0; i <= daysBetween(start, end); i++) {
      dates.add(start.add(Duration(days: i)));
    }

    return dates;
  }

  /// Returns a list of dates for a specific month
  static List<DateTime> getMonthDates(int year, int month) {
    final List<DateTime> dates = [];
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    for (int i = 0; i <= daysBetween(start, end); i++) {
      dates.add(start.add(Duration(days: i)));
    }

    return dates;
  }

  /// Returns the week number in the year
  static int getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = daysBetween(startOfYear, date) + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  /// Returns the number of days in a month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Checks if a year is a leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Returns the age in years based on birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Returns a relative time string (e.g., "2 days ago", "in 3 hours")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      }
    } else if (difference.inDays < 0) {
      final futureDays = difference.inDays.abs();
      if (futureDays == 1) {
        return 'Tomorrow';
      } else if (futureDays < 7) {
        return 'In $futureDays days';
      } else if (futureDays < 30) {
        final weeks = (futureDays / 7).floor();
        return weeks == 1 ? 'In 1 week' : 'In $weeks weeks';
      } else {
        final months = (futureDays / 30).floor();
        return months == 1 ? 'In 1 month' : 'In $months months';
      }
    } else {
      if (difference.inHours > 0) {
        return difference.inHours == 1
            ? '1 hour ago'
            : '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return difference.inMinutes == 1
            ? '1 minute ago'
            : '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    }
  }

  // Formatting methods
  static String formatDay(DateTime date) => _dayFormat.format(date);
  static String formatMonth(DateTime date) => _monthFormat.format(date);
  static String formatYear(DateTime date) => _yearFormat.format(date);
  static String formatFullDate(DateTime date) => _fullDateFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDayName(DateTime date) => _dayNameFormat.format(date);
  static String formatShortDay(DateTime date) => _shortDayFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String formatDayMonth(DateTime date) => _dayMonthFormat.format(date);

  /// Formats date for display in habit completion context
  static String formatHabitDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isInCurrentWeek(date)) {
      return formatDayName(date);
    } else if (isInCurrentYear(date)) {
      return formatDayMonth(date);
    } else {
      return formatShortDate(date);
    }
  }

  /// Returns a friendly date string for streaks
  static String formatStreakDate(DateTime date) {
    if (isToday(date)) {
      return 'today';
    } else if (isYesterday(date)) {
      return 'yesterday';
    } else {
      return formatShortDate(date);
    }
  }

  /// Parses a date string in various formats
  static DateTime? parseDate(String dateString) {
    try {
      // Try different date formats
      final formats = [
        DateFormat('yyyy-MM-dd'),
        DateFormat('MM/dd/yyyy'),
        DateFormat('dd/MM/yyyy'),
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('MMM d, yyyy'),
      ];

      for (final format in formats) {
        try {
          return format.parse(dateString);
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Returns the start of day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Returns the first day of the week containing the given date
  static DateTime firstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Returns the last day of the week containing the given date
  static DateTime lastDayOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  /// Returns the first day of the month containing the given date
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Returns the last day of the month containing the given date
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Returns a list of DateTime objects representing the dates in a calendar month view
  /// (includes days from previous/next month to fill the calendar grid)
  static List<DateTime> getCalendarDates(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    // Find the first Monday of the calendar view
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    // Find the last Sunday of the calendar view
    final endDate = lastDay.add(Duration(days: 7 - lastDay.weekday));

    final List<DateTime> dates = [];
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }
}
